#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=./scripts/lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/scripts/lib-common.sh"

export DEBIAN_FRONTEND=noninteractive
cd -P -- "$SCRIPT_DIR"
HOME="${HOME:-/home/${SUDO_USER:-$USER}}"
VERSION="1.0.0"

# PORTED/ADAPTED FROM AKM
LocalVersion(){ get_package_version "$1"; }
Exist(){ local version="$1"; [[ -n $version ]] && printf TRUE || printf FALSE; }
AvailableKernelsAndHeaders(){
  require_commands expac
  local headers kernel header
  mapfile -t headers < <(expac -Ss '%r/%n' 'linux[-]*[^ pi]*-headers' | grep -Pv 'testing/linux-|linux-api-headers')
  for header in "${headers[@]}"; do
    kernel="${header%-headers}"
    printf "%s %s\n" "$kernel" "$header"
  done
  [[ -v akm_kernels_headers_user ]] && [[ ${#akm_kernels_headers_user[@]} -gt 0 ]] && printf "%s\n" "${akm_kernels_headers_user[@]}"
}
akm_load_config(){
  local conf=/etc/akm.conf
  [[ -f $conf ]] || return 0
  # shellcheck disable=SC1090
  source "$conf"
  : "${KERNEL_HEADER_WITH_KERNEL:=}" "${AKM_KERNELS_HEADERS:=}"
  : "${AKM_WINDOW_WIDTH:=}" "${AKM_PREFER_SMALL_WINDOW:=}"
  [[ -n $KERNEL_HEADER_WITH_KERNEL ]] && connect_header_with_kernel="$KERNEL_HEADER_WITH_KERNEL"
  [[ -n $AKM_KERNELS_HEADERS ]] && akm_kernels_headers_user=("${AKM_KERNELS_HEADERS[@]}")
  [[ -n $AKM_WINDOW_WIDTH ]] && akm_window_width="$AKM_WINDOW_WIDTH"
  [[ -n $AKM_PREFER_SMALL_WINDOW ]] && small_font="$AKM_PREFER_SMALL_WINDOW"
}

parse_repo_type(){
  if has pacman-conf && pacman-conf --repo-list | grep -q "\-testing$"; then
    echo "Testing"
  else
    echo "Stable"
  fi
}

# Usage
show_usage(){
  cat <<EOF
${GRN}Usage:${DEF} ${0##*/} [command] [options]

${YLW}Commands:${DEF}
  ${CYN}catgirl${DEF}         Build optimized catgirl-edition kernel
  ${CYN}tkg${DEF}             Build TKG (Frogging-Family) packages
  ${CYN}patches${DEF}         Manage and apply kernel patches
  ${CYN}list${DEF}            List available patches by version
  ${CYN}kernels${DEF}         List available installed/packaged kernels
  ${CYN}help${DEF}            Show this help message
EOF
}

# Kernel/Package Info & List
list_kernels(){
  info "Available Kernel Packages (Arch-family style):"
  local kernels=()
  mapfile -t kernels < <(AvailableKernelsAndHeaders)
  local item ix=0
  for item in "${kernels[@]}"; do
    ((ix++))
    set -- $item
    printf "  %s) %s\n     %s\n" "$ix" "$1" "$2"
    v1=$(LocalVersion "$1")
    v2=$(LocalVersion "$2")
    printf "     %s: %s\n     %s: %s\n" "$1" "${v1:-not installed}" "$2" "${v2:-not installed}"
    exist1=$(Exist "$v1")
    exist2=$(Exist "$v2")
    printf "     Installed: %s (kernel) %s (headers)\n" "$exist1" "$exist2"
    echo
  done
}

# Stub functions (to be implemented)
build_catgirl(){ warn "catgirl build not yet implemented"; }
build_tkg(){ warn "tkg build not yet implemented"; }
manage_patches(){ warn "patch management not yet implemented"; }
list_patches(){ warn "patch listing not yet implemented"; }

# Main Command Handling
main(){
  cd "$SCRIPT_DIR"
  [[ $# -eq 0 ]] && show_usage && exit 1
  case $1 in
    catgirl) shift; build_catgirl "$@" ;;
    tkg) shift; build_tkg "$@" ;;
    patches) shift; manage_patches "$@" ;;
    compile) bash scripts/compile.sh ;;
    config) bash scripts/config.sh ;;
    fetch) bash scripts/fetch.sh ;;
    list) list_patches ;;
    kernels) list_kernels ;;
    help|--help|-h) show_usage ;;
    *) die "Unknown command: $1"; show_usage ;;
  esac
}
main "$@"
