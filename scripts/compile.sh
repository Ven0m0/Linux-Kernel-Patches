#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# Kernel compilation script with optimizations
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s
readonly SCRIPT_DIR=$(cd -P -- "${s%/*}" && pwd)
cd -P -- "$SCRIPT_DIR"
has(){ command -v -- "$1" &>/dev/null; }

[[ -f ${SCRIPT_DIR}/lib-kernel-config.sh ]] || { echo "Error: Cannot find lib-kernel-config.sh" >&2; exit 1; }
# shellcheck source=./lib-kernel-config.sh
source "${SCRIPT_DIR}/lib-kernel-config.sh"

KERNEL_DIR="${1:-.}"
[[ -d $KERNEL_DIR ]] || { echo "Error: Directory not found: $KERNEL_DIR" >&2; exit 1; }
cd "$KERNEL_DIR" || exit 1
[[ -f Makefile ]] && grep -q "^VERSION = " Makefile || { echo "Error: Not a valid kernel source tree" >&2; exit 1; }

echo "==> Kernel Compilation Setup"; echo "    Directory: $KERNEL_DIR"; echo

if has modprobed-db; then echo "==> Storing modprobed database..."; modprobed-db store
else echo "Warning: modprobed-db not found, skipping module tracking" >&2; fi

echo "==> Building kernel scripts..."; make scripts

echo "==> Applying performance optimizations..."
apply_performance_opts "$KERNEL_DIR"
apply_preemption_opts "$KERNEL_DIR"
apply_compiler_opts "$KERNEL_DIR"
apply_debug_disable "$KERNEL_DIR"
apply_network_opts "$KERNEL_DIR"
apply_memory_opts "$KERNEL_DIR"

if scripts/config --state CACHY &>/dev/null; then
  echo "==> Applying CachyOS-specific options..."; scripts/config -e CACHY -e SCHED_BORE
fi

echo "==> Building configuration..."
readonly MODPROBED_DB="${HOME}/.config/modprobed.db"
if [[ -f $MODPROBED_DB ]]; then echo "    Using modprobed database: $MODPROBED_DB"; yes "" | make LSMOD="$MODPROBED_DB" localmodconfig
else echo "    Warning: modprobed.db not found at $MODPROBED_DB"; yes "" | make localmodconfig; fi

echo "==> Preparing kernel build..."; make prepare
echo "==> Launching kernel configuration interface..."; make -j"$(nproc)" xconfig
