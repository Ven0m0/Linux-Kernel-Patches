# Linux Kernel Builder Suite - Build Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Build Methods](#build-methods)
4. [Catgirl Edition Build](#catgirl-edition-build)
5. [TKG Package Build](#tkg-package-build)
6. [Traditional Patch Application](#traditional-patch-application)
7. [Optimization Guide](#optimization-guide)
8. [Troubleshooting](#troubleshooting)

## Introduction

This guide covers all build methods available in the Linux Kernel Builder Suite, including:
- Catgirl Edition optimized kernel builds
- TKG (Frogging-Family) package management
- Traditional patch application and compilation

## Prerequisites

### Required Packages

**For all builds:**
```bash
# Arch Linux / Manjaro
sudo pacman -S base-devel git wget curl

# Ubuntu / Debian
sudo apt install build-essential git wget curl libncurses-dev flex bison \
                 libssl-dev libelf-dev bc
```

**For Catgirl Edition builds (Arch-based only):**
```bash
sudo pacman -S base-devel clang lld llvm
```

**For TKG Installer:**
```bash
# fzf is required for TUI mode
sudo pacman -S fzf  # Arch
sudo apt install fzf  # Ubuntu/Debian
```

### Optional but Recommended

**modprobed-db** - for minimal kernel builds:
```bash
# Install from AUR (Arch)
yay -S modprobed-db

# Usage
sudo modprobed-db store  # Run this regularly to track modules
```

## Build Methods

### Quick Reference

| Method | Best For | Distro | Complexity |
|--------|----------|--------|------------|
| Catgirl Edition | Desktop performance | Arch-based | Medium |
| TKG Packages | Customization | Any | Low-Medium |
| Traditional | Any Linux | Any | High |

## Catgirl Edition Build

### Overview

Catgirl Edition provides aggressive performance optimizations with minimal overhead.

### Step 1: Review Configuration

Open the PKGBUILD to review and customize:

```bash
cd build/catgirl-edition
nano PKGBUILD  # or your preferred editor
```

### Step 2: Key Configuration Options

#### CPU Scheduler Selection

```bash
# In PKGBUILD, set _cpusched variable:
: "${_cpusched:=bore}"    # Desktop - best interactivity under load
: "${_cpusched:=eevdf}"   # Server - fully fair scheduler
: "${_cpusched:=bmq}"     # Minimal - smaller code size
: "${_cpusched:=rt}"      # Real-time - predictable latency
: "${_cpusched:=rt-bore}" # RT Desktop - real-time with BORE
```

#### Patchset Selection

```bash
# CachyOS patchset (recommended)
: "${_import_cachyos_patchset:=yes}"

# Clear Linux patchset (Intel optimizations)
: "${_import_clear_patchset:=yes}"

# XanMod patchset (performance)
: "${_import_xanmod_patchset:=yes}"
```

#### Optimization Levels

```bash
# Use modprobed-db for minimal builds
: "${_localmodcfg:=yes}"
: "${_localmodcfg_path:="$HOME/.config/modprobed.db"}"

# Configure kernel interactively
: "${_makenconfig:=yes}"
```

### Step 3: Build

Using the unified interface:

```bash
./kernel-builder catgirl
```

Or directly:

```bash
cd build/catgirl-edition
makepkg -scf --cleanbuild --skipchecksums
```

### Step 4: Install

```bash
# Install the built package
sudo pacman -U linux-catgirl-*.pkg.tar.zst

# Update bootloader
sudo grub-mkconfig -o /boot/grub/grub.cfg  # GRUB
# or
sudo bootctl update  # systemd-boot
```

### Build Time

Expect 30-90 minutes depending on:
- CPU cores (use `-j$(nproc)` for parallel builds)
- Using modprobed-db (can reduce time by 50%)
- Selected optimizations (LTO increases build time)

## TKG Package Build

### Overview

TKG packages provide customizable builds for kernels, drivers, and gaming software.

### Interactive TUI Mode

```bash
# Launch the TUI
./kernel-builder tkg

# Or directly
./scripts/tkg-installer
```

The TUI provides:
- Package selection (linux, nvidia, mesa, wine, proton)
- Configuration file editing
- Preview and comparison tools

### Direct Command Mode

```bash
# Build packages directly
./scripts/tkg-installer linux    # Linux-TKG kernel
./scripts/tkg-installer nvidia   # NVIDIA-TKG drivers
./scripts/tkg-installer mesa     # Mesa-TKG graphics
./scripts/tkg-installer wine     # Wine-TKG
./scripts/tkg-installer proton   # Proton-TKG

# Edit configuration before building
./scripts/tkg-installer linux config
```

### Customization Files

TKG packages use `customization.cfg` files:

```bash
# Location (created automatically)
~/.config/frogminer/linux-tkg/customization.cfg
~/.config/frogminer/nvidia-all/customization.cfg
# etc.
```

Edit these files to customize builds before running the installer.

### Common TKG Options

For **linux-tkg**:
- Scheduler selection (PDS, BMQ, CacULE, etc.)
- Kernel version selection
- Custom patches
- CPU optimizations

For **nvidia-tkg**:
- Driver version
- DRM support
- Custom patches

## Traditional Patch Application

### Step 1: Fetch Patches

```bash
# Fetch latest patches from all sources
./kernel-builder fetch

# Or use the script directly
./scripts/fetch.sh
```

### Step 2: Browse Patches

```bash
# List all available patches
./kernel-builder list

# Show patches for specific version
./kernel-builder patches 6.17
```

### Step 3: Download Kernel Source

```bash
# Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.tar.xz
tar -xf linux-6.17.tar.xz
cd linux-6.17
```

### Step 4: Apply Patches

```bash
# Apply patches with patch command
patch -p1 < /path/to/Linux-Kernel-Patches/6.17/some-patch.patch

# Or use git apply
git apply /path/to/Linux-Kernel-Patches/6.17/some-patch.patch

# Apply multiple patches
for patch in /path/to/Linux-Kernel-Patches/6.17/*.patch; do
    patch -p1 < "$patch"
done
```

### Step 5: Configure Kernel

```bash
# Copy current config
cp /boot/config-$(uname -r) .config

# Update config
make olddefconfig

# Or configure manually
make menuconfig  # ncurses interface
make nconfig     # newer ncurses interface
```

### Step 6: Compile

```bash
# Compile kernel (use all cores)
make -j$(nproc)

# Compile modules
make modules -j$(nproc)

# Install modules
sudo make modules_install

# Install kernel
sudo make install
```

### Step 7: Update Bootloader

```bash
# GRUB
sudo grub-mkconfig -o /boot/grub/grub.cfg

# systemd-boot
sudo bootctl update
```

## Optimization Guide

### CPU-Specific Optimizations

#### -march=native

```bash
# In PKGBUILD or kernel config
# Optimizes for your specific CPU
CFLAGS="-march=native"
```

**Benefits:** Better instruction usage, cache optimization
**Drawback:** Binary won't work on different CPUs

#### Compiler Choice

```bash
# GCC (default, good compatibility)
make CC=gcc

# Clang (better optimizations, LTO support)
make CC=clang
```

### Scheduler Comparison

| Scheduler | Best For | Latency | Throughput | Fairness |
|-----------|----------|---------|------------|----------|
| BORE | Desktop | Excellent | Good | Low |
| EEVDF | Server | Good | Excellent | High |
| BMQ | Low-end | Good | Good | Medium |
| RT | Real-time | Predictable | Lower | Medium |

### Memory Optimizations

```bash
# In kernel config or PKGBUILD
CONFIG_ZRAM=y              # Compressed swap
CONFIG_ZSWAP=y             # Compressed cache
CONFIG_LRU_GEN=y           # Better page reclaim
CONFIG_TRANSPARENT_HUGEPAGE=y  # Large pages
```

### I/O Schedulers

```bash
# Available schedulers:
# - mq-deadline: Low latency, good for SSDs
# - kyber: Dynamic queue management
# - bfq: Best for desktop, fair I/O
# - none: No scheduling (NVMe only)
```

## Troubleshooting

### Build Fails with Missing Dependencies

```bash
# Arch-based
sudo pacman -S --needed base-devel

# Debian-based
sudo apt install build-essential kernel-package
```

### Catgirl Edition PKGBUILD Errors

```bash
# Clear build directory
cd build/catgirl-edition
rm -rf src pkg *.tar.* *.patch

# Rebuild
makepkg -scf --cleanbuild --skipchecksums
```

### Kernel Doesn't Boot

1. Boot into previous kernel from GRUB menu
2. Check kernel logs:
   ```bash
   journalctl -k -b -1  # Previous boot
   dmesg                # Current boot
   ```
3. Rebuild with fewer optimizations
4. Disable aggressive options (stack protector, init_on_free, etc.)

### Module Loading Issues

```bash
# Rebuild modules
sudo make modules_install

# Regenerate initramfs
sudo mkinitcpio -P  # Arch
sudo update-initramfs -u  # Debian/Ubuntu
```

### TKG Installer Issues

```bash
# Clean TKG cache
rm -rf ~/.cache/tkginstaller

# Reinstall TKG installer
./scripts/install-tkg.sh

# Check fzf is installed
which fzf
```

### Performance Issues After Build

1. Check CPU governor:
   ```bash
   cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
   # Should be "performance" for desktop
   ```

2. Check scheduler:
   ```bash
   cat /sys/kernel/debug/sched/features
   ```

3. Check kernel parameters:
   ```bash
   cat /proc/cmdline
   ```

## Best Practices

1. **Always backup** your current working kernel
2. **Test in VM** first for aggressive optimizations
3. **Use modprobed-db** for faster builds
4. **Keep kernel config** for future reference
5. **Document changes** you make to PKGBUILD or configs
6. **Monitor system** after kernel changes

## Performance Testing

### Benchmarking

```bash
# CPU performance
sysbench cpu --cpu-max-prime=20000 run

# I/O performance
fio --name=randwrite --rw=randwrite --size=1G --bs=4k

# Gaming performance
mangohud yourfavorite-game
```

### Monitoring

```bash
# CPU scheduler stats
cat /proc/sched_debug

# Memory stats
cat /proc/meminfo

# I/O stats
iostat -x 1
```

## Additional Resources

- [Catgirl Edition README](../build/catgirl-edition/README.md)
- [Arch Wiki - Kernel Compilation](https://wiki.archlinux.org/title/Kernel/Traditional_compilation)
- [Frogging-Family GitHub](https://github.com/Frogging-Family)
- [Linux Kernel Documentation](https://www.kernel.org/doc/)
