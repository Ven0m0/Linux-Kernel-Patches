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
  ${CYN}cachymod${DEF}        Build CachyMod kernels (interactive CachyOS builds)
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

  # Batch all package queries to avoid repeated subprocess spawning
  local -a all_packages=()
  local item
  for item in "${kernels[@]}"; do
    set -- $item
    all_packages+=("$1" "$2")
  done

  # Query all versions in a single expac call
  declare -A version_map=()
  if [[ ${#all_packages[@]} -gt 0 ]]; then
    local pkg_versions
    if has expac; then
      pkg_versions=$(expac -Q '%n:%v' "${all_packages[@]}" 2>/dev/null || true)
    elif has pacman; then
      pkg_versions=$(pacman -Q "${all_packages[@]}" 2>/dev/null | awk '{print $1":"$2}' || true)
    fi

    while IFS=: read -r pkg ver; do
      [[ -n $pkg ]] && version_map[$pkg]=$ver
    done <<<"$pkg_versions"
  fi

  # Display results
  local ix=0
  for item in "${kernels[@]}"; do
    ((ix++))
    set -- $item
    local kernel=$1 header=$2
    local v1=${version_map[$kernel]:-}
    local v2=${version_map[$header]:-}

    printf "  %s) %s\n     %s\n" "$ix" "$kernel" "$header"
    printf "     %s: %s\n     %s: %s\n" "$kernel" "${v1:-not installed}" "$header" "${v2:-not installed}"

    # Inline existence check to avoid function call overhead
    local exist1="FALSE" exist2="FALSE"
    [[ -n $v1 ]] && exist1="TRUE"
    [[ -n $v2 ]] && exist2="TRUE"
    printf "     Installed: %s (kernel) %s (headers)\n" "$exist1" "$exist2"
    echo
  done
}

# Build Functions
build_catgirl(){
  info "Building Catgirl Edition kernel..."
  cd build/catgirl-edition || die "Catgirl edition directory not found"
  makepkg -scf --cleanbuild --skipchecksums "$@"
}

build_cachymod(){
  info "Launching CachyMod build system..."
  local cachymod_dir="build/cachymod"

  if [[ ! -d "$cachymod_dir" ]]; then
    die "CachyMod directory not found at $cachymod_dir"
  fi

  # Check for gum dependency
  if ! has gum; then
    warn "CachyMod requires 'gum' for interactive configuration"
    info "Install it with: sudo pacman -S gum"
    die "Missing dependency: gum"
  fi

  # Show CachyMod menu
  cat <<EOF

${BLD}${CYN}CachyMod Build System${DEF}
Interactive kernel builder for CachyOS

${YLW}Available Actions:${DEF}
  ${GRN}1)${DEF} Configure new kernel (confmod.sh)
  ${GRN}2)${DEF} Build kernel from config
  ${GRN}3)${DEF} List available configurations
  ${GRN}4)${DEF} Uninstall CachyMod kernels
  ${GRN}5)${DEF} View README

EOF

  # If arguments provided, handle them
  if [[ $# -gt 0 ]]; then
    case $1 in
      config|configure)
        cd "$cachymod_dir/6.18" || die "CachyMod 6.18 directory not found"
        ../confmod.sh
        ;;
      build)
        cd "$cachymod_dir/6.18" || die "CachyMod 6.18 directory not found"
        shift
        ./build.sh "$@"
        ;;
      list)
        cd "$cachymod_dir/6.18" || die "CachyMod 6.18 directory not found"
        ./build.sh list
        ;;
      uninstall)
        cd "$cachymod_dir" || die "CachyMod directory not found"
        ./uninstall.sh
        ;;
      readme|help)
        less "$cachymod_dir/README.md" || cat "$cachymod_dir/README.md"
        ;;
      *)
        die "Unknown cachymod command: $1"
        ;;
    esac
  else
    # Interactive mode - run confmod.sh
    info "Launching interactive configuration..."
    cd "$cachymod_dir/6.18" || die "CachyMod 6.18 directory not found"
    ../confmod.sh
  fi
}

build_tkg(){ warn "tkg build not yet implemented"; }
manage_patches(){ warn "patch management not yet implemented"; }
list_patches(){ warn "patch listing not yet implemented"; }

# Main Command Handling
main(){
  cd "$SCRIPT_DIR"
  [[ $# -eq 0 ]] && show_usage && exit 1
  case $1 in
    catgirl) shift; build_catgirl "$@" ;;
    cachymod) shift; build_cachymod "$@" ;;
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
