#!/usr/bin/env bash
# Kernel compilation script with optimizations
# Applies performance optimizations and builds kernel configuration

set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Script directory
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source the configuration library
if [[ -f "${SCRIPT_DIR}/lib-kernel-config.sh" ]]; then
  # shellcheck source=./lib-kernel-config.sh
  source "${SCRIPT_DIR}/lib-kernel-config.sh"
else
  echo "Error: Cannot find lib-kernel-config.sh" >&2
  exit 1
fi

# Kernel source directory (current directory or first argument)
KERNEL_DIR="${1:-.}"

# Validate kernel directory
[[ -d "$KERNEL_DIR" ]] || {
  echo "Error: Directory not found: $KERNEL_DIR" >&2
  exit 1
}

cd "$KERNEL_DIR" || exit 1

[[ -f "Makefile" ]] && grep -q "^VERSION = " Makefile || {
  echo "Error: Not a valid kernel source tree" >&2
  exit 1
}

echo "==> Kernel Compilation Setup"
echo "    Directory: $KERNEL_DIR"
echo

# Store module database
if command -v modprobed-db &>/dev/null; then
  echo "==> Storing modprobed database..."
  modprobed-db store
else
  echo "Warning: modprobed-db not found, skipping module tracking" >&2
fi

# Build kernel scripts
echo "==> Building kernel scripts..."
make scripts

# Apply configuration optimizations using library
echo "==> Applying performance optimizations..."
apply_performance_opts "$KERNEL_DIR"
apply_preemption_opts "$KERNEL_DIR"
apply_compiler_opts "$KERNEL_DIR"
apply_debug_disable "$KERNEL_DIR"
apply_network_opts "$KERNEL_DIR"
apply_memory_opts "$KERNEL_DIR"

# CachyOS/BORE-specific options (if available)
if scripts/config --state CACHY &>/dev/null; then
  echo "==> Applying CachyOS-specific options..."
  scripts/config -e CACHY -e SCHED_BORE
fi

# Build configuration with modprobed-db if available
echo "==> Building configuration..."
readonly MODPROBED_DB="${HOME}/.config/modprobed.db"
if [[ -f "$MODPROBED_DB" ]]; then
  echo "    Using modprobed database: $MODPROBED_DB"
  yes "" | make LSMOD="$MODPROBED_DB" localmodconfig
else
  echo "    Warning: modprobed.db not found at $MODPROBED_DB"
  yes "" | make localmodconfig
fi

# Prepare build
echo "==> Preparing kernel build..."
make prepare

# Launch configuration interface
echo "==> Launching kernel configuration interface..."
make -j"$(nproc)" xconfig
