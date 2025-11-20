# Quick Start Guide

## 5-Minute Setup

### 1. Clone Repository

```bash
git clone https://github.com/Ven0m0/Linux-Kernel-Patches.git
cd Linux-Kernel-Patches
```

### 2. Choose Your Build Method

#### Option A: Catgirl Edition (Optimized Kernel - Arch Only)

```bash
# Install dependencies
sudo pacman -S base-devel clang lld llvm

# Build
./kernel-builder catgirl

# Install
sudo pacman -U build/catgirl-edition/linux-catgirl-*.pkg.tar.zst
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Best for:** Desktop users wanting maximum performance

#### Option B: TKG Installer (Any Package)

```bash
# Install fzf for TUI
sudo pacman -S fzf  # or: sudo apt install fzf

# Launch TUI
./kernel-builder tkg

# Or build directly
./kernel-builder tkg linux
```

**Best for:** Users wanting customizable builds

#### Option C: Traditional Patches

```bash
# Fetch patches
./kernel-builder fetch

# View available patches
./kernel-builder patches 6.17

# Apply manually to your kernel source
cd /path/to/linux-source
patch -p1 < /path/to/Linux-Kernel-Patches/6.17/some-patch.patch
```

**Best for:** Advanced users, custom builds

## Common Tasks

### Build Optimized Desktop Kernel

```bash
./kernel-builder catgirl
# Select BORE scheduler when prompted
# Enable -O3 optimization
# Keep modprobed-db enabled
```

### Build Gaming-Optimized System

```bash
# Build kernel
./kernel-builder tkg linux

# Build Mesa for graphics
./kernel-builder tkg mesa

# Build Proton for Steam
./kernel-builder tkg proton
```

### Update Patches

```bash
./kernel-builder fetch
```

### Browse Patch Collection

```bash
./kernel-builder list
```

## Recommendations by Use Case

### Desktop Gaming
1. Catgirl Edition with BORE scheduler
2. Mesa-TKG for graphics
3. Proton-TKG for Steam games

### Workstation
1. Catgirl Edition with BORE or EEVDF
2. -O3 optimization
3. Enable modprobed-db

### Server
1. Traditional patches (CachyOS, Clear Linux)
2. EEVDF scheduler
3. No aggressive optimizations

### Low-End Hardware
1. Catgirl Edition with BMQ scheduler
2. Enable modprobed-db (smaller kernel)
3. Disable LTO (faster build)

## Next Steps

- Read the [BUILD_GUIDE.md](BUILD_GUIDE.md) for detailed instructions
- Check [../build/catgirl-edition/README.md](../build/catgirl-edition/README.md) for optimization details
- Visit [Frogging-Family](https://github.com/Frogging-Family) for TKG documentation

## Troubleshooting

**Build fails?**
```bash
# Check dependencies
./kernel-builder help
```

**Kernel doesn't boot?**
- Boot into old kernel from GRUB
- Rebuild with fewer optimizations
- Check `dmesg` for errors

**TKG installer not working?**
```bash
# Reinstall
./scripts/install-tkg.sh
```

## Need Help?

- Open an issue on GitHub
- Check docs/ directory
- Read kernel documentation at kernel.org
