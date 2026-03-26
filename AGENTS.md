# AGENTS.md — AI Agent Guide for Linux Kernel Builder Suite

> Canonical reference for AI coding agents (Claude, Gemini, Copilot, etc.).
> Keep this file in sync with the codebase when making structural changes.
> **Aliases**: `CLAUDE.md` and `GEMINI.md` are symlinks to this file.

---

## Agent Quick Start

Before writing any code, read these files in order:

1. `scripts/lib-common.sh` — shared library every script sources; understand its API before touching any script
2. `scripts/lib-kernel-config.sh` — all kconfig manipulation goes here
3. The specific script or PKGBUILD you are modifying

**Key rules (never violate)**:
- Always source `scripts/lib-common.sh`; never copy its helpers
- Always use `die "msg"` for fatal errors; never `exit 1`
- Always add shellcheck directives at the top of every new script
- Never commit `src/`, `pkg/`, `*.pkg.tar.zst`, or `*.tar.xz` build artifacts
- Run `bash -n <script.sh>` and `shellcheck` before committing any shell change
- Use `rg` (ripgrep) for file/code discovery within the repo

---

## Project

**One-liner**: Unified Linux kernel build suite — curated patches, Catgirl Edition, CachyMod, and TKG integration for performance-optimized custom kernels.

**Primary language**: Bash (shell scripts, PKGBUILDs)
**Secondary language**: Python (benchmark scraping/reporting)
**Target distro**: Arch Linux / CachyOS (pacman, makepkg, PKGBUILD)
**No traditional build system** (no Makefile, package.json, Cargo.toml, pyproject.toml)

**Frameworks / ecosystems**:
- `makepkg` / PKGBUILD — Arch package build system
- `gum` — TUI dialogs for interactive scripts (CachyMod)
- `fzf` — fuzzy finder for TKG installer menus
- Docker (`pttrr/docker-makepkg`) — cross-arch kernel builds
- GitHub Actions — CI/CD (build, patch fetch)

---

## Structure

```
Linux-Kernel-Patches/
├── kernel-builder.sh           # PRIMARY entry point — unified CLI for all operations
├── autofdo.sh                  # AutoFDO profile-guided optimization workflow
├── docker-build.sh             # Docker-based multi-arch kernel builds
├── cachyos-benchmarker.sh      # Mini benchmark suite (cpu/mem/io/codec)
├── custom-device-pollrates.sh  # USB/HID device polling rate configurator
├── custom-device-pollrates.conf# udev rules config for poll rates
├── custom-device-pollrates.service # systemd service for poll rate persistence
├── benchmark_scraper.py        # Parse benchmark logs → HTML report + charts
├── srcinfo.sh                  # Regenerate .SRCINFO for all PKGBUILDs
│
├── scripts/
│   ├── lib-common.sh           # SHARED LIBRARY — source this in ALL scripts
│   ├── lib-kernel-config.sh    # Kernel kconfig helpers (apply_*_opts)
│   ├── fetch.sh                # Parallel patch fetching from upstream lists
│   ├── compile.sh              # Kernel compilation with modprobed-db + xconfig
│   ├── tkg-installer           # TKG/Frogminer package TUI (linux/nvidia/mesa/wine/proton)
│   ├── install-tkg.sh          # Install tkg-installer to system
│   └── utils/
│       ├── sort-modprobed-dbs  # Merge/sort modprobed-db files
│       └── zramswap            # ZRAM swap configuration
│
├── build/
│   ├── catgirl-edition/        # Catgirl Edition — aggressive perf kernel
│   │   ├── PKGBUILD            # PRIMARY build file; all tuning vars here
│   │   ├── config              # Base kernel .config (~289KB, ~8000 options)
│   │   └── patches/            # Build-time patches (Clear Linux patchset)
│   ├── cachymod/               # CachyMod — interactive CachyOS kernel builder
│   │   ├── confmod.sh          # Interactive config wizard (requires gum)
│   │   ├── uninstall.sh        # Remove installed cachymod kernels
│   │   ├── defconfigs/         # Pre-made .conf files (618-bore, 618-bmq, etc.)
│   │   └── 6.18/               # Per-version build directory
│   │       ├── PKGBUILD        # CachyMod PKGBUILD
│   │       ├── build.sh        # Build from saved config name
│   │       ├── config.sh       # Config helper (wraps scripts/lib-kernel-config.sh)
│   │       ├── config          # Base kernel config
│   │       └── *.patch         # Scheduler and feature patches
│   ├── linux-cachyos/          # Upstream CachyOS kernel PKGBUILD
│   ├── linux-cachyos-bore/     # CachyOS with BORE scheduler
│   └── linux-cachyos-rc/       # CachyOS release-candidate kernel
│
├── 6.12/ 6.18/ 6.19/           # Patch collections per kernel version
│   ├── patches.txt             # Patch inventory / fetch list
│   └── *.patch                 # Individual patch files
│
├── docs/
│   ├── BUILD_GUIDE.md          # Comprehensive build guide
│   ├── PATCH_SOURCES.md        # Upstream patch source references
│   └── REFACTORING.md          # Refactoring history / design decisions
│
└── .github/
    ├── workflows/fetch.yml     # Trigger: manual — runs scripts/fetch.sh
    └── workflows/build.yml     # Trigger: push to linux-cachyos/PKGBUILD — builds GCC+Clang
```

---

## Dev Workflow

### Setup

```bash
# Dependencies (Arch/CachyOS)
sudo pacman -S --needed base-devel clang lld llvm gum fzf expac modprobed-db ccache

# Clone
git clone https://github.com/Ven0m0/Linux-Kernel-Patches
cd Linux-Kernel-Patches

# No install step — scripts run in-place
```

### Build

```bash
# Interactive menu (recommended starting point)
./kernel-builder.sh

# Catgirl Edition (PKGBUILD-based)
cd build/catgirl-edition
makepkg -scf --cleanbuild --skipchecksums

# CachyMod — create config first, then build
cd build/cachymod/6.18
../confmod.sh          # interactive wizard, saves to ~/.config/cachymod/<name>.conf
./build.sh <confname>  # build from saved config
./build.sh list        # list all saved configs

# Docker multi-arch build
./docker-build.sh [generic|v3|v4]
```

### Test / Validate

```bash
# Syntax check any shell script
bash -n <script.sh>

# Validate PKGBUILD
namcap build/catgirl-edition/PKGBUILD        # requires namcap package

# Dry-run patch application (against downloaded kernel source)
patch -p1 --dry-run < 6.18/some.patch

# Post-build kernel checks
uname -r
dmesg | grep -i error
cat /sys/kernel/debug/sched/features
sysbench cpu --cpu-max-prime=20000 run       # CPU benchmark
stress-ng --cpu $(nproc) --timeout 300s      # stability
```

### Lint

```bash
# shellcheck (used in CI via super-linter)
shellcheck -e SC2218 scripts/tkg-installer
shellcheck scripts/lib-common.sh
shellcheck scripts/fetch.sh

# All scripts have shellcheck directives at top:
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
```

### Fetch Latest Patches

```bash
./scripts/fetch.sh           # downloads parallel, respects MAX_PARALLEL=4
# OR
./kernel-builder.sh fetch
# OR trigger GitHub Action: Actions → "Fetch files" → Run workflow
```

### Deploy / Install

```bash
# Install built kernel package
sudo pacman -U build/catgirl-edition/linux-catgirl-*.pkg.tar.zst
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo reboot

# TKG packages (interactive)
./scripts/tkg-installer
./scripts/tkg-installer linux      # direct: linux-tkg
./scripts/tkg-installer nvidia     # direct: nvidia-tkg
./scripts/tkg-installer mesa       # direct: mesa-tkg
./scripts/tkg-installer wine       # direct: wine-tkg
./scripts/tkg-installer proton     # direct: proton-tkg
```

---

## Conventions

### Shell Script Style

All scripts follow this pattern — **read `scripts/lib-common.sh` before writing new scripts**:

```bash
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=./lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"

# Strict mode is already set by lib-common.sh; only add below in standalone scripts
# that may run without sourcing it:
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'
```

### Output Functions (from lib-common.sh)

| Function | Color   | Use for                       |
|----------|---------|-------------------------------|
| `info`   | green   | Success / progress messages   |
| `warn`   | yellow  | Non-fatal warnings            |
| `msg`    | cyan    | Informational / neutral       |
| `die`    | red     | Fatal errors (exits)          |
| `debug`  | magenta | Debug only when `DEBUG=1`     |

### Naming Conventions

- **Functions**: `snake_case` for library functions; `PascalCase` for top-level commands in `kernel-builder.sh`
- **Variables**: `UPPER_CASE` for constants/exports; `lower_case` for locals
- **PKGBUILD vars**: `_leading_underscore` for user-configurable options (e.g., `_cpusched`, `_use_llvm_lto`)
- **Config vars in PKGBUILD**: colon-expansion default pattern: `: "${_var:=default}"`
- **Patch files**: `descriptive-kebab-case.patch` or `<git-hash>.patch`
- **Config files**: `<version>-<scheduler>.conf` (e.g., `618-bore.conf`)

### Error Handling

```bash
# Always use die() for fatal errors — never bare exit 1
die "Kernel directory not found: $kdir"

# Use require_commands for dependency checks
require_commands expac pacman makepkg

# Validate kernel dirs before use
validate_kernel_dir "$KERNEL_DIR"

# Cleanup via trap (registered in lib-common.sh)
add_cleanup "/tmp/my-tempdir"
```

### File Organization

- **New shared utilities** → add to `scripts/lib-common.sh` or `scripts/lib-kernel-config.sh`
- **New kernel config functions** → add to `scripts/lib-kernel-config.sh` using `_apply_config` helper
- **Standalone scripts** → source `lib-common.sh` at top; don't duplicate color defs or helper functions
- **New patches** → place in `<kernel-version>/` directory; update `<kernel-version>/patches.txt`
- **New PKGBUILD variants** → create `build/<name>/PKGBUILD` + `build/<name>/config`

### Import / Source Style

```bash
# Relative sourcing (portable across symlinks)
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"

# Or the compact form used in some scripts:
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
```

### PKGBUILD Conventions

```bash
# User-tunable vars use colon-expansion with defaults
: "${_cpusched:=bore}"               # bore | eevdf | bmq | rt | rt-bore
: "${_use_llvm_lto:=thin}"           # none | thin | full
: "${_optimize:=O3}"                 # O2 | O3 | Os | Ofast
: "${_march:=native}"                # CPU arch target
: "${_localmodcfg:=no}"             # yes = use modprobed-db (smaller kernel)
: "${_makenconfig:=no}"             # yes = pause for interactive nconfig
```

---

## Dependencies

| Dependency               | Purpose                                      | Required by                          |
|--------------------------|----------------------------------------------|--------------------------------------|
| `base-devel`             | makepkg, gcc, etc.                           | All PKGBUILDs                        |
| `clang` + `lld` + `llvm` | LLVM toolchain for LTO builds                | catgirl-edition, cachymod            |
| `gum`                    | TUI dialogs for interactive config wizard    | `build/cachymod/confmod.sh`          |
| `fzf`                    | Fuzzy finder menus                           | `scripts/tkg-installer`              |
| `expac`                  | Query pacman package info                    | `kernel-builder.sh`                  |
| `modprobed-db`           | Track loaded modules → minimal kernel config | `scripts/compile.sh`, PKGBUILDs      |
| `ccache`                 | Compiler cache (speeds up rebuilds)          | All PKGBUILDs (optional)             |
| `namcap`                 | PKGBUILD validation (optional)               | CI/local dev                         |
| `Docker`                 | Cross-arch kernel builds                     | `docker-build.sh`                    |
| `perf`                   | CPU profiling for AutoFDO                    | `autofdo.sh`                         |
| `sysbench` / `stress-ng` | Performance and stability testing            | Post-install validation              |
| `numpy` + `matplotlib`   | Python benchmark report generation           | `benchmark_scraper.py`               |

---

## Common Tasks

### Add a New Patch

```bash
# 1. Place patch in the right kernel version directory
cp /path/to/new.patch 6.18/

# 2. Add to fetch list (if it should be auto-fetched)
echo "https://example.com/new.patch  new.patch" >> 6.18/patches.txt

# 3. Dry-run test against kernel source
cd /tmp && wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.18.tar.xz
tar -xf linux-6.18.tar.xz && cd linux-6.18
patch -p1 --dry-run < /path/to/Linux-Kernel-Patches/6.18/new.patch

# 4. Commit
git add 6.18/new.patch 6.18/patches.txt
git commit -m "feat: Add new.patch for kernel 6.18"
```

### Add a New Kernel Config Option

```bash
# All kconfig helpers live in scripts/lib-kernel-config.sh
# Add a new apply_* function following the pattern:
apply_my_feature(){ _apply_config "$1" -e MY_FEATURE -d CONFLICTING_OPTION; }

# For batched apply (preferred for performance):
apply_my_feature(){
  _apply_config "$1" \
    -e MY_FEATURE_A \
    -e MY_FEATURE_B \
    -d CONFLICTING_OPTION
}

# Then call from scripts/compile.sh or PKGBUILD
apply_my_feature "$KERNEL_DIR"
```

### Add a New Script

```bash
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=./lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"

# Your script here — use info/warn/die/msg/has/require_commands
require_commands pacman makepkg
info "Doing the thing..."
```

### Add a New PKGBUILD Variant

```bash
# 1. Create directory
mkdir -p build/linux-my-variant

# 2. Copy closest existing PKGBUILD as base
cp build/linux-cachyos/PKGBUILD build/linux-my-variant/
cp build/linux-cachyos/config   build/linux-my-variant/

# 3. Edit PKGBUILD — adjust pkgname, scheduler options, patches
# 4. Generate srcinfo
bash srcinfo.sh

# 5. Test build
cd build/linux-my-variant
makepkg -scf --cleanbuild --skipchecksums --noconfirm
```

### Fix a Failing Patch

```bash
# 1. Check the error
patch -p1 --dry-run < 6.18/failing.patch 2>&1

# 2. Common fixes:
dos2unix failing.patch          # fix Windows line endings
head -20 failing.patch          # verify target kernel version in context

# 3. If context mismatch, try fuzzy matching
patch -p1 --fuzz=3 < failing.patch

# 4. If still failing, regenerate from git
git format-patch -1 <commit-hash>
```

### Update Shared Library

```bash
# lib-common.sh is sourced by ALL scripts — changes affect everything
# 1. Edit scripts/lib-common.sh
# 2. Test that guard works (sourcing twice should be a no-op):
bash -c 'source scripts/lib-common.sh; source scripts/lib-common.sh; echo ok'
# 3. Run shellcheck
shellcheck scripts/lib-common.sh
# 4. Test representative scripts
bash -n scripts/fetch.sh
bash -n scripts/compile.sh
bash -n kernel-builder.sh
```

---

## CI/CD

### Workflows

| Workflow  | File                           | Trigger                                    | What it does                                                                     |
|-----------|--------------------------------|--------------------------------------------|----------------------------------------------------------------------------------|
| **Fetch** | `.github/workflows/fetch.yml`  | `workflow_dispatch` (manual)               | Runs `scripts/fetch.sh` to download latest patches                               |
| **Build** | `.github/workflows/build.yml`  | Push to `linux-cachyos/PKGBUILD` or manual | Builds `linux-cachyos` with GCC and Clang in parallel; uploads `.pkg.tar.zst`   |

### Build Matrix

The build workflow runs a `strategy.matrix` over `[gcc, clang]`:
- **gcc**: `_use_llvm_lto=none`
- **clang**: `_use_llvm_lto=thin`

Both use CachyOS repository for dependencies, ccache for caching, and the `CachyOS GitHub Actions` packager signature.

### Dependency Updates

- **Renovate** (`renovate.json`): follows `config:recommended`
- **Dependabot** (`.github/dependabot.yml`): daily updates for GitHub Actions, weekly for git submodules

### Adding a New Workflow

```yaml
name: My workflow
on:
  workflow_dispatch:
  push:
    paths: ['relevant/path/**']

concurrency:
  group: ${{ github.workflow }}-${{ github.head_ref || github.run_id }}
  cancel-in-progress: true

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 0
      # ...
```

---

## Tool Preferences

| Category        | Tool                     | Notes                                         |
|-----------------|--------------------------|-----------------------------------------------|
| Shell           | Bash (4+)                | `#!/usr/bin/env bash`, not `/bin/bash`        |
| Linter          | shellcheck               | `enable=all`, directives at top of each file  |
| Package manager | pacman / makepkg         | Arch/CachyOS only                             |
| Compiler        | Clang/LLVM (preferred)   | GCC as fallback; set via `_use_llvm_lto`      |
| TUI             | gum (confmod), fzf (tkg) | Not interchangeable                           |
| Profiler        | perf (AutoFDO)           | `autofdo.sh` workflow                         |
| Formatter       | None enforced            | Follow surrounding code style                 |
| Python          | System python3           | Only for `benchmark_scraper.py`               |
| Docker image    | `pttrr/docker-makepkg`   | For cross-arch builds in `docker-build.sh`    |
| File search     | `rg` (ripgrep)           | Preferred over `grep`/`find` for discovery    |

---

## Key Design Decisions

1. **`lib-common.sh` is the single source of truth** for shared shell utilities. Never copy-paste color definitions or helper functions into new scripts — source the library.

2. **`lib-kernel-config.sh` wraps `scripts/config`** — all kconfig manipulation goes through `_apply_config()` which validates the kernel dir first. Batch multiple options in a single call to minimize subprocess overhead.

3. **PKGBUILD variables use colon-expansion** (`: "${_var:=default}"`) so users can override from the environment without editing the file.

4. **Parallel downloads** in `scripts/fetch.sh` use a rolling window (`MAX_PARALLEL=4`) — not `wait -n` on all jobs at once — for better throughput on slow connections.

5. **The `has()` function in lib-common.sh caches results** in `__HAS_CACHE` associative array to avoid repeated `command -v` subprocess spawning in tight loops.

6. **Cleanup via `add_cleanup()`** — register temp paths at the start, `trap` handles cleanup on EXIT/INT/TERM automatically.

7. **No Python runtime dependency** for the build system — Python is only used for the optional benchmark scraper.

---

## Troubleshooting Quick Reference

```bash
# Build failed — clean and retry
cd build/catgirl-edition && rm -rf src pkg *.tar.* *.pkg.tar.*
makepkg -scf --cleanbuild --skipchecksums 2>&1 | tee build.log

# Patch won't apply
dos2unix the.patch
patch -p1 --dry-run --fuzz=3 < the.patch

# Script has unbound variable error
bash -x script.sh 2>&1 | head -50    # trace execution

# Kernel won't boot — rebuild with safer options
# In PKGBUILD: _use_llvm_lto=none, _optimize=O2, _march=x86-64

# Out of disk space during build
BUILDDIR=/path/with/space makepkg -scf --cleanbuild --skipchecksums

# TKG installer missing fzf
sudo pacman -S fzf && chmod +x scripts/tkg-installer

# modprobed-db not found
sudo pacman -S modprobed-db && sudo modprobed-db store
```

---

*This file is the canonical AI agent guide. `CLAUDE.md` and `GEMINI.md` are symlinks to this file.*
