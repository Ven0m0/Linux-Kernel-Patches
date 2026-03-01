# GitHub Copilot Instructions — Linux Kernel Builder Suite

## Project

Unified Linux kernel build suite (Bash + Arch/CachyOS PKGBUILDs). No Node.js, no Python runtime dependency for builds.

## Key Commands

```bash
# Main entry point
./kernel-builder.sh [catgirl|cachymod|tkg|patches|fetch|help]

# Build Catgirl Edition
cd build/catgirl-edition && makepkg -scf --cleanbuild --skipchecksums

# Build CachyMod (interactive)
cd build/cachymod/6.18 && ../confmod.sh   # configure
./build.sh <confname>                      # build

# Fetch upstream patches
./scripts/fetch.sh

# Validate shell scripts
bash -n script.sh
shellcheck --enable=all script.sh

# Test patch application
patch -p1 --dry-run < 6.18/patch.patch
```

## Shell Script Conventions

Always source the shared library — never duplicate helpers:
```bash
#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=./lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"
```

**Output functions** (from `scripts/lib-common.sh`):
- `info "msg"` → green (success/progress)
- `warn "msg"` → yellow (non-fatal)
- `msg "msg"` → cyan (informational)
- `die "msg"` → red + exit 1 (fatal)

**Error handling**:
```bash
require_commands pacman makepkg   # check deps, die if missing
validate_kernel_dir "$KERNEL_DIR" # validate kernel source
die "reason"                      # fatal error, always prefer over bare exit 1
add_cleanup "/tmp/tempdir"        # register for auto-cleanup on EXIT
```

## Naming

- Functions: `snake_case` (lib funcs), `PascalCase` (kernel-builder.sh commands)
- Constants: `UPPER_CASE`; locals: `lower_case`
- PKGBUILD user vars: `_leading_underscore` with `": ${_var:=default}"` pattern
- Patches: `descriptive-kebab-case.patch` or `<git-hash>.patch`
- CachyMod configs: `<version>-<scheduler>.conf` (e.g., `618-bore.conf`)

## File Placement

| What | Where |
|------|-------|
| Shared bash utilities | `scripts/lib-common.sh` |
| Kernel kconfig helpers | `scripts/lib-kernel-config.sh` |
| Version-specific patches | `<version>/` (e.g., `6.18/`) |
| PKGBUILD variants | `build/<name>/PKGBUILD` + `build/<name>/config` |
| CachyMod patches | `build/cachymod/6.18/*.patch` |

## PKGBUILD User Variables

```bash
: "${_cpusched:=bore}"           # bore | eevdf | bmq | rt | rt-bore
: "${_use_llvm_lto:=thin}"       # none | thin | full
: "${_optimize:=O3}"             # O2 | O3 | Os | Ofast
: "${_march:=native}"            # CPU target
: "${_localmodcfg:=no}"          # yes = use modprobed-db
: "${_makenconfig:=no}"          # yes = launch nconfig before build
```

## CI/CD

- **Lint**: `super-linter` on push/PR to main — covers shellcheck, markdownlint
- **Build**: Tests `linux-cachyos` PKGBUILD with GCC and Clang on push to that path
- **Fetch**: Manual dispatch only — runs `scripts/fetch.sh`
- Actions use `actions/checkout@v6`, `actions/cache@v5`, `actions/upload-artifact@v7`

## Dependencies

`base-devel clang lld llvm gum fzf expac modprobed-db ccache`

## Do Not

- Copy color definitions or helper functions — source `lib-common.sh`
- Use bare `exit 1` — use `die "reason"`
- Skip shellcheck directives at script top
- Commit build artifacts (`src/`, `pkg/`, `*.pkg.tar.zst`, `*.tar.xz`)
