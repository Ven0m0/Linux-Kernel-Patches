# Linux Kernel Patches

A curated collection of Linux kernel patches from various sources, organized by kernel version. This repository provides patches for performance optimization, hardware support, and feature enhancements.

## Repository Structure

```
.
├── 6.12/               # Patches for Linux kernel 6.12
├── 6.15/               # Patches for Linux kernel 6.15
├── 6.16/               # Patches for Linux kernel 6.16
├── 6.17/               # Patches for Linux kernel 6.17
├── 6.18/               # Patches for Linux kernel 6.18
├── scripts/            # Build and configuration scripts
│   ├── cachy/         # CachyOS-specific scripts
│   ├── utils/         # Utility scripts
│   ├── compile.sh     # Kernel compilation script
│   ├── config.sh      # Kernel configuration script
│   ├── fetch.sh       # Patch fetching script
│   └── trim.sh        # Patch trimming/processing script
└── docs/              # Documentation and patch lists
```

## Quick Start

### Fetching Patches

Use the fetch script to download patches for a specific kernel version:

```bash
./scripts/fetch.sh
```

### Applying Patches

1. Navigate to your kernel source directory
2. Apply patches using `patch` or `git apply`:

```bash
cd /path/to/linux-source
patch -p1 < /path/to/patch-file.patch
```

### Building with CachyOS Patches

```bash
./scripts/cachy/cachy.sh
./scripts/compile.sh
```

## Patch Categories

### Performance Patches
- **CachyOS patches**: Performance optimizations and scheduling improvements
- **Sunlight Linux patches**: System call optimizations and I/O improvements
- **Zen patches**: Desktop responsiveness and latency reduction

### Hardware Support
- **Mesa patches**: GPU driver improvements
- **Raspberry Pi patches**: ARM-specific optimizations

### Memory Management
- **zblock allocator**: Compressed memory block allocation
- **PTE batching**: Page table entry batching for performance
- **ZRAM improvements**: Enhanced swap compression

### Filesystem Patches
- **F2FS patches**: Flash-friendly filesystem optimizations
- **XFS fixes**: XFS filesystem bug fixes and improvements

## Patch Sources

This repository aggregates patches from the following upstream sources:

### Main Sources
- [CachyOS kernel-patches](https://github.com/CachyOS/kernel-patches)
- [sirlucjan kernel-patches](https://github.com/sirlucjan/kernel-patches)
- [XanMod linux-patches](https://gitlab.com/xanmod/linux-patches)
- [Frogging-Family linux-tkg](https://github.com/Frogging-Family/linux-tkg)

### Additional Sources
- [Clear Linux kernel](https://github.com/clearlinux-pkgs/linux)
- [CachyMod](https://github.com/marioroy/cachymod)
- [Sunlight Linux](https://github.com/sunlightlinux/linux-sunlight)
- [openSUSE kernel-source](https://github.com/openSUSE/kernel-source)
- [build-ubuntu-kernel](https://github.com/arvin-foroutan/build-ubuntu-kernel)
- [zram-ir](https://github.com/firelzrd/zram-ir)

## Tools

### Recommended Tools
- [patchutils](https://github.com/twaugh/patchutils) - Collection of programs for manipulating patch files

### Included Utilities
- **sort-modprobed-dbs**: Sort and merge modprobed-db files
- **zramswap**: ZRAM swap configuration utility

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing patches and improvements.

## License

See [LICENSE](LICENSE) for details.

## Disclaimer

These patches are provided as-is. Always test patches in a safe environment before applying them to production systems. Kernel modifications can potentially cause system instability.

## Support

For issues or questions:
- Open an issue in this repository
- Check the upstream patch sources for specific patch documentation
- Consult the Linux kernel documentation

## Version Compatibility

Each directory (6.12, 6.15, etc.) contains patches specifically tested for that kernel version. Patches may not apply cleanly to other kernel versions without modification.
