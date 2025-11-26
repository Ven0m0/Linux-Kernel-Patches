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
║  • TKG Package Management                                         ║
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
  ${CYN}t2linux${DEF}         Build kernel for Apple T2 hardware (MacBook/iMac)
  ${CYN}tkg${DEF}             Launch TKG installer (Frogging-Family packages)
  ${CYN}patches${DEF}         Manage and apply kernel patches
  ${CYN}compile${DEF}         Run standard kernel compilation
  ${CYN}config${DEF}          Configure kernel build options
  ${CYN}fetch${DEF}           Fetch latest patches from sources
  ${CYN}list${DEF}            List available patches by version
  ${CYN}help${DEF}            Show this help message

${YLW}Examples:${DEF}
  ${0##*/} catgirl              # Build catgirl-edition kernel with optimizations
  ${0##*/} t2linux              # Build kernel with T2 hardware support and RT patches
  ${0##*/} tkg                  # Launch TKG installer TUI
  ${0##*/} patches 6.17         # Show patches available for kernel 6.17
  ${0##*/} compile              # Standard kernel compilation
  ${0##*/} fetch                # Fetch latest patches

${YLW}Build Profiles:${DEF}
  ${CYN}Catgirl Edition${DEF}  - Aggressive optimizations, multiple schedulers
                       (BORE, EEVDF, BMQ, RT), LTO, -O3, performance tweaks
  ${CYN}T2 Linux${DEF}         - Apple T2 hardware support (MacBook Pro, iMac Pro)
                       with T2-specific patches, optional RT patches
  ${CYN}TKG Packages${DEF}     - Frogging-Family customizable builds
                       (linux-tkg, nvidia-tkg, mesa-tkg, wine-tkg, proton-tkg)
  ${CYN}Standard Patches${DEF} - Curated patches from CachyOS, XanMod, Clear Linux,
                       and other sources

${YLW}Documentation:${DEF}
  See ${CYN}docs/${DEF} directory for detailed guides
  See ${CYN}build/catgirl-edition/README.md${DEF} for catgirl optimizations
  Run ${CYN}./scripts/tkg-installer help${DEF} for TKG installer usage
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
#──────────── Build T2 Linux ────────────
build_t2linux(){
  info "Building T2 Linux Kernel (Apple T2 Hardware Support)"
  warn "This will build a kernel optimized for Apple T2 hardware"
  printf '\n'
  local nproc_count
  nproc_count=$(nproc)
  export MAKEFLAGS="-j${nproc_count}" INSTALL_PATH=/boot/linux
  mkdir -p kernel && cd kernel
  msg "Grabbing kernel and patches..."
  rm -rf patches 2>/dev/null || :
  git clone --depth=1 --filter=blob:none https://github.com/t2linux/linux-t2-patches patches
  # Get latest kernel version from T2-Ubuntu-Kernel releases
  local release_page pkgver _srcname
  release_page=$(fetch "https://github.com/t2linux/T2-Ubuntu-Kernel/releases/latest/")
  # Extract version: parse <title>Release vX.Y.Z-...</title>
  if [[ $release_page =~ \<title\>Release\ v([0-9]+\.[0-9]+\.[0-9]+) ]]; then
    pkgver=${BASH_REMATCH[1]}
  else
    die "Failed to parse kernel version from T2 releases"
  fi
  _srcname="linux-${pkgver}"
  msg "Downloading kernel ${pkgver}..."
  local major_ver=${pkgver%%.*}
  fetch "https://kernel.org/pub/linux/kernel/v${major_ver}.x/${_srcname}.tar.xz" "${_srcname}.tar.xz"
  tar xf "${_srcname}.tar.xz"
  cd "$_srcname"
  # Apply T2 patches
  msg "Applying T2 patches..."
  local patch
  for patch in ../patches/*.patch; do
    [[ -f $patch ]] && patch -Np1 < "$patch"
  done
  # Copy current kernel config
  zcat /proc/config.gz > .config
  local kernelver localver kernelmajminver
  kernelver=$(make kernelversion)
  localver=$(grep -oP 'CONFIG_LOCALVERSION="\K[^"]*' .config) || localver=""
  kernelmajminver="${kernelver%.*}"
  # Grab RT patchset
  msg "Checking for real-time patches..."
  local rt_index rtpatchfile rtver=""
  rt_index=$(fetch "https://kernel.org/pub/linux/kernel/projects/rt/${kernelmajminver}/") || :
  if [[ -n $rt_index ]]; then
    # Extract patch filename (patch-X.Y.Z-rtN.patch.xz)
    if [[ $rt_index =~ href=\"(patch-[^\"]+\.patch\.xz)\" ]]; then
      rtpatchfile=${BASH_REMATCH[1]}
      # Extract RT version (-rtN)
      [[ $rtpatchfile =~ -rt([0-9]+) ]] && rtver="-rt${BASH_REMATCH[1]}"
      info "Grabbing real-time patches..."
      fetch "https://kernel.org/pub/linux/kernel/projects/rt/${kernelmajminver}/${rtpatchfile}" "../patches/${rtpatchfile}" || :
      if [[ -f ../patches/${rtpatchfile} ]]; then
        xz -d "../patches/${rtpatchfile}" || :
        local rtpatch_uncompressed=${rtpatchfile%.xz}
        msg "Applying real-time patches..."
        patch -Np1 < "../patches/${rtpatch_uncompressed}" || :
      fi
    fi
  fi
  [[ -z $rtver ]] && warn "Real-time patches not available for this kernel version."
  msg "Configuring kernel..."
  # Disable debug info for smaller/faster builds
  ./scripts/config --undefine GDB_SCRIPTS
  ./scripts/config --undefine DEBUG_INFO
  ./scripts/config --undefine DEBUG_INFO_SPLIT
  ./scripts/config --undefine DEBUG_INFO_REDUCED
  ./scripts/config --undefine DEBUG_INFO_COMPRESSED
  ./scripts/config --set-val DEBUG_INFO_NONE y
  ./scripts/config --set-val DEBUG_INFO_DWARF5 n
  make olddefconfig
  # Configure T2-specific modules
  ./scripts/config --module CONFIG_BT_HCIBCM4377
  ./scripts/config --module CONFIG_HID_APPLE_IBRIDGE
  ./scripts/config --module CONFIG_HID_APPLE_TOUCHBAR
  ./scripts/config --module CONFIG_HID_APPLE_MAGIC_BACKLIGHT
  info "Building kernel (this may take a while)..."
  make && make modules_install
  info "Installing kernel..."
  kernel-install add "${kernelver}${rtver}${localver}" ./vmlinux
  info "T2 Linux kernel build complete!"
  msg "Kernel version: ${kernelver}${rtver}${localver}"
  cd "$SCRIPT_DIR"
}
#──────────── Launch TKG ────────────────
launch_tkg(){
  info "Launching TKG Installer"; local tkg_script="scripts/tkg-installer"
  if [[ ! -x $tkg_script ]]; then
    warn "TKG installer not found, installing..."; bash scripts/install-tkg.sh
  fi
  exec "$tkg_script" "$@"
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
  ${CYN}2${DEF}) Build T2 Linux Kernel (Apple T2 Hardware)
  ${CYN}3${DEF}) Launch TKG Installer (TUI)
  ${CYN}4${DEF}) Browse Patch Collection
  ${CYN}5${DEF}) Standard Kernel Compilation
  ${CYN}6${DEF}) Kernel Configuration
  ${CYN}7${DEF}) Fetch Latest Patches
  ${CYN}8${DEF}) Help & Documentation
  ${CYN}q${DEF}) Quit

EOF
  local choice
  read -rp "Enter choice: " choice
  case $choice in
    1) build_catgirl ;;
    2) build_t2linux ;;
    3) launch_tkg ;;
    4) list_patches ;;
    5) bash scripts/compile.sh ;;
    6) bash scripts/config.sh ;;
    7) bash scripts/fetch.sh ;;
    8) show_usage ;;
    q|Q) exit 0 ;;
    *) die "Invalid option" ;;
  esac
}
#──────────── Main Entry ────────────────
main(){
  cd "$SCRIPT_DIR"
  case ${1:-} in
    catgirl) build_catgirl ;;
    t2linux) build_t2linux ;;
    tkg) shift; launch_tkg "$@" ;;
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
