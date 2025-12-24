#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# Kernel compilation script with optimizations
# shellcheck source=./lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"

cd -P -- "$SCRIPT_DIR"

[[ -f ${SCRIPT_DIR}/lib-kernel-config.sh ]] || die "Cannot find lib-kernel-config.sh"
# shellcheck source=./lib-kernel-config.sh
source "${SCRIPT_DIR}/lib-kernel-config.sh"

KERNEL_DIR="${1:-.}"
validate_kernel_dir "$KERNEL_DIR"
cd "$KERNEL_DIR" || die "Cannot enter directory: $KERNEL_DIR"

info "Kernel Compilation Setup"
msg "    Directory: $KERNEL_DIR"
echo

if has modprobed-db; then
  info "Storing modprobed database..."
  modprobed-db store
else
  warn "modprobed-db not found, skipping module tracking"
fi

info "Building kernel scripts..."
make scripts || die "Failed to build kernel scripts"

info "Applying performance optimizations..."
apply_performance_opts "$KERNEL_DIR"
apply_preemption_opts "$KERNEL_DIR"
apply_compiler_opts "$KERNEL_DIR"
apply_debug_disable "$KERNEL_DIR"
apply_network_opts "$KERNEL_DIR"
apply_memory_opts "$KERNEL_DIR"

if scripts/config --state CACHY &>/dev/null; then
  info "Applying CachyOS-specific options..."
  scripts/config -e CACHY -e SCHED_BORE
fi

info "Building configuration..."
readonly MODPROBED_DB="${HOME}/.config/modprobed.db"
if [[ -f $MODPROBED_DB ]]; then
  msg "    Using modprobed database: $MODPROBED_DB"
  yes "" | make LSMOD="$MODPROBED_DB" localmodconfig
else
  warn "modprobed.db not found at $MODPROBED_DB"
  yes "" | make localmodconfig
fi

info "Preparing kernel build..."
make prepare || die "Failed to prepare kernel"

info "Launching kernel configuration interface..."
make -j"$(nproc)" xconfig
