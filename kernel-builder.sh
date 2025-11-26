#!/usr/bin/env bash
# =============================================================================
# Linux Kernel Builder - Unified Build System
# =============================================================================
# Combines functionality from:
# - Linux-Kernel-Patches: Curated patch collection
# - linux-catgirl-edition: Optimized kernel builds with PKGBUILD
# - tkginstaller: TKG package management and TUI
# =============================================================================
set -e; shopt -s nullglob globstar
IFS=$'\n\t' LC_ALL=C LANG=C
VERSION="1.0.0"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
#──────────── Color & Style ────────────
RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' BLD=$'\e[1m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'
#──────────── Helpers ────────────────────
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b\n' "${RED}Error:${DEF} $*" >&2; exit 1; }
info(){ printf '%b\n' "${GRN}$*${DEF}"; }
warn(){ printf '%b\n' "${YLW}$*${DEF}"; }
msg(){ printf '%b\n' "${CYN}$*${DEF}"; }
# Common curl options for all downloads
readonly CURL_OPTS=(-fLSs --proto '=https' --tlsv1.2 --compressed --connect-timeout 15 --retry 3 --retry-delay 2 --retry-max-time 60 --progress-bar)
# Fetch URL to stdout or file (silent mode)
fetch(){ local url=$1 out=${2:-}; [[ -n $out ]] && opts+=(-o "$out"); curl "${opts[@]}" "$url"; }
#──────────── Banner ────────────────────
show_banner(){
  printf '%b' "$CYN"
  cat <<'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                  Linux Kernel Builder Suite                       ║
║  Unified build system combining:                                  ║
║  • Curated Kernel Patches (6.12-6.18)                             ║
║  • Catgirl Edition Optimizations                                  ║
║  • TKG (Frogging-Family) Package Building                         ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
  printf '%b\n' "$DEF"
}
#──────────── Usage ────────────────────
show_usage(){
  cat <<EOF
${GRN}Usage:${DEF} ${0##*/} [command] [options]

${YLW}Commands:${DEF}
  ${CYN}catgirl${DEF}         Build optimized catgirl-edition kernel
  ${CYN}tkg${DEF}             Build TKG (Frogging-Family) packages
  ${CYN}patches${DEF}         Manage and apply kernel patches
  ${CYN}compile${DEF}         Run standard kernel compilation
  ${CYN}config${DEF}          Configure kernel build options
  ${CYN}fetch${DEF}           Fetch latest patches from sources
  ${CYN}list${DEF}            List available patches by version
  ${CYN}help${DEF}            Show this help message

${YLW}Examples:${DEF}
  ${0##*/} catgirl              # Build catgirl-edition kernel with optimizations
  ${0##*/} tkg linux            # Build Linux-TKG kernel
  ${0##*/} tkg nvidia           # Build Nvidia-TKG drivers
  ${0##*/} patches 6.17         # Show patches available for kernel 6.17
  ${0##*/} compile              # Standard kernel compilation
  ${0##*/} fetch                # Fetch latest patches

${YLW}Build Profiles:${DEF}
  ${CYN}Catgirl Edition${DEF}  - Aggressive optimizations, multiple schedulers
                       (BORE, EEVDF, BMQ, RT), LTO, -O3, performance tweaks
  ${CYN}TKG Packages${DEF}     - Frogging-Family customizable builds
                       (linux-tkg, nvidia-all, mesa-git, wine-tkg, proton-tkg)
  ${CYN}Standard Patches${DEF} - Curated patches from CachyOS, XanMod, Clear Linux,
                       and other sources

${YLW}Documentation:${DEF}
  See ${CYN}docs/${DEF} directory for detailed guides
  See ${CYN}build/catgirl-edition/README.md${DEF} for catgirl optimizations
  See ${CYN}https://github.com/Frogging-Family${DEF} for TKG documentation
EOF
}
#──────────── Build Catgirl ────────────
build_catgirl(){
  info "Building Catgirl Edition Kernel"
  warn "This will build an optimized kernel using the catgirl-edition PKGBUILD"
  printf '\n'
  local pkgbuild="build/catgirl-edition/PKGBUILD"
  [[ -f $pkgbuild ]] || die "PKGBUILD not found in build/catgirl-edition/"
  cd build/catgirl-edition
  msg "Please review the PKGBUILD and customize as needed:"
  printf '%s\n' "  - CPU scheduler (BORE/EEVDF/BMQ/RT)"
  printf '%s\n' "  - Optimization level (-O3, LTO)"
  printf '%s\n' "  - Patchsets (CachyOS, Clear Linux, XanMod)"
  printf '\n'
  local edit_choice
  read -rp "Do you want to edit the PKGBUILD before building? (y/N): " edit_choice
  [[ ${edit_choice,,} == y ]] && "${EDITOR:-nano}" PKGBUILD
  info "Starting build..."
  makepkg -scf --cleanbuild --skipchecksums
  info "Build complete!"
  printf '%s\n' "Install the package with: ${CYN}sudo pacman -U linux-catgirl-*.pkg.tar.zst${DEF}"
}
#──────────── TKG Package Builder ──────
# Detect distribution
detect_distro(){
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_LIKE="${ID_LIKE:-}"
  else
    DISTRO_ID="unknown"
    DISTRO_LIKE=""
  fi
  # Check if Arch-based
  if [[ "${DISTRO_ID,,}" =~ ^(arch|cachyos|manjaro|endeavouros)$ || "${DISTRO_LIKE,,}" == *"arch"* ]]; then
    IS_ARCH_BASED=true
  else
    IS_ARCH_BASED=false
  fi
}
# Generic TKG package installer
install_tkg_package(){
  local repo_url="$1" package_name="$2" build_cmd="$3" work_dir="${4:-}"
  info "Building ${package_name} from Frogging-Family"
  local tmp_dir="${HOME}/.cache/kernel-builder/tkg"
  mkdir -p "$tmp_dir" && cd "$tmp_dir"
  msg "Cloning repository..."
  rm -rf "$(basename "$repo_url" .git)" 2>/dev/null || :
  git clone --depth=1 "$repo_url" || die "Failed to clone $repo_url"
  local repo_dir="$(basename "$repo_url" .git)"
  cd "$repo_dir" || die "Failed to enter $repo_dir"
  [[ -n $work_dir ]] && { cd "$work_dir" || die "Failed to enter $work_dir"; }
  info "Building ${package_name}..."
  eval "$build_cmd" || die "Build failed for $package_name"
  info "${package_name} build complete!"
  cd "$SCRIPT_DIR"
}
# TKG package builder
build_tkg(){
  local package="${1:-}"
  detect_distro
  case "${package,,}" in
    linux|l)
      msg "Building Linux-TKG kernel"
      local build_cmd
      if [[ $IS_ARCH_BASED == true ]]; then
        info "Arch-based distribution detected, using makepkg"
        build_cmd="makepkg -Csic"
      else
        info "Using generic install script"
        build_cmd="chmod +x install.sh && ./install.sh install"
      fi
      install_tkg_package "https://github.com/Frogging-Family/linux-tkg.git" \
        "Linux-TKG" "$build_cmd"
      ;;
    nvidia|n)
      [[ $IS_ARCH_BASED != true ]] && die "Nvidia-TKG only supports Arch-based distributions"
      msg "Building Nvidia-TKG drivers"
      install_tkg_package "https://github.com/Frogging-Family/nvidia-all.git" \
        "Nvidia-TKG" "makepkg -Csic"
      ;;
    mesa|m)
      [[ $IS_ARCH_BASED != true ]] && die "Mesa-TKG only supports Arch-based distributions"
      msg "Building Mesa-TKG"
      install_tkg_package "https://github.com/Frogging-Family/mesa-git.git" \
        "Mesa-TKG" "makepkg -Csic"
      ;;
    wine|w)
      msg "Building Wine-TKG"
      local build_cmd
      if [[ $IS_ARCH_BASED == true ]]; then
        build_cmd="makepkg -Csic"
      else
        build_cmd="chmod +x non-makepkg-build.sh && ./non-makepkg-build.sh"
      fi
      install_tkg_package "https://github.com/Frogging-Family/wine-tkg-git.git" \
        "Wine-TKG" "$build_cmd" "wine-tkg-git"
      ;;
    proton|p)
      msg "Building Proton-TKG"
      install_tkg_package "https://github.com/Frogging-Family/wine-tkg-git.git" \
        "Proton-TKG" "./proton-tkg.sh" "proton-tkg"
      ;;
    "")
      warn "No TKG package specified"
      printf '\n%s\n' "Available TKG packages:"
      printf '  %blinux%b   - Custom Linux kernel (linux-tkg)\n' "$CYN" "$DEF"
      [[ $IS_ARCH_BASED == true ]] && {
        printf '  %bnvidia%b  - Nvidia drivers (nvidia-all)\n' "$CYN" "$DEF"
        printf '  %bmesa%b    - Mesa graphics (mesa-git)\n' "$CYN" "$DEF"
      }
      printf '  %bwine%b    - Wine compatibility layer (wine-tkg)\n' "$CYN" "$DEF"
      printf '  %bproton%b  - Proton for Steam (proton-tkg)\n' "$CYN" "$DEF"
      printf '\n%s\n' "Usage: ${0##*/} tkg [linux|nvidia|mesa|wine|proton]"
      ;;
    *)
      die "Unknown TKG package: $package"
      ;;
  esac
}
#──────────── Manage Patches ────────────
manage_patches(){
  local version=${1:-}
  if [[ -z $version ]]; then
    warn "Available kernel versions:"; local dir
    for dir in 6.*/; do
      [[ -d $dir ]] && printf '  %b%s%b\n' "$CYN" "${dir%/}" "$DEF"
    done
    printf '\n%s\n' "Usage: ${0##*/} patches <version>"
    printf '%s\n' "Example: ${0##*/} patches 6.17"; return
  fi
  [[ -d $version ]] || die "Version $version not found"
  info "Patches available for kernel ${version}:"
  printf '\n'
  local patch size
  while IFS= read -r patch; do
    printf '  %b%s%b\n' "$CYN" "$patch" "$DEF"
    size=$(du -h "$patch" | cut -f1)
    printf '    Size: %s\n\n' "$size"
  done < <(find "$version" -type f -name "*.patch")
}
#──────────── List Patches ────────────
list_patches(){
  info "Kernel Patch Collection"
  printf '\n'
  local version count
  for version in 6.*/; do
    [[ -d $version ]] || continue
    version=${version%/}
    printf '%b=== %s ===%b\n' "$CYN" "$version" "$DEF"
    count=$(find "$version" -type f -name "*.patch" 2>/dev/null | wc -l)
    printf '  Patches: %d\n' "$count"
    [[ -d "${version}/catgirl-edition" ]] && \
      printf '  %b✓ Catgirl Edition patches available%b\n' "$MGN" "$DEF"
    printf '\n'
  done
}
#──────────── Main Menu ────────────────
main_menu(){
  show_banner
  warn "Select an option:"
  cat <<EOF

  ${CYN}1${DEF}) Build Catgirl Edition Kernel (Optimized)
  ${CYN}2${DEF}) Build TKG Package (Frogging-Family)
  ${CYN}3${DEF}) Browse Patch Collection
  ${CYN}4${DEF}) Standard Kernel Compilation
  ${CYN}5${DEF}) Kernel Configuration
  ${CYN}6${DEF}) Fetch Latest Patches
  ${CYN}7${DEF}) Help & Documentation
  ${CYN}q${DEF}) Quit

EOF
  local choice
  read -rp "Enter choice: " choice
  case $choice in
    1) build_catgirl ;;
    2) build_tkg ;;
    3) list_patches ;;
    4) bash scripts/compile.sh ;;
    5) bash scripts/config.sh ;;
    6) bash scripts/fetch.sh ;;
    7) show_usage ;;
    q|Q) exit 0 ;;
    *) die "Invalid option" ;;
  esac
}
#──────────── Main Entry ────────────────
main(){
  cd "$SCRIPT_DIR"
  case ${1:-} in
    catgirl) build_catgirl ;;
    tkg) shift; build_tkg "$@" ;;
    patches) shift; manage_patches "$@" ;;
    compile) bash scripts/compile.sh ;;
    config) bash scripts/config.sh ;;
    fetch) bash scripts/fetch.sh ;;
    list) list_patches ;;
    help|--help|-h) show_banner; show_usage ;;
    "") main_menu ;;
    *) die "Unknown command: $1"; show_usage ;;
  esac
}
main "$@"
