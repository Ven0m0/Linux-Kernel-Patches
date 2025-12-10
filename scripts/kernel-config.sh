#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# Unified kernel configuration script
# Replaces:  config.sh, trim.sh, cachy/cachy.sh

set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'

# Resolve script directory
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
readonly SCRIPT_DIR=$PWD

# Source library
# shellcheck source=./lib-kernel-config.sh
source "${SCRIPT_DIR}/lib-kernel-config.sh"

# Color definitions
readonly RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' BLU=$'\e[34m' DEF=$'\e[0m'

info(){ printf '%b\n' "${GRN}$*${DEF}"; }
warn(){ printf '%b\n' "${YLW}$*${DEF}"; }
error(){ printf '%b\n' "${RED}Error: $*${DEF}" >&2; }
die(){ error "$*"; exit 1; }

usage(){
  cat << EOF
${BLU}Unified Kernel Configuration Script${DEF}

${GRN}Usage:${DEF}
  $(basename "$0") [OPTIONS] <kernel_src_dir>

${GRN}Options:${DEF}
  --mode=MODE, -m MODE  Configuration mode (default: full)
  --help, -h            Show this help

${GRN}Modes:${DEF}
  minimal   Basic optimizations + debug disabling (old config. sh)
  trim      Aggressive driver trimming (old trim.sh)
  cachy     CachyOS-optimized (old cachy/cachy.sh)
  full      All optimizations (default)

${GRN}Examples:${DEF}
  $(basename "$0") --mode=minimal /usr/src/linux-6.18
  $(basename "$0") -m cachy /usr/src/linux-6.18
  $(basename "$0") /usr/src/linux-6.18  # Uses full mode

${GRN}Notes:${DEF}
  - Requires scripts/config in kernel source tree
  - Run 'make scripts' first if needed
  - Replaces config.sh, trim.sh, cachy/cachy.sh
EOF
}

# Parse arguments
MODE=full KERNEL_DIR=
while [[ $# -gt 0 ]]; do
  case $1 in
    --mode=*) MODE=${1#*=}; shift ;;
    -m) MODE=${2: ? Mode required}; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    -*) die "Unknown option: $1" ;;
    *) KERNEL_DIR=$1; shift ;;
  esac
done

# Validate
[[ -n $KERNEL_DIR ]] || { error "Kernel source directory required"; echo; usage; exit 1; }
[[ -d $KERNEL_DIR ]] || die "Directory not found: $KERNEL_DIR"
[[ -f $KERNEL_DIR/scripts/config ]] || die "Not a kernel source tree: $KERNEL_DIR"
[[ $MODE =~ ^(minimal|trim|cachy|full)$ ]] || die "Invalid mode: $MODE"

# Main
main(){
  info "Unified Kernel Configuration"
  info "Mode: ${YLW}${MODE}${DEF}"
  info "Kernel source: ${YLW}${KERNEL_DIR}${DEF}"
  echo

  cd "$KERNEL_DIR" || die "Cannot enter:  $KERNEL_DIR"

  # Build scripts if needed
  [[ -x scripts/config ]] || { info "Building kernel scripts..."; make scripts || die "Failed to build scripts"; }

  # Sort modprobed databases
  [[ -f ${SCRIPT_DIR}/utils/sort-modprobed-dbs ]] && {
    info "Sorting modprobed databases..."
    "${SCRIPT_DIR}/utils/sort-modprobed-dbs" || warn "Failed to sort modprobed databases"
  }

  # Apply profile
  info "Applying ${MODE} configuration..."
  case $MODE in
    minimal) apply_minimal_profile "$KERNEL_DIR" ;;
    trim) apply_trim_profile "$KERNEL_DIR" ;;
    cachy) apply_cachy_profile "$KERNEL_DIR" ;;
    full) apply_full_profile "$KERNEL_DIR" ;;
  esac

  echo
  info "Configuration complete!"
  info "Next steps:"
  echo "  1. make menuconfig"
  echo "  2. make -j\$(nproc)"
  echo "  3. sudo make modules_install"
  echo "  4. sudo make install"
}

main
