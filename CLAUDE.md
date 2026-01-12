# CLAUDE.md - AI Assistant Guide for Linux Kernel Builder Suite

**Version**: 1.0.0
**Last Updated**: 2025-12-04
**Repository**: Linux-Kernel-Patches (Unified Build Suite)

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Codebase Structure](#codebase-structure)
3. [Development Workflows](#development-workflows)
4. [Key Conventions](#key-conventions)
5. [Build Systems](#build-systems)
6. [Common Tasks](#common-tasks)
7. [Important Files](#important-files)
8. [Testing and Validation](#testing-and-validation)
9. [Git and CI/CD](#git-and-cicd)
10. [Troubleshooting Guide](#troubleshooting-guide)

---

## Repository Overview

### Purpose

This is a **unified Linux kernel build system** that combines four major components:

1. **Curated Patch Collection**: Organized patches from CachyOS, XanMod, Clear Linux, and other upstream sources
2. **Catgirl Edition**: Aggressive performance-optimized kernel build system with PKGBUILD
3. **CachyMod**: Interactive CachyOS kernel builder with scheduler variants and TUI configuration
4. **TKG Integration**: Frogging-Family package management for linux-tkg, nvidia-tkg, mesa-tkg, wine-tkg, and proton-tkg

### Primary Use Cases

- Building highly optimized custom Linux kernels
- Managing and applying kernel patches
- Building TKG packages for gaming and graphics optimization
- Desktop performance tuning
- Server kernel customization

### Target Users

- Kernel developers and enthusiasts
- Performance-focused desktop users
- Gaming enthusiasts (Steam, Proton, Wine)
- System administrators building custom kernels
- Advanced Linux users on Arch-based distributions

---

## Codebase Structure

```
Linux-Kernel-Patches/
├── 6.12/                       # Kernel 6.12 patches
├── 6.15/                       # Kernel 6.15 patches
├── 6.16/                       # Kernel 6.16 patches
├── 6.17/                       # Kernel 6.17 patches
│   ├── catgirl-edition/       # Catgirl-specific patches for 6.17
│   └── patches.txt            # Patch inventory
├── 6.18/                       # Kernel 6.18 patches (latest)
│   └── mesa/                  # Mesa-specific patches
├── build/                      # Build system directory
│   ├── catgirl-edition/       # Catgirl Edition PKGBUILD system
│   │   ├── PKGBUILD           # Arch package build script (PRIMARY)
│   │   ├── config             # Optimized kernel configuration
│   │   ├── patches/           # Build-time patches
│   │   └── README.md          # Catgirl documentation
│   ├── cachymod/              # CachyMod interactive build system
│   │   ├── confmod.sh         # Interactive configuration utility
│   │   ├── uninstall.sh       # Kernel removal tool
│   │   ├── defconfigs/        # Pre-made configurations
│   │   ├── sample/            # Custom modification templates
│   │   └── 6.18/              # Kernel 6.18 build directory
│   │       ├── PKGBUILD       # CachyMod PKGBUILD
│   │       ├── build.sh       # Build script
│   │       ├── config.sh      # Configuration script
│   │       ├── config         # Base kernel config
│   │       └── *.patch        # CachyMod patches
│   ├── configs/               # Additional build configurations
│   └── templates/             # Build templates
├── scripts/                    # Automation scripts
│   ├── cachy/                 # CachyOS-specific scripts
│   │   └── cachy.sh           # CachyOS patch application
│   ├── utils/                 # Utility scripts
│   │   ├── sort-modprobed-dbs # Sort/merge modprobed-db files
│   │   └── zramswap           # ZRAM swap configuration
│   ├── compile.sh             # Standard kernel compilation
│   ├── config.sh              # Kernel configuration helper
│   ├── fetch.sh               # Automated patch fetching
│   ├── trim.sh                # Patch processing
│   ├── tkg-installer          # TKG package installer (TUI)
│   └── install-tkg.sh         # TKG installer setup
├── docs/                       # Documentation
│   ├── BUILD_GUIDE.md         # Comprehensive build guide
│   ├── QUICKSTART.md          # Quick start guide
│   └── MERGE_SUMMARY.md       # Repository merge history
├── .github/                    # GitHub workflows
│   ├── workflows/
│   │   └── fetch.yml          # Automated patch fetching
│   └── dependabot.yml         # Dependency management
├── kernel-builder.sh          # **MAIN UNIFIED INTERFACE**
├── autofdo.sh                 # Unified AutoFDO profiling and optimization
├── docker-build.sh            # Unified Docker-based kernel builds (all architectures)
├── README.md                  # Main documentation
├── LICENSE                    # Repository license
└── .gitignore                 # Git ignore patterns
```

### Directory Purposes

#### Kernel Version Directories (6.12 - 6.18)

- **Purpose**: Store patches specific to each kernel version
- **Structure**: Patches are organized by source and functionality
- **Naming**: Descriptive names indicating patch purpose
- **Special**: `6.17/catgirl-edition/` contains Clear Linux patchset for Catgirl Edition

#### build/catgirl-edition/

- **Primary File**: `PKGBUILD` - Controls entire build process
- **Purpose**: Arch Linux package build system for optimized kernels
- **Configuration**: Extensive customization options via PKGBUILD variables
- **Output**: `.pkg.tar.zst` installable packages

#### build/cachymod/

- **Primary Files**: `confmod.sh` (configuration), `build.sh` (compilation)
- **Purpose**: Interactive CachyOS kernel builder with TUI
- **Configuration**: Uses `gum` for interactive dialogs, stores configs in `~/.config/cachymod/`
- **Variants**: Supports multiple scheduler variants (EEVDF, BORE, BMQ, PDS, RT)
- **Output**: `.pkg.tar.zst` installable packages (linux-cachymod-*)

#### scripts/

- **Purpose**: Automation scripts for various build workflows
- **Categories**:
  - Build: `compile.sh`, `config.sh`
  - Patch management: `fetch.sh`, `trim.sh`
  - TKG: `tkg-installer`, `install-tkg.sh`
  - Utilities: `cachy/`, `utils/`

---

## Development Workflows

### 1. Unified Build Interface (Recommended)

The `kernel-builder.sh` script is the **primary entry point** for all operations:

```bash
# Interactive mode
./kernel-builder.sh

# Build Catgirl Edition
./kernel-builder.sh catgirl

# Build CachyMod kernels
./kernel-builder.sh cachymod

# Launch TKG installer
./kernel-builder.sh tkg

# Manage patches
./kernel-builder.sh patches [version]

# List all patches
./kernel-builder.sh list

# List installed kernels
./kernel-builder.sh kernels

# Fetch latest patches
./kernel-builder.sh fetch

# Show help
./kernel-builder.sh help
```

### 2. Catgirl Edition Workflow

**File**: `build/catgirl-edition/PKGBUILD`

```bash
# Step 1: Review and customize PKGBUILD
cd build/catgirl-edition
$EDITOR PKGBUILD  # Review optimization options

# Step 2: Key configuration variables to customize
# _cpusched:       bore|eevdf|bmq|rt|rt-bore
# _import_cachyos_patchset: yes|no
# _import_clear_patchset: yes|no
# _localmodcfg:    yes|no (use modprobed-db)
# _makenconfig:    yes|no (interactive config)

# Step 3: Build
makepkg -scf --cleanbuild --skipchecksums

# Step 4: Install
sudo pacman -U linux-catgirl-*.pkg.tar.zst

# Step 5: Update bootloader
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 3. CachyMod Workflow

**Primary Files**: `build/cachymod/confmod.sh`, `build/cachymod/6.18/build.sh`

```bash
# Step 1: Install dependencies
sudo pacman -S gum  # Required for interactive TUI

# Step 2: Configure new kernel variant
cd build/cachymod/6.18
../confmod.sh

# In confmod.sh:
# - Choose CPU scheduler (EEVDF, BORE, BMQ, PDS, RT)
# - Set build type (none, thin, full LTO)
# - Configure AutoFDO, hugepage, modprobed-db
# - Set kernel suffix (e.g., 618-bore)
# - Choose tick rate (1000, 800, 500, etc.)
# - Configure preemption (full, lazy, voluntary, none)
# - Add extra patches if needed

# Step 3: Build from configuration
./build.sh 618-bore  # Or your config name

# Or via unified interface
cd ../..
./kernel-builder.sh cachymod build 618-bore

# Step 4: List available configurations
./build.sh list
# Or: ./kernel-builder.sh cachymod list

# Step 5: Installation (automatic via build.sh)
# Packages are auto-installed after build completes

# Step 6: Update bootloader
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Step 7: Uninstall kernels (if needed)
cd build/cachymod
./uninstall.sh
# Or: ./kernel-builder.sh cachymod uninstall
```

**Key Features**:
- Interactive configuration with `gum` TUI
- Pre-made configs in `defconfigs/` directory
- Support for custom modifications via `custom.sh`
- Multiple kernel variants can coexist
- AutoFDO profile-guided optimization support

### 4. TKG Package Workflow

```bash
# Interactive TUI mode (requires fzf)
./scripts/tkg-installer

# Or via unified interface
./kernel-builder.sh tkg

# Direct package builds
./scripts/tkg-installer linux     # Linux-TKG kernel
./scripts/tkg-installer nvidia    # NVIDIA-TKG drivers
./scripts/tkg-installer mesa      # Mesa-TKG graphics
./scripts/tkg-installer wine      # Wine-TKG
./scripts/tkg-installer proton    # Proton-TKG

# Edit configuration before building
./scripts/tkg-installer linux config
```

### 5. Traditional Patch Application Workflow

```bash
# Step 1: Fetch latest patches
./scripts/fetch.sh

# Step 2: Download kernel source
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.tar.xz
tar -xf linux-6.18.tar.xz
cd linux-6.18

# Step 3: Apply patches
patch -p1 < /path/to/Linux-Kernel-Patches/6.18/some-patch.patch

# Or apply multiple patches
for patch in /path/to/Linux-Kernel-Patches/6.18/*.patch; do
    patch -p1 < "$patch"
done

# Step 4: Configure
cp /boot/config-$(uname -r) .config
make olddefconfig

# Step 5: Compile
make -j$(nproc)
sudo make modules_install
sudo make install
```

### 6. Patch Fetching Workflow

**Script**: `scripts/fetch.sh`

```bash
# Automatic fetch (uses parallel downloads)
./scripts/fetch.sh

# Or via unified interface
./kernel-builder.sh fetch
```

**How it works**:
- Reads patch list URLs from script
- Downloads patches in parallel (default: 4 concurrent)
- Stores in appropriate version directories
- Used by GitHub Actions for automated updates

---

## Key Conventions

### File Naming Conventions

#### Patches

- **Format**: `<description>.patch` or `<commit-hash>.patch`
- **Examples**:
  - `clear-linux-patchset.patch` - Clear Linux patches
  - `9591fdb0611dccdeeeeacb99d89f0098737d209b.patch` - Git commit patch
  - `Allow_larger_pages.patch` - Descriptive feature name

#### Build Artifacts

- **Kernel packages**: `linux-catgirl-*.pkg.tar.zst`
- **Build directories**: `src/`, `pkg/` (git-ignored)
- **Temporary files**: `*.tmp`, `*.bak` (git-ignored)

### Code Style Conventions

#### Shell Scripts

```bash
# Use strict mode
set -euo pipefail
shopt -s nullglob globstar

# Use consistent IFS
IFS=$'\n\t'

# Color definitions (from kernel-builder.sh)
RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' BLD=$'\e[1m'

# Helper functions
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b\n' "${RED}Error:${DEF} $*" >&2; exit 1; }
info(){ printf '%b\n' "${GRN}$*${DEF}"; }
warn(){ printf '%b\n' "${YLW}$*${DEF}"; }
msg(){ printf '%b\n' "${CYN}$*${DEF}"; }
```

#### PKGBUILD Variables

```bash
# Use colon expansion for optional variables
: "${_cpusched:=bore}"              # Default to bore
: "${_import_cachyos_patchset:=yes}" # Default to yes
: "${_localmodcfg:=no}"             # Default to no
```

### Documentation Conventions

- **README.md**: High-level overview, quick start, feature list
- **BUILD_GUIDE.md**: Detailed step-by-step instructions
- **QUICKSTART.md**: Minimal 5-minute setup guide
- **Code comments**: Explain "why", not "what"
- **Inline documentation**: Use markdown code blocks with language hints

### Git Conventions

#### Commit Messages

Follow conventional commits format when possible:

```
feat: Add support for kernel 6.19
fix: Correct patch application order in fetch.sh
docs: Update BUILD_GUIDE with modprobed-db instructions
chore: Update GitHub Actions to latest version
```

#### Branch Strategy

- **main**: Stable releases
- **development branches**: Feature development
- **patch updates**: Automated via GitHub Actions

---

## Build Systems

### 1. Catgirl Edition PKGBUILD System

**Primary File**: `build/catgirl-edition/PKGBUILD`

#### Key Configuration Variables

```bash
# CPU Scheduler Selection
: "${_cpusched:=bore}"              # Options: bore, eevdf, bmq, rt, rt-bore

# Patchset Selection
: "${_import_cachyos_patchset:=yes}" # CachyOS performance patches
: "${_import_clear_patchset:=yes}"   # Clear Linux Intel optimizations
: "${_import_xanmod_patchset:=no}"   # XanMod patches

# Build Optimizations
: "${_use_llvm_lto:=thin}"          # Options: none, thin, full
: "${_optimize:=O3}"                 # Options: O2, O3, Os, Ofast
: "${_march:=native}"                # CPU-specific optimizations

# Size Reductions
: "${_disable_debug:=yes}"           # Remove debug symbols
: "${_disable_numa:=no}"             # Remove NUMA support
: "${_localmodcfg:=no}"              # Use modprobed-db

# Interactive Configuration
: "${_makenconfig:=no}"              # Run nconfig before build
```

#### Optimization Profiles

**Desktop Gaming** (Recommended):
```bash
_cpusched=bore
_import_cachyos_patchset=yes
_use_llvm_lto=thin
_optimize=O3
_march=native
_localmodcfg=yes  # If using modprobed-db
```

**Server**:
```bash
_cpusched=eevdf
_import_cachyos_patchset=yes
_use_llvm_lto=none
_optimize=O2
_march=x86-64-v3
_localmodcfg=no
```

**Low-End Hardware**:
```bash
_cpusched=bmq
_import_cachyos_patchset=yes
_use_llvm_lto=none
_optimize=O2
_localmodcfg=yes
_disable_debug=yes
```

#### Build Process

1. **Source Download**: Downloads kernel from kernel.org
2. **Patch Application**: Applies selected patchsets in order
3. **Configuration**: Generates optimized .config
4. **Compilation**: Uses Clang/LLVM or GCC
5. **Packaging**: Creates installable .pkg.tar.zst

### 2. TKG Installer System

**Primary Script**: `scripts/tkg-installer`

#### Supported Packages

- **linux-tkg**: Customizable kernel builds
- **nvidia-tkg**: NVIDIA driver builds
- **mesa-tkg**: Mesa graphics driver builds
- **wine-tkg**: Wine compatibility layer
- **proton-tkg**: Proton for Steam

#### Configuration Files

Location: `~/.config/frogminer/<package>/customization.cfg`

TKG uses `customization.cfg` files for per-package settings. These are auto-generated on first run and can be edited before building.

#### TUI Mode

Requires `fzf` package. Provides:
- Interactive package selection
- Configuration preview and editing
- Build progress monitoring
- Multi-package build support

### 3. Traditional Build System

Uses standard kernel compilation workflow:

1. Fetch patches: `./scripts/fetch.sh`
2. Download kernel source
3. Apply patches manually
4. Configure: `make menuconfig` or `make nconfig`
5. Compile: `make -j$(nproc)`
6. Install: `sudo make modules_install && sudo make install`

---

## Common Tasks

### Task 1: Building an Optimized Desktop Kernel

```bash
# Step 1: Review catgirl edition options
cd build/catgirl-edition
nano PKGBUILD

# Step 2: Set recommended options
# _cpusched=bore
# _import_cachyos_patchset=yes
# _use_llvm_lto=thin
# _optimize=O3
# _localmodcfg=yes  # If you've been running modprobed-db

# Step 3: Build
makepkg -scf --cleanbuild --skipchecksums

# Step 4: Install
sudo pacman -U linux-catgirl-6.*.pkg.tar.zst

# Step 5: Update bootloader
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Step 6: Reboot into new kernel
sudo reboot
```

### Task 2: Adding a New Patch

```bash
# Step 1: Identify kernel version
KERNEL_VERSION="6.18"

# Step 2: Add patch file
cp /path/to/new-patch.patch ${KERNEL_VERSION}/

# Step 3: (Optional) Update patches.txt
echo "new-patch.patch" >> ${KERNEL_VERSION}/patches.txt

# Step 4: Test patch application
cd /tmp
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VERSION}.tar.xz
tar -xf linux-${KERNEL_VERSION}.tar.xz
cd linux-${KERNEL_VERSION}
patch -p1 --dry-run < /path/to/Linux-Kernel-Patches/${KERNEL_VERSION}/new-patch.patch

# Step 5: Commit
git add ${KERNEL_VERSION}/new-patch.patch
git commit -m "feat: Add new-patch for kernel ${KERNEL_VERSION}"
```

### Task 3: Updating Patches from Upstream

```bash
# Option 1: Use fetch script
./scripts/fetch.sh

# Option 2: Via unified interface
./kernel-builder.sh fetch

# Option 3: Trigger GitHub Action
# Go to Actions tab → Fetch files → Run workflow

# Verify updates
git status
git diff

# Commit updates
git add .
git commit -m "chore: Update patches from upstream sources"
```

### Task 4: Building a Gaming-Optimized System

```bash
# Build optimized kernel
./kernel-builder.sh catgirl
# Select BORE scheduler
# Enable -O3 optimization

# Build Mesa-TKG for graphics
./kernel-builder.sh tkg mesa

# Build Proton-TKG for Steam
./kernel-builder.sh tkg proton

# Install all packages
sudo pacman -U build/catgirl-edition/linux-catgirl-*.pkg.tar.zst
# Mesa and Proton will be in their TKG build directories
```

### Task 5: Testing a Patch Before Applying

```bash
# Download kernel source
cd /tmp
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.tar.xz
tar -xf linux-6.18.tar.xz
cd linux-6.18

# Test patch (dry-run)
patch -p1 --dry-run < /path/to/Linux-Kernel-Patches/6.18/test.patch

# If successful, apply
patch -p1 < /path/to/Linux-Kernel-Patches/6.18/test.patch

# Verify changes
git diff  # If kernel source is git repo
# or
find . -name "*.orig"  # Check backup files
```

### Task 6: Creating a Custom Configuration

```bash
# Start with catgirl edition base
cd build/catgirl-edition

# Enable interactive config
sed -i 's/_makenconfig:=no/_makenconfig:=yes/' PKGBUILD

# Build (will pause at nconfig)
makepkg -scf --cleanbuild --skipchecksums

# In nconfig:
# - Customize as needed
# - Save and exit
# - Build continues automatically

# Save configuration for reuse
cp src/linux-*/. config ../configs/my-custom-config
```

---

## Important Files

### Critical Files (Do Not Modify Without Understanding)

#### build/catgirl-edition/PKGBUILD

- **Purpose**: Controls entire Catgirl Edition build process
- **Warning**: Incorrect modifications can break builds or create unstable kernels
- **Modification**: Always test in a VM first
- **Backup**: Keep a copy before modifications

#### build/catgirl-edition/config

- **Purpose**: Base kernel configuration
- **Size**: 289KB, ~8000 configuration options
- **Warning**: Only modify if you understand kernel configuration
- **Recommendation**: Use `_makenconfig=yes` in PKGBUILD instead

#### kernel-builder.sh

- **Purpose**: Unified interface for all build operations
- **Dependencies**: Various helper functions and scripts
- **Modification**: Test thoroughly before committing
- **Style**: Follows strict bash conventions

### Configuration Files

#### .gitignore

Properly configured to ignore:
- Build artifacts: `src/`, `pkg/`, `*.tar.*`
- Editor files: `.vscode/`, `.idea/`, `*.swp`
- Kernel outputs: `vmlinux*`, `bzImage*`
- Temporary files: `*.tmp`, `*.bak`
- Preserves: `build/catgirl-edition/` core files

#### .github/workflows/fetch.yml

- **Purpose**: Automated patch fetching
- **Trigger**: Manual workflow_dispatch (scheduled cron commented out)
- **Actions**: Runs `scripts/fetch.sh`
- **Concurrency**: Cancels in-progress runs on new trigger

### Documentation Files

#### Priority Order

1. **README.md**: Start here for overview
2. **docs/QUICKSTART.md**: 5-minute setup
3. **docs/BUILD_GUIDE.md**: Comprehensive guide
4. **build/catgirl-edition/README.md**: Catgirl-specific details
5. **docs/MERGE_SUMMARY.md**: Historical context

---

## Testing and Validation

### Pre-Build Testing

#### Test Patch Application

```bash
# Create test environment
cd /tmp
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.tar.xz
tar -xf linux-6.18.tar.xz
cd linux-6.18

# Test each patch
for patch in /path/to/Linux-Kernel-Patches/6.18/*.patch; do
    echo "Testing: $patch"
    patch -p1 --dry-run < "$patch" || echo "FAILED: $patch"
done
```

#### Validate PKGBUILD Syntax

```bash
cd build/catgirl-edition

# Check syntax
bash -n PKGBUILD

# Validate with namcap (if available)
namcap PKGBUILD
```

### Post-Build Testing

#### Verify Kernel Boot

```bash
# Check kernel version
uname -r

# Check kernel command line
cat /proc/cmdline

# Check for errors
dmesg | grep -i error
dmesg | grep -i warning

# Check loaded modules
lsmod | wc -l

# Verify scheduler
cat /sys/kernel/debug/sched/features  # May require root
```

#### Performance Testing

```bash
# CPU benchmark
sysbench cpu --cpu-max-prime=20000 run

# Memory benchmark
sysbench memory --memory-total-size=10G run

# I/O benchmark
fio --name=randwrite --rw=randwrite --size=1G --bs=4k

# Gaming (if applicable)
mangohud <your-game>
```

#### Stability Testing

```bash
# Run stress test
stress-ng --cpu $(nproc) --timeout 300s

# Memory test
stress-ng --vm $(nproc) --vm-bytes 80% --timeout 300s

# Check for kernel panics
journalctl -k -b -1  # Previous boot
```

### Continuous Integration

#### GitHub Actions Workflow

**File**: `.github/workflows/fetch.yml`

```yaml
# Triggers:
# - workflow_dispatch: Manual trigger
# - schedule: Daily at 3 AM (commented out)

# Process:
# 1. Checkout repository
# 2. Run scripts/fetch.sh
# 3. (Could be extended to commit changes)
```

#### Recommended CI Extensions

For AI assistants modifying this repo:

1. **Patch validation**: Test patches apply cleanly
2. **PKGBUILD syntax check**: Validate before commit
3. **Documentation linting**: Check markdown formatting
4. **Version tracking**: Alert on new kernel releases

---

## Git and CI/CD

### Branch Strategy

#### Main Branch

- **Purpose**: Stable, tested code
- **Protection**: Should be protected (require PR reviews)
- **Updates**: Via pull requests or automated workflows

#### Feature Branches

- **Naming**: `feature/<description>` or `patch/<kernel-version>`
- **Purpose**: Development and testing
- **Lifecycle**: Merged to main, then deleted

#### Automated Branches

- **GitHub Actions**: May create branches for automated updates
- **Dependabot**: Creates branches for dependency updates

### Commit Guidelines

#### Good Commit Messages

```
feat: Add support for kernel 6.19 patches
fix: Correct patch application order in PKGBUILD
docs: Update BUILD_GUIDE with new scheduler options
chore: Update fetch.sh to use parallel downloads
perf: Optimize kernel-builder.sh with parallel checks
```

#### Bad Commit Messages

```
update
fix stuff
changes
wip
asdf
```

### CI/CD Workflows

#### Current Workflows

1. **Patch Fetching** (`.github/workflows/fetch.yml`)
   - **Trigger**: Manual or scheduled
   - **Action**: Fetch latest patches
   - **Improvement**: Could auto-commit and create PR

#### Recommended Workflows

For AI assistants to implement:

1. **Patch Validation**
   - Test each patch applies to kernel source
   - Validate no conflicts
   - Report failures

2. **Build Testing**
   - Test catgirl edition builds successfully
   - Validate PKGBUILD syntax
   - Check for common issues

3. **Documentation Sync**
   - Ensure README is up-to-date
   - Validate markdown links
   - Check code examples

4. **Release Automation**
   - Auto-tag versions
   - Generate changelogs
   - Create GitHub releases

### GitHub Actions Best Practices

```yaml
# Use latest stable actions
- uses: actions/checkout@v6

# Set concurrency to cancel old runs
concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
  cancel-in-progress: true

# Use caching when appropriate
- uses: actions/cache@v4
  with:
    path: ~/.cache
    key: ${{ runner.os }}-cache-${{ hashFiles('**/lockfile') }}

# Set appropriate timeouts
timeout-minutes: 30
```

---

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue: PKGBUILD Build Fails

**Symptoms**:
```
==> ERROR: A failure occurred in build()
```

**Solutions**:
```bash
# 1. Clean build directory
cd build/catgirl-edition
rm -rf src pkg *.tar.* *.pkg.tar.*

# 2. Update dependencies
sudo pacman -Syu base-devel clang lld llvm

# 3. Try without checksums
makepkg -scf --cleanbuild --skipchecksums

# 4. Enable debug output
makepkg -scf --cleanbuild --skipchecksums --noconfirm 2>&1 | tee build.log
```

#### Issue: Patch Fails to Apply

**Symptoms**:
```
patch: **** malformed patch at line 123
```

**Solutions**:
```bash
# 1. Check patch format
file suspicious-patch.patch

# 2. Test manually
cd /tmp/linux-source
patch -p1 --dry-run < /path/to/patch.patch

# 3. Check line endings
dos2unix suspicious-patch.patch

# 4. Verify patch is for correct kernel version
head -20 suspicious-patch.patch  # Check context
```

#### Issue: Kernel Doesn't Boot

**Symptoms**:
- System hangs at boot
- Drops to emergency shell
- Kernel panic

**Solutions**:
```bash
# 1. Boot into previous kernel from GRUB menu
# Press Shift during boot → Advanced Options → Select old kernel

# 2. Check logs
sudo journalctl -k -b -1  # Previous boot logs

# 3. Identify problematic config
# Rebuild with fewer optimizations:
# - Disable LTO
# - Use O2 instead of O3
# - Switch to GCC instead of Clang
# - Disable aggressive memory optimizations

# 4. Check hardware compatibility
dmesg | grep -i "hardware"
lspci -v
```

#### Issue: TKG Installer Not Working

**Symptoms**:
```
fzf: command not found
```

**Solutions**:
```bash
# 1. Install fzf
sudo pacman -S fzf       # Arch
sudo apt install fzf     # Debian/Ubuntu

# 2. Reinstall TKG installer
./scripts/install-tkg.sh

# 3. Clear cache
rm -rf ~/.cache/tkginstaller

# 4. Check permissions
chmod +x ./scripts/tkg-installer
```

#### Issue: Build Takes Too Long

**Solutions**:
```bash
# 1. Enable modprobed-db
sudo pacman -S modprobed-db  # or from AUR
sudo modprobed-db store      # Run regularly

# In PKGBUILD:
_localmodcfg=yes
_localmodcfg_path="$HOME/.config/modprobed.db"

# 2. Disable LTO
_use_llvm_lto=none

# 3. Use parallel builds
makepkg -scf --cleanbuild -j$(nproc)

# 4. Use ccache
sudo pacman -S ccache
export PATH="/usr/lib/ccache/bin:$PATH"
```

#### Issue: Out of Disk Space During Build

**Solutions**:
```bash
# 1. Check disk usage
df -h

# 2. Clean package cache
sudo pacman -Sc

# 3. Remove old build artifacts
cd build/catgirl-edition
rm -rf src pkg *.tar.*

# 4. Build on different partition
# Edit PKGBUILD:
BUILDDIR=/path/to/larger/partition

# 5. Use tmpfs (if enough RAM)
# Edit /etc/makepkg.conf:
BUILDDIR=/tmp/makepkg
```

### Performance Issues After Installation

#### Low Performance

```bash
# 1. Check CPU governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# Should be "performance" for desktop

# Set to performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 2. Check scheduler
cat /sys/kernel/debug/sched/features

# 3. Verify kernel parameters
cat /proc/cmdline

# 4. Check for throttling
sudo turbostat --interval 1
```

#### High Latency

```bash
# 1. Check timer frequency
grep CONFIG_HZ= /boot/config-$(uname -r)
# Should be CONFIG_HZ_1000=y for desktop

# 2. Check preemption
grep CONFIG_PREEMPT /boot/config-$(uname -r)
# Should have CONFIG_PREEMPT=y

# 3. Disable mitigations (security tradeoff)
# Add to kernel parameters:
mitigations=off
```

### Debugging Tips for AI Assistants

1. **Always check logs first**: `journalctl -k`, `dmesg`, build logs
2. **Test incrementally**: Apply changes one at a time
3. **Use dry-run**: `patch --dry-run`, `makepkg --nobuild`
4. **Validate syntax**: `bash -n script.sh`, `namcap PKGBUILD`
5. **Check permissions**: `ls -la`, `stat file`
6. **Compare configs**: `diff old-config new-config`
7. **Backup before changes**: `cp -a original backup`

---

## AI Assistant Guidelines

### When Modifying This Repository

1. **Read First**: Always read relevant files before modifying
2. **Test Changes**: Validate syntax and logic before committing
3. **Document**: Update documentation when changing functionality
4. **Follow Conventions**: Match existing code style
5. **Safety First**: Kernel modifications can break systems

### Answering User Questions

1. **Identify Goal**: Understand if user wants performance, stability, or features
2. **Recommend Appropriate Path**:
   - Desktop/gaming → Catgirl Edition with BORE
   - Server → Traditional patches with EEVDF
   - Custom → TKG packages
3. **Provide Complete Examples**: Include all steps, not just commands
4. **Warn About Risks**: Aggressive optimizations can cause instability
5. **Reference Docs**: Point to relevant documentation sections

### Making Changes

1. **Small Iterations**: Test each change independently
2. **Validate Before Commit**: Check syntax, test patches, verify builds
3. **Update Version**: Increment version numbers appropriately
4. **Changelog**: Document changes in commits
5. **Backup Critical Files**: Especially PKGBUILD and config

### Code Modification Checklist

- [ ] Read and understand existing code
- [ ] Identify all files that need changes
- [ ] Make changes following existing conventions
- [ ] Test syntax: `bash -n script.sh`
- [ ] Test functionality (dry-run if possible)
- [ ] Update documentation
- [ ] Update version numbers if applicable
- [ ] Write clear commit message
- [ ] Verify no unintended changes: `git diff`

---

## Additional Resources

### Upstream Documentation

- [Kernel.org Documentation](https://www.kernel.org/doc/)
- [Arch Wiki - Kernel Compilation](https://wiki.archlinux.org/title/Kernel/Traditional_compilation)
- [CachyOS Kernel Patches](https://github.com/CachyOS/kernel-patches)
- [Frogging-Family GitHub](https://github.com/Frogging-Family)
- [Clear Linux Kernel](https://github.com/clearlinux-pkgs/linux)

### Tools Documentation

- [makepkg - Arch Wiki](https://wiki.archlinux.org/title/Makepkg)
- [PKGBUILD - Arch Wiki](https://wiki.archlinux.org/title/PKGBUILD)
- [modprobed-db](https://github.com/graysky2/modprobed-db)
- [patchutils](https://github.com/twaugh/patchutils)

### Community Resources

- [r/linux_gaming](https://reddit.com/r/linux_gaming) - Gaming optimizations
- [r/archlinux](https://reddit.com/r/archlinux) - Arch-specific help
- [CachyOS Discord](https://discord.gg/cachyos) - CachyOS community

---

## Changelog

### Version 1.0.0 (2025-12-04)

- Initial CLAUDE.md creation
- Comprehensive repository structure documentation
- Development workflows for all build systems
- Common tasks and troubleshooting guide
- AI assistant guidelines

---

## Metadata

**File**: CLAUDE.md
**Purpose**: AI assistant guide for Linux Kernel Builder Suite
**Maintainer**: Repository maintainers
**Last Review**: 2025-12-04
**Next Review**: When major changes are made to repository structure

---

*This document is intended for AI assistants (like Claude) to understand the codebase structure, development workflows, and conventions. It should be updated whenever significant changes are made to the repository structure or development processes.*
