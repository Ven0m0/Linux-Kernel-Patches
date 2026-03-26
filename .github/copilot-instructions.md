# GitHub Copilot Instructions — Linux Kernel Builder Suite

> Full agent guide: `AGENTS.md` (root). This file focuses on code generation patterns.

## Project Snapshot

- **What**: Unified Linux kernel build suite — Catgirl Edition, CachyMod, TKG integration, curated patches
- **Language**: Bash (primary), Python (benchmark scraper only)
- **Target**: Arch Linux / CachyOS (`pacman`, `makepkg`, PKGBUILD)
- **Entry point**: `./kernel-builder.sh`
- **No** Makefile, package.json, Cargo.toml, or pyproject.toml

---

## Critical Rules (Always Apply)

```bash
# REQUIRED at top of every new shell script — no exceptions
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=./lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"
```

| Do | Don't |
|----|-------|
| `die "reason"` for fatal errors | `exit 1` bare |
| `require_commands foo bar` to check deps | Silent missing-command failures |
| `source lib-common.sh` for all helpers | Copy color defs or helper functions |
| `add_cleanup "/tmp/dir"` for temp paths | Manual `rm` in ad-hoc traps |
| `validate_kernel_dir "$KERNEL_DIR"` before kconfig ops | Assume the kernel dir exists |
| `rg` for file/code search | `grep -r` or `find` |
| `bash -n script.sh && shellcheck script.sh` before commit | Skipping lint |
| `/usr/bin/env bash` shebang | `/bin/bash` shebang |

---

## Output Functions

Always use these from `scripts/lib-common.sh` — never `echo` directly for user-facing output:

```bash
info  "Build complete"          # green  — success / progress
warn  "ccache not found"        # yellow — non-fatal, continues
msg   "Applying patches..."     # cyan   — informational / neutral
die   "Kernel dir not found"    # red    — fatal, exits immediately
debug "Loop iteration: $i"      # magenta — only shown when DEBUG=1
```

---

## Naming

| Context | Convention | Example |
|---------|-----------|---------|
| Lib functions | `snake_case` | `validate_kernel_dir` |
| `kernel-builder.sh` commands | `PascalCase` | `BuildCatgirl` |
| Constants / exports | `UPPER_CASE` | `MAX_PARALLEL` |
| Local variables | `lower_case` | `kdir` |
| PKGBUILD user vars | `_leading_underscore` | `_cpusched` |
| Patch files | `kebab-case.patch` or `<hash>.patch` | `bore-sched-6.18.patch` |
| CachyMod configs | `<ver>-<sched>.conf` | `618-bore.conf` |

---

## Where Things Go

| What you're adding | Where it goes |
|--------------------|---------------|
| Shared bash helpers | `scripts/lib-common.sh` |
| Kernel kconfig functions | `scripts/lib-kernel-config.sh` |
| Patches for kernel 6.18 | `6.18/<name>.patch` + entry in `6.18/patches.txt` |
| Patches for other versions | `<ver>/<name>.patch` + `<ver>/patches.txt` |
| New PKGBUILD variant | `build/<name>/PKGBUILD` + `build/<name>/config` |
| CachyMod patches | `build/cachymod/6.18/*.patch` |
| Pre-made CachyMod configs | `build/cachymod/defconfigs/<ver>-<sched>.conf` |

---

## PKGBUILD Pattern

All user-tunable variables use colon-expansion so they can be overridden from the environment:

```bash
: "${_cpusched:=bore}"       # bore | eevdf | bmq | rt | rt-bore
: "${_use_llvm_lto:=thin}"   # none | thin | full
: "${_optimize:=O3}"         # O2 | O3 | Os | Ofast
: "${_march:=native}"        # CPU target (native, x86-64, x86-64-v3, x86-64-v4)
: "${_localmodcfg:=no}"      # yes = use modprobed-db for minimal kernel
: "${_makenconfig:=no}"      # yes = pause for interactive nconfig
```

---

## Kconfig Helper Pattern

All kernel config manipulation goes through `scripts/lib-kernel-config.sh`:

```bash
# Single option
apply_my_feature(){ _apply_config "$1" -e MY_FEATURE -d CONFLICTING_OPT; }

# Batch (preferred — fewer subprocess forks)
apply_my_feature(){
  _apply_config "$1" \
    -e MY_FEATURE_A \
    -e MY_FEATURE_B \
    -d CONFLICTING_OPT
}

# Call site (compile.sh or PKGBUILD)
apply_my_feature "$KERNEL_DIR"
```

---

## Error Handling Pattern

```bash
# Dependency check — dies with helpful message if any are missing
require_commands expac pacman makepkg curl

# Kernel source validation
validate_kernel_dir "$KERNEL_DIR"

# Temp directory with auto-cleanup
tmpdir=$(mktemp -d)
add_cleanup "$tmpdir"          # cleaned up on EXIT/INT/TERM automatically
```

---

## Parallel Download Pattern (fetch.sh style)

Use a rolling job window — not `wait` on all at once:

```bash
declare -i running=0
for url in "${urls[@]}"; do
  curl -fsSL "$url" -o "${url##*/}" &
  (( ++running >= MAX_PARALLEL )) && { wait -n; (( --running )); }
done
wait
```

---

## Common Build Commands

```bash
# Catgirl Edition
cd build/catgirl-edition && makepkg -scf --cleanbuild --skipchecksums

# CachyMod
cd build/cachymod/6.18
../confmod.sh            # interactive wizard → ~/.config/cachymod/<name>.conf
./build.sh <confname>    # build from saved config
./build.sh list          # list saved configs

# Docker multi-arch
./docker-build.sh [generic|v3|v4]

# Patch dry-run
patch -p1 --dry-run < 6.18/some.patch

# Syntax + lint
bash -n scripts/fetch.sh
shellcheck --enable=all scripts/fetch.sh
```

---

## CI/CD

| Workflow | Trigger | Action |
|----------|---------|--------|
| `build.yml` | Push to `linux-cachyos/PKGBUILD` or manual | Parallel GCC + Clang build; artifact upload |
| `fetch.yml` | Manual `workflow_dispatch` | Runs `scripts/fetch.sh` |

Build matrix: `_use_llvm_lto=none` (gcc) and `_use_llvm_lto=thin` (clang).
Pinned action versions: `actions/checkout@v6`, `actions/cache@v5`, `actions/upload-artifact@v7`.

---

## Never Commit

- `src/`, `pkg/`, `*.pkg.tar.zst`, `*.tar.xz`, `*.tar.zst` — build artifacts
- Untracked `.config` changes from `make menuconfig` sessions
- Hardcoded paths (use `$KERNEL_DIR`, `$SCRIPT_DIR`, `$HOME`)
