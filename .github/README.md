# Linux Kernel Builder Suite

A comprehensive Linux kernel build system combining:
- **Curated Patch Collection**: Organized patches from CachyOS, XanMod, Clear Linux, and more
- **Catgirl Edition**: Aggressive performance optimizations with multiple scheduler options
- **TKG Integration**: Frogging-Family package management for linux-tkg, nvidia-tkg, mesa-tkg, wine-tkg, and proton-tkg

This unified repository provides everything needed for building highly optimized custom Linux kernels with extensive customization options.

## Repository Structure

```
.
├── 6.12/                       # Patches for Linux kernel 6.12
├── 6.15/                       # Patches for Linux kernel 6.15
├── 6.16/                       # Patches for Linux kernel 6.16
├── 6.17/                       # Patches for Linux kernel 6.17
│   └── catgirl-edition/       # Catgirl edition patches
├── 6.18/                       # Patches for Linux kernel 6.18
├── build/                      # Build system directory
│   ├── catgirl-edition/       # Catgirl Edition PKGBUILD and configs
│   │   ├── PKGBUILD           # Arch Linux package build script
│   │   ├── config             # Kernel configuration
│   │   ├── patches/           # Catgirl-specific patches
│   │   └── README.md          # Catgirl Edition documentation
│   ├── configs/               # Build configurations
│   └── templates/             # Build templates
├── scripts/                    # Build and configuration scripts
│   ├── cachy/                 # CachyOS-specific scripts
│   ├── utils/                 # Utility scripts
│   ├── compile.sh             # Kernel compilation script
│   ├── config.sh              # Kernel configuration script
│   ├── fetch.sh               # Patch fetching script
│   ├── trim.sh                # Patch trimming/processing script
│   ├── tkg-installer          # TKG package installer (TUI)
│   └── install-tkg.sh         # TKG installer setup script
├── docs/                       # Documentation and patch lists
└── kernel-builder              # Main unified build interface
```

## Quick Start

### Unified Build Interface

Use the main `kernel-builder` script for all build operations:

```bash
# Interactive mode - shows menu with all options
./kernel-builder

# Build Catgirl Edition kernel (optimized, multiple schedulers)
./kernel-builder catgirl

# Launch TKG installer TUI for Frogging-Family packages
./kernel-builder tkg

# Browse available patches by version
./kernel-builder patches 6.17

# Fetch latest patches from upstream sources
./kernel-builder fetch

# Standard kernel compilation
./kernel-builder compile

# Show help and available commands
./kernel-builder help
```

### Building Catgirl Edition Kernel

The Catgirl Edition provides aggressive performance optimizations:

```bash
# Build with interactive customization
./kernel-builder catgirl

# Or directly with makepkg
cd build/catgirl-edition
makepkg -scf --cleanbuild --skipchecksums
```

**Key Features:**
- Multiple CPU schedulers: BORE (recommended), EEVDF, BMQ, RT
- Clang LTO and -O3 optimizations
- TCP BBRv3 congestion control
- Modprobed-db support for minimal kernel size
- Clear Linux and CachyOS patchsets

### Using TKG Installer

Build and manage Frogging-Family packages:

```bash
# Interactive TUI mode
./kernel-builder tkg

# Direct package installation
./scripts/tkg-installer linux     # Linux-TKG kernel
./scripts/tkg-installer nvidia    # NVIDIA-TKG drivers
./scripts/tkg-installer mesa      # Mesa-TKG graphics
./scripts/tkg-installer wine      # Wine-TKG
./scripts/tkg-installer proton    # Proton-TKG

# Edit package configuration
./scripts/tkg-installer linux config
```

### Traditional Patch Application

For manual patch application:

```bash
# Fetch latest patches
./scripts/fetch.sh

# Apply patches to kernel source
cd /path/to/linux-source
patch -p1 < /path/to/patch-file.patch

# Or use git apply
git apply /path/to/patch-file.patch
```

### Building with CachyOS Patches

```bash
./scripts/cachy/cachy.sh
./scripts/compile.sh
```

## Build Profiles

### Catgirl Edition (Aggressive Optimizations)

A highly optimized kernel build system with the following features:

**Performance Optimizations:**
- **Guess unwinder**: Zero overhead alternative to ORC/frame pointer
- **CPU schedulers**: BORE (best for desktop), EEVDF (stock), BMQ (minimal), RT (realtime)
- **TCP BBRv3**: Google's advanced congestion control protocol
- **-O3 optimization**: Maximum compiler optimization level
- **Clang LTO**: Link-time optimization for better performance
- **-march=native**: CPU-specific optimizations

**Size Reductions:**
- Remove BUG() calls, coredump support, and tracing infrastructure
- Disable module decompression in kernel
- Remove 16/32-bit application support (optional)
- No printk() support to reduce kernel size

**Configurability:**
- Fine-grained kernel tickrates (default: 1000Hz)
- Multiple preemption levels (rt, full, lazy, voluntary, none)
- Modprobed-db integration for minimal module selection
- Per-feature toggles in PKGBUILD

See `build/catgirl-edition/README.md` for detailed documentation.

### TKG Packages (Frogging-Family)

Customizable source-based packages from the Frogging-Family:

- **linux-tkg**: Highly customizable kernel builds
- **nvidia-tkg**: Custom NVIDIA driver builds
- **mesa-tkg**: Optimized Mesa graphics drivers
- **wine-tkg**: Enhanced Wine compatibility layer
- **proton-tkg**: Optimized Proton for Steam gaming

Each package includes extensive customization options via `customization.cfg` files.

### Standard Patch Collection

#### Performance Patches
- **CachyOS patches**: Performance optimizations and scheduling improvements
- **Sunlight Linux patches**: System call optimizations and I/O improvements
- **Zen patches**: Desktop responsiveness and latency reduction
- **Clear Linux patches**: Intel-optimized performance improvements

#### Hardware Support
- **Mesa patches**: GPU driver improvements
- **Raspberry Pi patches**: ARM-specific optimizations

#### Memory Management
- **zblock allocator**: Compressed memory block allocation
- **PTE batching**: Page table entry batching for performance
- **ZRAM improvements**: Enhanced swap compression

#### Filesystem Patches
- **F2FS patches**: Flash-friendly filesystem optimizations
- **XFS fixes**: XFS filesystem bug fixes and improvements

## Patch Sources

This repository aggregates patches from the following upstream sources:

### Main Sources
- [CachyOS kernel-patches](https://github.com/CachyOS/kernel-patches) - Performance and scheduling improvements
- [linux-catgirl-edition](https://github.com/Ven0m0/linux-catgirl-edition) - Aggressive optimization build system
- [Frogging-Family linux-tkg](https://github.com/Frogging-Family/linux-tkg) - Customizable TKG packages
- [tkginstaller](https://github.com/damachine/tkginstaller) - TKG package management TUI
- [sirlucjan kernel-patches](https://github.com/sirlucjan/kernel-patches) - Community patches
- [XanMod linux-patches](https://gitlab.com/xanmod/linux-patches) - Performance-focused patches

### Additional Sources
- [Clear Linux kernel](https://github.com/clearlinux-pkgs/linux) - Intel optimizations
- [CachyMod](https://github.com/marioroy/cachymod) - CachyOS modifications
- [Sunlight Linux](https://github.com/sunlightlinux/linux-sunlight) - System call optimizations
- [openSUSE kernel-source](https://github.com/openSUSE/kernel-source) - Enterprise patches
- [build-ubuntu-kernel](https://github.com/arvin-foroutan/build-ubuntu-kernel) - Ubuntu kernel builds
- [zram-ir](https://github.com/firelzrd/zram-ir) - ZRAM improvements

## Tools and Utilities

### Main Build Tools
- **kernel-builder**: Unified build interface for all kernel build operations
- **TKG Installer**: Interactive TUI for Frogging-Family package management
- **PKGBUILD System**: Arch Linux package build system for catgirl edition

### Recommended External Tools
- [patchutils](https://github.com/twaugh/patchutils) - Collection of programs for manipulating patch files
- [modprobed-db](https://github.com/graysky2/modprobed-db) - Track kernel modules for minimal builds
- [fzf](https://github.com/junegunn/fzf) - Required for TKG installer TUI mode

### Included Utilities
- **sort-modprobed-dbs**: Sort and merge modprobed-db files
- **zramswap**: ZRAM swap configuration utility
- **compile.sh**: Standard kernel compilation script
- **config.sh**: Kernel configuration helper
- **fetch.sh**: Automated patch fetching
- **trim.sh**: Patch processing and trimming

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing patches and improvements.

## License

See [LICENSE](LICENSE) for details.

## Merged Repositories

This repository combines functionality from:

1. **Original Linux-Kernel-Patches**: Curated patch collection organized by kernel version
2. **linux-catgirl-edition** ([Ven0m0/linux-catgirl-edition](https://github.com/Ven0m0/linux-catgirl-edition)): Aggressive optimization build system with PKGBUILD
3. **tkginstaller** ([damachine/tkginstaller](https://github.com/damachine/tkginstaller)): TKG package management and TUI

The merge provides a unified interface for all kernel building needs, from patch management to optimized builds.

## Disclaimer

**Important:** These patches and build configurations are provided as-is. Always test in a safe environment before applying to production systems. Kernel modifications can potentially cause system instability.

**Catgirl Edition Warning:** The aggressive optimizations in catgirl edition (especially memory zero-init disabling, stack protections removal) may introduce security risks. Only use these optimizations if you understand the tradeoffs.

**TKG Packages:** Frogging-Family TKG packages are customizable and may require specific hardware or software configurations. Review customization.cfg files before building.

## Support

For issues or questions:
- **General issues**: Open an issue in this repository
- **Catgirl Edition**: See [build/catgirl-edition/README.md](build/catgirl-edition/README.md)
- **TKG packages**: Visit [Frogging-Family repositories](https://github.com/Frogging-Family)
- **Patches**: Check upstream patch sources for specific documentation
- **Kernel documentation**: Consult the [Linux kernel documentation](https://www.kernel.org/doc/)

## Version Compatibility

Each directory (6.12, 6.15, etc.) contains patches specifically tested for that kernel version. Patches may not apply cleanly to other kernel versions without modification.

**Catgirl Edition**: Currently configured for kernel 6.17.x (see build/catgirl-edition/PKGBUILD)
**TKG Packages**: Support varies by package; check Frogging-Family repositories for details
