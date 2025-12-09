# Kernel Patch Sources

This document provides detailed information about various kernel patch sources available for integration with the Linux Kernel Builder Suite.

## Table of Contents

1. [Integrated Sources](#integrated-sources)
2. [Available for Manual Integration](#available-for-manual-integration)
3. [Integration Guidelines](#integration-guidelines)
4. [Adding New Sources](#adding-new-sources)

---

## Integrated Sources

### CachyOS Kernel Patches ✅

**Status**: Fully integrated via PKGBUILD auto-fetch

- **Repository**: https://github.com/CachyOS/kernel-patches
- **Integration**: Automatic at build time via `build/catgirl-edition/PKGBUILD`
- **Configuration**: `_import_cachyos_patchset=yes` (default)
- **Features**:
  - Multiple CPU schedulers (BORE, BMQ, EEVDF, RT, RT-BORE)
  - Performance optimizations
  - Hardware support improvements
  - NVIDIA driver patches
- **Version**: Dynamically detected from latest mainline
- **Location**: Fetched from `https://raw.githubusercontent.com/cachyos/kernel-patches/master/${version}/`

**Usage**:
```bash
# In build/catgirl-edition/PKGBUILD
: "${_import_cachyos_patchset:=yes}"  # Enable CachyOS patches
: "${_cpusched:=bore}"                # Select scheduler
```

### GloriousEggroll Linux Pollrate Patch ✅

**Status**: Integrated in repository

- **Repository**: https://github.com/GloriousEggroll/Linux-Pollrate-Patch
- **Description**: USB device polling rate improvements for gaming peripherals
- **Benefits**:
  - Higher polling rates for mice and keyboards
  - Reduced input latency
  - Improved gaming experience
- **Location**: `6.18/pollrate.patch`
- **Fetch URL**: `https://raw.githubusercontent.com/GloriousEggroll/Linux-Pollrate-Patch/main/pollrate.patch`

**Apply manually**:
```bash
cd linux-6.18
patch -p1 < /path/to/Linux-Kernel-Patches/6.18/pollrate.patch
patch -p1 < pollrate.patch

### ZRAM-IR (ZRAM Improved Read) ✅

**Status**: Integrated in repository

- **Repository**: https://github.com/firelzrd/zram-ir
- **Description**: Performance improvements for ZRAM compressed memory reads
- **Benefits**:
  - Faster memory decompression
  - Improved system responsiveness under memory pressure
  - Better performance for systems using ZRAM swap
- **Versions Available**:
  - `6.16/zram-ir-1.2.patch` - For kernel 6.16.0+
  - `6.17/zram-ir-1.2.patch` - For kernel 6.17.x
  - `6.18/zram-ir-1.2.patch` - For kernel 6.18.x
  - `6.19/zram-ir-1.2.patch` - For kernel 6.19.x
- **Fetch URL**:
  - `https://raw.githubusercontent.com/firelzrd/zram-ir/main/patches/0001-linux6.16.0-zram-ir-1.2.patch`

**Apply manually**:
```bash
cd linux-6.16
patch -p1 < /path/to/Linux-Kernel-Patches/6.16/zram-ir-1.2.patch
```

---

## Available for Manual Integration

These sources contain extensive patch collections. Review carefully before integration to avoid conflicts with existing patches.

### openSUSE kernel-source: patches.rpmify

**Repository**: https://github.com/openSUSE/kernel-source/tree/master/patches.rpmify

- **Focus**: RPM packaging adaptations
- **Patch Count**: ~6 patches
- **Target Use Case**: Building RPM packages for openSUSE/SUSE/Fedora
- **Notable Patches**:
  - `Add-ksym-provides-tool.patch` - Kernel symbol provides for RPM
  - `BTF-Don-t-break-ABI-when-debuginfo-is-disabled.patch` - BTF ABI stability
  - `usrmerge-Adjust-module-path-in-the-kernel-sources.patch` - UsrMerge support

**Integration Considerations**:
- ⚠️ Primarily useful for RPM-based distributions
- ⚠️ May not be relevant for Arch-based builds
- ✅ Safe to integrate if building for openSUSE/Fedora targets

### openSUSE kernel-source: patches.suse

**Repository**: https://github.com/openSUSE/kernel-source/tree/master/patches.suse

- **Focus**: SUSE enterprise and server features
- **Patch Count**: 100+ patches
- **Target Use Case**: Enterprise/server deployments
- **Categories**:
  - Hardware support (especially enterprise hardware)
  - File system improvements
  - Security hardening
  - Performance tuning for server workloads

**Integration Considerations**:
- ⚠️ Large patch set with complex dependencies
- ⚠️ May conflict with existing performance patches
- ⚠️ Targeted at enterprise use cases, not desktop gaming
- ⚠️ Requires careful review and testing

**Recommendation**: Selectively cherry-pick specific patches rather than wholesale integration.

### arvin-foroutan/build-ubuntu-kernel: patches

**Repository**: https://github.com/arvin-foroutan/build-ubuntu-kernel/tree/master/patches

- **Focus**: Comprehensive patch collection organized by category
- **Patch Count**: 200+ patches across multiple categories
- **Categories**:
  - **clearlinux/**: Intel Clear Linux patches (overlaps with existing integration)
  - **graysky/**: CPU optimization patches
  - **ll-patches/**: Low-latency patches
  - **lucjan/**: Lucjan's kernel patches (desktop performance)
  - **xanmod/**: XanMod kernel patches
  - **O3-optimization/**: -O3 compiler optimization patches
  - **rt/**: Real-time kernel patches
  - **ubuntu-5.4/, ubuntu-5.7+, ubuntu-6.10+, ubuntu-6.17+/**: Ubuntu-specific patches by version

**Integration Considerations**:
- ⚠️ **High overlap risk**: Many categories overlap with existing CachyOS/Clear Linux integrations
- ⚠️ **Version-specific**: Ubuntu version directories may not match mainline kernel versions
- ⚠️ **Potential conflicts**: Multiple scheduler and optimization approaches
- ✅ **Good reference**: Useful for discovering new patch sources

**Recommendation**:
1. Use as a reference to discover upstream patch sources
2. Integrate specific categories that don't overlap (e.g., hardware-specific fixes)
3. Avoid categories already covered (clearlinux, xanmod if using CachyOS)

### arvin-foroutan/build-ubuntu-kernel: build_kernel.sh

**Repository**: https://github.com/arvin-foroutan/build-ubuntu-kernel/blob/master/build_kernel.sh

- **Type**: Build automation script
- **Target**: Ubuntu/Debian-based distributions
- **Purpose**: Reference implementation for:
  - Automated patch application
  - Kernel configuration
  - Debian package building
  - Multi-version support

**Integration Considerations**:
- ℹ️ Not a patch, but a build script reference
- ℹ️ Debian/Ubuntu-focused (different from Arch PKGBUILD approach)
- ✅ Good source of ideas for automation improvements

**Recommendation**: Review for workflow ideas, not direct integration.

---

## Integration Guidelines

### Before Integrating New Patches

1. **Check for Overlap**:
   - Compare with existing CachyOS patches
   - Check against Clear Linux patchset
   - Verify no duplicate functionality

2. **Test Compatibility**:
   ```bash
   # Dry-run test
   cd /tmp/linux-source
   patch -p1 --dry-run < /path/to/new.patch
   ```

3. **Review Patch Purpose**:
   - Does it align with repository goals (performance/gaming/desktop)?
   - Is it maintenance burden justified?
   - Does it conflict with existing optimizations?

4. **Check Kernel Version**:
   - Verify patch applies to target kernel version
   - Check if backporting or forward-porting is needed

### Safe Integration Process

1. **Add to appropriate version directory**:
   ```bash
   cp new.patch Linux-Kernel-Patches/6.18/
   ```

2. **Update patches.txt** (if using autofetch):
   ```bash
   echo "https://example.com/new.patch" >> 6.18/patches.txt
   ```

3. **Update fetch.sh** (if autofetching):
   ```bash
   # Add to lists associative array in scripts/fetch.sh
   ["https://example.com/patches.txt"]="lists/6.18"
   ```

4. **Test in VM first**:
   - Build kernel in virtual machine
   - Test boot and basic functionality
   - Verify no regressions

5. **Document in commit**:
   ```bash
   git commit -m "feat: add new-feature patch for 6.18

   Source: https://example.com/patch
   Benefits: <describe benefits>
   Tested: <describe testing>"
   ```

### Patch Categories

**High Priority for Integration**:
- ✅ Performance improvements
- ✅ Gaming optimizations
- ✅ Desktop responsiveness
- ✅ Hardware support (common hardware)

**Medium Priority**:
- ⚠️ Security hardening (if no performance cost)
- ⚠️ File system improvements
- ⚠️ Power management

**Low Priority/Avoid**:
- ❌ Enterprise/server-specific features
- ❌ RPM/DEB packaging patches
- ❌ Patches that duplicate existing functionality
- ❌ Untested/experimental patches

---

## Adding New Sources

To add a new patch source to autofetch:

1. **Verify patch availability**:
   ```bash
   curl -fsSL "https://example.com/patch.patch" | head
   ```

2. **Create/update patches.txt**:
   ```bash
   cat >> 6.18/patches.txt <<EOF
   # New source: Example patches
   https://example.com/patch1.patch
   https://example.com/patch2.patch
   EOF
   ```

3. **Update fetch.sh**:
   ```bash
   # Edit scripts/fetch.sh, add to lists array:
   ["https://raw.githubusercontent.com/yourrepo/main/6.18/patches.txt"]="lists/6.18"
   ```

4. **Test fetch**:
   ```bash
   cd Linux-Kernel-Patches
   ./scripts/fetch.sh
   ls -la lists/6.18/
   ```

5. **Update documentation**:
   - Add to this file (PATCH_SOURCES.md)
   - Update TODO.md if from TODO list
   - Update main README.md if significant

---

## Patch Source Evaluation Checklist

When evaluating a new patch source:

- [ ] **Active maintenance**: Last commit within 6 months?
- [ ] **Clear purpose**: Does it have clear documentation?
- [ ] **Licensing**: Compatible with GPL-2.0?
- [ ] **Community**: Used by other distributions/projects?
- [ ] **Size**: Reasonable number of patches (not 1000s)?
- [ ] **Conflicts**: Tested against existing patches?
- [ ] **Benefits**: Clear performance/functionality improvements?
- [ ] **Risks**: Documented risks and trade-offs?

---

## Resources

### Upstream Patch Sources

- **Kernel.org patches**: https://cdn.kernel.org/pub/linux/kernel/
- **CachyOS**: https://github.com/CachyOS/kernel-patches
- **XanMod**: https://github.com/xanmod/linux-patches
- **Clear Linux**: https://github.com/clearlinux-pkgs/linux
- **Liquorix**: https://github.com/damentz/liquorix-package
- **Zen Kernel**: https://github.com/zen-kernel/zen-kernel

### Patch Review Tools

- **patchutils**: https://github.com/twaugh/patchutils
  ```bash
  # View patch statistics
  lsdiff patch.patch

  # Filter patches by file
  filterdiff -i '*.c' patch.patch
  ```

- **quilt**: http://savannah.nongnu.org/projects/quilt
  ```bash
  # Manage patch series
  quilt series
  quilt push
  quilt pop
  ```

---

**Last Updated**: 2025-12-09
**Maintainer**: Repository maintainers
**Related**: See also `CLAUDE.md`, `BUILD_GUIDE.md`, `TODO.md`
