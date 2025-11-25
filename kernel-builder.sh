#!/usr/bin/env bash
# =============================================================================
# Linux Kernel Builder - Unified Build System
# =============================================================================
# Combines functionality from:
# - Linux-Kernel-Patches: Curated patch collection
# - linux-catgirl-edition: Optimized kernel builds with PKGBUILD
# - tkginstaller: TKG package management and TUI
# =============================================================================
set -e
LC_ALL=C LANG=C
VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
# Banner
show_banner(){
  echo -e "${CYAN}"
  cat <<'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                  Linux Kernel Builder Suite                       ║
║  Unified build system combining:                                  ║
║  • Curated Kernel Patches (6.12-6.18)                             ║
║  • Catgirl Edition Optimizations                                  ║
║  • TKG Package Management                                         ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"
}

# Usage information
show_usage(){
    cat <<EOF
${GREEN}Usage:${NC} $0 [command] [options]

${YELLOW}Commands:${NC}
  ${CYAN}catgirl${NC}         Build optimized catgirl-edition kernel
  ${CYAN}t2linux${NC}         Build kernel for Apple T2 hardware (MacBook/iMac)
  ${CYAN}tkg${NC}             Launch TKG installer (Frogging-Family packages)
  ${CYAN}patches${NC}         Manage and apply kernel patches
  ${CYAN}compile${NC}         Run standard kernel compilation
  ${CYAN}config${NC}          Configure kernel build options
  ${CYAN}fetch${NC}           Fetch latest patches from sources
  ${CYAN}list${NC}            List available patches by version
  ${CYAN}help${NC}            Show this help message

${YELLOW}Examples:${NC}
  $0 catgirl              # Build catgirl-edition kernel with optimizations
  $0 t2linux              # Build kernel with T2 hardware support and RT patches
  $0 tkg                  # Launch TKG installer TUI
  $0 patches 6.17         # Show patches available for kernel 6.17
  $0 compile              # Standard kernel compilation
  $0 fetch                # Fetch latest patches

${YELLOW}Build Profiles:${NC}
  ${CYAN}Catgirl Edition${NC}  - Aggressive optimizations, multiple schedulers
                       (BORE, EEVDF, BMQ, RT), LTO, -O3, performance tweaks
  ${CYAN}T2 Linux${NC}         - Apple T2 hardware support (MacBook Pro, iMac Pro)
                       with T2-specific patches, optional RT patches
  ${CYAN}TKG Packages${NC}     - Frogging-Family customizable builds
                       (linux-tkg, nvidia-tkg, mesa-tkg, wine-tkg, proton-tkg)
  ${CYAN}Standard Patches${NC} - Curated patches from CachyOS, XanMod, Clear Linux,
                       and other sources

${YELLOW}Documentation:${NC}
  See ${CYAN}docs/${NC} directory for detailed guides
  See ${CYAN}build/catgirl-edition/README.md${NC} for catgirl optimizations
  Run ${CYAN}./scripts/tkg-installer help${NC} for TKG installer usage
EOF
}

# Build catgirl-edition kernel
build_catgirl(){
  echo -e "${GREEN}Building Catgirl Edition Kernel${NC}"
  echo -e "${YELLOW}This will build an optimized kernel using the catgirl-edition PKGBUILD${NC}\n"
  if [[ ! -f "build/catgirl-edition/PKGBUILD" ]]; then
    echo -e "${RED}Error: PKGBUILD not found in build/catgirl-edition/${NC}"; exit 1
  fi
  cd build/catgirl-edition
  echo -e "${CYAN}Please review the PKGBUILD and customize as needed:${NC}"
  echo -e "  - CPU scheduler (BORE/EEVDF/BMQ/RT)"
  echo -e "  - Optimization level (-O3, LTO)"
  echo -e "  - Patchsets (CachyOS, Clear Linux, XanMod)"
  echo ""
  read -p "Do you want to edit the PKGBUILD before building? (y/N): " edit_choice
  [[ "$edit_choice" =~ ^[Yy]$ ]] && ${EDITOR:-nano} PKGBUILD
  echo -e "${GREEN}Starting build...${NC}"
  makepkg -scf --cleanbuild --skipchecksums
  echo -e "${GREEN}Build complete!${NC}"
  echo -e "Install the package with: ${CYAN}sudo pacman -U linux-catgirl-*.pkg.tar.zst${NC}"
}

# Build T2 Linux kernel (for Apple T2 hardware)
build_t2linux(){
  echo -e "${GREEN}Building T2 Linux Kernel (Apple T2 Hardware Support)${NC}"
  echo -e "${YELLOW}This will build a kernel optimized for Apple T2 hardware${NC}"
  echo ""
  # Set up environment
  MAKEFLAGS=-j$(nproc)
  export MAKEFLAGS INSTALL_PATH=/boot/linux
  mkdir -p kernel && cd kernel
  echo -e "${CYAN}Grabbing kernel and patches...${NC}"
  rm -rf patches 2> /dev/null || :
  git clone --depth=1 --filter=blob:none https://github.com/t2linux/linux-t2-patches patches

  # Get latest kernel version from T2-Ubuntu-Kernel releases
  pkgver=$(curl -sL https://github.com/t2linux/T2-Ubuntu-Kernel/releases/latest/ | grep "<title>Release" | awk -F " " '{print $2}' | cut -d "v" -f 2 | cut -d "-" -f 1)
  _srcname=linux-${pkgver}
  echo -e "${CYAN}Downloading kernel ${pkgver}...${NC}"
  wget https://kernel.org/pub/linux/kernel/v"${pkgver//.*/}".x/"$_srcname".tar.xz
  tar xvf "$_srcname".tar.xz
  cd "$_srcname"
  # Apply T2 patches
  echo -e "${CYAN}Applying T2 patches...${NC}"
  for patch in ../patches/*.patch; do patch -Np1 < "$patch"; done
  # Copy current kernel config
  zcat /proc/config.gz > .config
  kernelver=$(make kernelversion)
  localver=$(grep 'CONFIG_LOCALVERSION=' .config | awk -F '"' '{print $2}')
  kernelmajminver=$(echo "$kernelver" | awk -F "." '{print $1 "." $2}')
  # Grab RT patchset
  echo -e "${CYAN}Checking for real-time patches...${NC}"
  rtpatchfile=$(curl -s --location "https://kernel.org/pub/linux/kernel/projects/rt/$kernelmajminver/" | grep -ioE '<a href="(patch-.+)">' | awk -F '"' '{print $2}' | tail -n 1)
  rtver=$(echo "$rtpatchfile" | awk -F "-" '{print $3}' | awk -F "\\\." '{print "-" $1}')
  if [[ -n $rtpatchfile ]]; then
      echo -e "${GREEN}Grabbing real-time patches...${NC}"
      wget -O "../patches/$rtpatchfile" "https://kernel.org/pub/linux/kernel/projects/rt/$kernelmajminver/$rtpatchfile" || :
      xz -d "../patches/$rtpatchfile" || :
      echo -e "${CYAN}Applying real-time patches...${NC}"
      patch -Np1 < "../patches/$(echo "$rtpatchfile" | head -c -4)" || :
  else
    echo -e "${YELLOW}Real-time patches not available for this kernel version.${NC}"
  fi
  echo -e "${CYAN}Configuring kernel...${NC}"
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
  scripts/config --module CONFIG_BT_HCIBCM4377
  scripts/config --module CONFIG_HID_APPLE_IBRIDGE
  scripts/config --module CONFIG_HID_APPLE_TOUCHBAR
  scripts/config --module CONFIG_HID_APPLE_MAGIC_BACKLIGHT
  echo -e "${GREEN}Building kernel (this may take a while)...${NC}"
  make && make modules_install
  echo -e "${GREEN}Installing kernel...${NC}"
  kernel-install add "$kernelver$rtver$localver" ./vmlinux
  echo -e "${GREEN}T2 Linux kernel build complete!${NC}"
  echo -e "${CYAN}Kernel version: $kernelver$rtver$localver${NC}"
  cd "$SCRIPT_DIR"
}

# Launch TKG installer
launch_tkg(){
  echo -e "${GREEN}Launching TKG Installer${NC}"
  if [[ ! -x "scripts/tkg-installer" ]]; then
      echo -e "${RED}Error: TKG installer not found${NC}"
      echo -e "${YELLOW}Installing TKG installer...${NC}"
      bash scripts/install-tkg.sh
  fi
  exec scripts/tkg-installer "$@"
}

# Manage patches
manage_patches(){
  local version="$1"
  if [[ -z "$version" ]]; then
      echo -e "${YELLOW}Available kernel versions:${NC}"
      for dir in 6.*; do
        [[ -d "$dir" ]] && echo -e "  ${CYAN}$dir${NC}"
      done
      echo ""
      echo -e "Usage: $0 patches <version>"
      echo -e "Example: $0 patches 6.17"; return
    fi
  if [[ ! -d "$version" ]]; then
      echo -e "${RED}Error: Version $version not found${NC}"; return 1
  fi

    echo -e "${GREEN}Patches available for kernel $version:${NC}"
    echo ""

    find "$version" -type f -name "*.patch" | while read -r patch; do
        echo -e "  ${CYAN}$patch${NC}"
        local size=$(du -h "$patch" | cut -f1)
        echo -e "    Size: $size"
        echo ""
    done
}

# List all patches
list_patches(){
    echo -e "${GREEN}Kernel Patch Collection${NC}\n"
    for version in 6.*; do
        if [[ -d "$version" ]]; then
            echo -e "${CYAN}=== $version ===${NC}"
            local count=$(find "$version" -type f -name "*.patch" 2>/dev/null | wc -l)
            echo -e "  Patches: $count"
            [[ -d "$version/catgirl-edition" ]] && echo -e "  ${MAGENTA}✓ Catgirl Edition patches available${NC}\n"
        fi
    done
}

# Main menu
main_menu(){
    show_banner
    echo -e "${YELLOW}Select an option:${NC}"
    echo -e "\n  ${CYAN}1${NC}) Build Catgirl Edition Kernel (Optimized)"
    echo -e "  ${CYAN}2${NC}) Build T2 Linux Kernel (Apple T2 Hardware)"
    echo -e "  ${CYAN}3${NC}) Launch TKG Installer (TUI)"
    echo -e "  ${CYAN}4${NC}) Browse Patch Collection"
    echo -e "  ${CYAN}5${NC}) Standard Kernel Compilation"
    echo -e "  ${CYAN}6${NC}) Kernel Configuration"
    echo -e "  ${CYAN}7${NC}) Fetch Latest Patches"
    echo -e "  ${CYAN}8${NC}) Help & Documentation"
    echo -e "  ${CYAN}q${NC}) Quit"
    echo ""
    read -p "Enter choice: " choice
    case "$choice" in
        1) build_catgirl ;;
        2) build_t2linux ;;
        3) launch_tkg ;;
        4) list_patches ;;
        5) bash scripts/compile.sh ;;
        6) bash scripts/config.sh ;;
        7) bash scripts/fetch.sh ;;
        8) show_usage ;;
        q|Q) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}
# Main entry point
main(){
    cd "$SCRIPT_DIR"
    case "${1:-}" in
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
        *) echo -e "${RED}Unknown command: $1${NC}\n"; show_usage; exit 1 ;;
    esac
}
# Run main function
main "$@"
