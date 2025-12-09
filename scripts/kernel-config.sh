#!/usr/bin/env bash
# Unified kernel configuration script
# Replaces: config.sh, trim.sh, cachy/cachy.sh
#
# Usage:
#   kernel-config.sh [--mode=MODE] <kernel_src_dir>
#
# Modes:
#   minimal  - Basic optimizations (old config.sh)
#   trim     - Aggressive driver trimming (old trim.sh)
#   cachy    - CachyOS optimized (old cachy/cachy.sh)
#   full     - All optimizations (default)
#
# Examples:
#   kernel-config.sh --mode=minimal /usr/src/linux-6.18
#   kernel-config.sh --mode=trim /usr/src/linux-6.18
#   kernel-config.sh /usr/src/linux-6.18  # Uses full mode

set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'

# Script directory
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Source the library
if [[ -f "${SCRIPT_DIR}/lib-kernel-config.sh" ]]; then
  # shellcheck source=./lib-kernel-config.sh
  source "${SCRIPT_DIR}/lib-kernel-config.sh"
else
  echo "Error: Cannot find lib-kernel-config.sh in ${SCRIPT_DIR}" >&2
  exit 1
fi

# Color definitions
RED=$'\e[31m'
GRN=$'\e[32m'
YLW=$'\e[33m'
BLU=$'\e[34m'
DEF=$'\e[0m'

# Print functions
info() { printf '%b\n' "${GRN}$*${DEF}"; }
warn() { printf '%b\n' "${YLW}$*${DEF}"; }
error() { printf '%b\n' "${RED}Error: $*${DEF}" >&2; }
die() { error "$*"; exit 1; }

# Show usage
usage() {
  cat << EOF
${BLU}Unified Kernel Configuration Script${DEF}

${GRN}Usage:${DEF}
  $(basename "$0") [OPTIONS] <kernel_src_dir>

${GRN}Options:${DEF}
  --mode=MODE        Configuration mode (default: full)
  -m MODE           Configuration mode (short form)
  --help, -h        Show this help message

${GRN}Modes:${DEF}
  minimal           Basic optimizations and debug disabling
                    - Equivalent to old config.sh
                    - Good for general use

  trim              Aggressive driver and subsystem trimming
                    - Equivalent to old trim.sh
                    - Smaller kernel, fewer drivers
                    - Best for custom desktop builds

  cachy             CachyOS-optimized configuration
                    - Equivalent to old cachy/cachy.sh
                    - Performance-focused desktop
                    - Includes Clear Linux defaults

  full              All optimizations combined (default)
                    - Complete performance optimization
                    - Maximum size reduction
                    - Desktop/gaming focused

${GRN}Examples:${DEF}
  # Apply minimal config
  $(basename "$0") --mode=minimal /usr/src/linux-6.18

  # Apply trim profile
  $(basename "$0") --mode=trim /usr/src/linux-6.18

  # Apply CachyOS profile
  $(basename "$0") -m cachy /usr/src/linux-6.18

  # Apply full profile (default)
  $(basename "$0") /usr/src/linux-6.18

${GRN}Notes:${DEF}
  - Kernel source must have 'scripts/config' available
  - Run 'make scripts' first if needed
  - This script replaces config.sh, trim.sh, and cachy/cachy.sh

EOF
}

# Parse arguments
MODE="full"
KERNEL_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode=*)
      MODE="${1#*=}"
      shift
      ;;
    -m)
      MODE="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      die "Unknown option: $1"
      ;;
    *)
      KERNEL_DIR="$1"
      shift
      ;;
  esac
done

# Validate arguments
[[ -n "$KERNEL_DIR" ]] || {
  error "Kernel source directory not specified"
  echo
  usage
  exit 1
}

[[ -d "$KERNEL_DIR" ]] || die "Directory not found: $KERNEL_DIR"
[[ -f "$KERNEL_DIR/scripts/config" ]] || die "Not a valid kernel source tree: $KERNEL_DIR"

# Validate mode
case "$MODE" in
  minimal|trim|cachy|full) ;;
  *) die "Invalid mode: $MODE (must be: minimal, trim, cachy, or full)" ;;
esac

# Main execution
main() {
  info "Unified Kernel Configuration"
  info "Mode: ${YLW}${MODE}${DEF}"
  info "Kernel source: ${YLW}${KERNEL_DIR}${DEF}"
  echo

  # Change to kernel directory
  cd "$KERNEL_DIR" || die "Cannot enter directory: $KERNEL_DIR"

  # Build kernel scripts if needed
  if [[ ! -x scripts/config ]]; then
    info "Building kernel scripts..."
    make scripts || die "Failed to build kernel scripts"
  fi

  # Sort modprobed databases before configuration
  if [[ -f "${SCRIPT_DIR}/utils/sort-modprobed-dbs" ]]; then
    info "Sorting modprobed databases..."
    "${SCRIPT_DIR}/utils/sort-modprobed-dbs" || warn "Failed to sort modprobed databases"
  fi

  # Apply configuration based on mode
  info "Applying ${MODE} configuration..."

  case "$MODE" in
    minimal)
      apply_minimal_profile "$KERNEL_DIR"
      ;;
    trim)
      apply_trim_profile "$KERNEL_DIR"
      ;;
    cachy)
      apply_cachy_profile "$KERNEL_DIR"
      ;;
    full)
      apply_full_profile "$KERNEL_DIR"
      ;;
  esac

  echo
  info "Configuration complete!"
  info "Next steps:"
  echo "  1. Review configuration: make menuconfig"
  echo "  2. Build kernel: make -j\$(nproc)"
  echo "  3. Install modules: sudo make modules_install"
  echo "  4. Install kernel: sudo make install"
}

# Run main
main
