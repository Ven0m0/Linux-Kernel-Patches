# Script Migration Guide

**Date**: 2025-12-09
**Version**: 2.0

## Overview

The kernel configuration scripts have been merged and deduplicated into a unified system. This guide helps you migrate from the old scripts to the new system.

## What Changed

### Merged Scripts

Three overlapping scripts have been merged into one unified system:

| Old Script | Size | Status | Replacement |
|-----------|------|--------|-------------|
| `config.sh` | 15K | Archived | `kernel-config.sh --mode=minimal` |
| `trim.sh` | 51K | Archived | `kernel-config.sh --mode=trim` |
| `cachy/cachy.sh` | 17K | Archived | `kernel-config.sh --mode=cachy` |

### New Structure

```
scripts/
├── lib-kernel-config.sh      # Modular configuration library (NEW)
├── kernel-config.sh           # Unified CLI wrapper (NEW)
├── compile.sh                 # Updated to use lib-kernel-config.sh
├── fetch.sh                   # Unchanged
├── install-tkg.sh             # Unchanged
├── tkg-installer              # Unchanged
├── utils/
│   ├── sort-modprobed-dbs    # Enhanced
│   └── zramswap              # Unchanged
└── archived/                  # Old scripts (for reference)
    ├── config.sh
    ├── trim.sh
    └── cachy.sh
```

## Quick Migration

### Example 1: Minimal Configuration

**Old way:**
```bash
cd /usr/src/linux-6.18
~/Linux-Kernel-Patches/scripts/config.sh .
```

**New way:**
```bash
~/Linux-Kernel-Patches/scripts/kernel-config.sh --mode=minimal /usr/src/linux-6.18
```

### Example 2: Aggressive Trimming

**Old way:**
```bash
cd /usr/src/linux-6.18
~/Linux-Kernel-Patches/scripts/trim.sh .
```

**New way:**
```bash
~/Linux-Kernel-Patches/scripts/kernel-config.sh --mode=trim /usr/src/linux-6.18
```

### Example 3: CachyOS Profile

**Old way:**
```bash
cd /usr/src/linux-6.18
~/Linux-Kernel-Patches/scripts/cachy/cachy.sh .
```

**New way:**
```bash
~/Linux-Kernel-Patches/scripts/kernel-config.sh --mode=cachy /usr/src/linux-6.18
```

### Example 4: Full Optimizations (New!)

**New capability:**
```bash
# Apply ALL optimizations (new default mode)
~/Linux-Kernel-Patches/scripts/kernel-config.sh /usr/src/linux-6.18

# Or explicitly:
~/Linux-Kernel-Patches/scripts/kernel-config.sh --mode=full /usr/src/linux-6.18
```

## Modes Explained

### minimal
- Basic optimizations
- Debug feature disabling
- Performance settings (BBR, O3, hugepages)
- Good for general use

### trim
- Everything in `minimal`
- Aggressive driver removal
- Subsystem disabling
- Best for custom desktop builds

### cachy
- Everything in `trim`
- CachyOS-specific optimizations
- Clear Linux defaults
- Performance-focused desktop

### full (default)
- All optimizations combined
- Maximum performance
- Smallest kernel size
- Desktop/gaming focused

## API for Scripts

If you're calling the configuration from other scripts, you can use the library directly:

```bash
#!/usr/bin/env bash

# Source the library
source /path/to/scripts/lib-kernel-config.sh

# Use individual functions
apply_performance_opts "/usr/src/linux-6.18"
apply_network_opts "/usr/src/linux-6.18"
apply_compiler_opts "/usr/src/linux-6.18"

# Or use complete profiles
apply_cachy_profile "/usr/src/linux-6.18"
```

## Available Functions

See `lib-kernel-config.sh` for the complete list. Key functions include:

- `apply_minimal_profile()`
- `apply_trim_profile()`
- `apply_cachy_profile()`
- `apply_full_profile()`
- `apply_performance_opts()`
- `apply_network_opts()`
- `apply_debug_disable()`
- `apply_compiler_opts()`
- And many more...

## Updated Scripts

### compile.sh

The `compile.sh` script now uses the unified library:

```bash
# Old: inline kernel config commands
# New: uses lib-kernel-config.sh functions

~/Linux-Kernel-Patches/scripts/compile.sh /usr/src/linux-6.18
```

No changes needed for users - it works the same way but uses the new library internally.

## Benefits

1. **70% size reduction**: ~83K → ~25K of configuration code
2. **No duplication**: Single source of truth
3. **Modular**: Mix and match optimizations
4. **Maintainable**: Fix bugs once, benefit everywhere
5. **Flexible**: Choose your optimization level
6. **Better UX**: Clear help text and error messages

## Compatibility Notes

### Behavior Changes

The new scripts produce **identical** kernel configurations as the old scripts. The only differences are:

1. Better error handling
2. More informative output
3. CLI argument parsing
4. Modprobed-db sorting is now a separate step (but still happens automatically)

### Backward Compatibility

The archived scripts (`scripts/archived/*.sh`) are preserved for reference but will not receive updates. They can still be used if needed, but we recommend migrating to the new system.

## Troubleshooting

### "Cannot find lib-kernel-config.sh"

Make sure you're using the latest version of the repository:
```bash
cd ~/Linux-Kernel-Patches
git pull
```

### "Invalid mode"

Use one of the supported modes:
- `minimal`
- `trim`
- `cachy`
- `full`

### Getting Help

```bash
# Show detailed help
~/Linux-Kernel-Patches/scripts/kernel-config.sh --help

# Check version
cat ~/Linux-Kernel-Patches/scripts/lib-kernel-config.sh | head -5
```

## Examples

### Building a Gaming Kernel

```bash
# Download kernel
cd /tmp
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.tar.xz
tar -xf linux-6.18.tar.xz
cd linux-6.18

# Apply full optimization profile
~/Linux-Kernel-Patches/scripts/kernel-config.sh --mode=full .

# Build
make -j$(nproc)
sudo make modules_install
sudo make install
```

### Building a Minimal Server Kernel

```bash
cd /usr/src/linux-6.18

# Apply minimal profile
~/Linux-Kernel-Patches/scripts/kernel-config.sh --mode=minimal .

# Customize further
make menuconfig

# Build
make -j$(nproc)
```

### Using Custom Profiles

```bash
#!/usr/bin/env bash
# my-custom-kernel-build.sh

source ~/Linux-Kernel-Patches/scripts/lib-kernel-config.sh

KERNEL_SRC="/usr/src/linux-6.18"

# Apply base minimal
apply_minimal_profile "$KERNEL_SRC"

# Add network optimizations
apply_network_opts "$KERNEL_SRC"

# But keep debugging for development
apply_debug_disable "$KERNEL_SRC"

# Custom settings
scripts/config -e MY_CUSTOM_FEATURE

# Build
cd "$KERNEL_SRC"
make -j$(nproc)
```

## Feedback

If you encounter issues or have suggestions, please:
- Check existing issues: https://github.com/Ven0m0/Linux-Kernel-Patches/issues
- Open a new issue if needed

## See Also

- [CLAUDE.md](../CLAUDE.md) - Complete repository documentation
- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Kernel building guide
- [scripts/kernel-config.sh](../scripts/kernel-config.sh) - Main script
- [scripts/lib-kernel-config.sh](../scripts/lib-kernel-config.sh) - Function library
