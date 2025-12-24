#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# =============================================================================
# Common Library for Kernel Build Scripts
# Shared functions, variables, and boilerplate to eliminate duplication
# =============================================================================
#
# Usage: Source this file at the top of your scripts
#   source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"
#
# What this provides:
#   - Strict error handling (set -euo pipefail)
#   - Common shell options and environment
#   - Helper functions (has, die, info, warn, msg, etc.)
#   - Color definitions for output
#   - Directory/path resolution utilities
#   - curl/fetch utilities
# =============================================================================

# Guard against multiple sourcing
[[ -v __LIB_COMMON_LOADED ]] && return 0
readonly __LIB_COMMON_LOADED=1

# =============================================================================
# STRICT ERROR HANDLING & SHELL OPTIONS
# =============================================================================
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'

# =============================================================================
# PATH RESOLUTION
# =============================================================================
# Resolve script directory (works even when sourced)
__resolve_script_dir(){
  local s="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  [[ $s != /* ]] && s=$PWD/$s
  cd -P -- "${s%/*}" && pwd
}

# Set SCRIPT_DIR if not already set
: "${SCRIPT_DIR:=$(__resolve_script_dir)}"
export SCRIPT_DIR

# =============================================================================
# COLOR DEFINITIONS
# =============================================================================
# Standard colors
readonly RED=$'\e[31m'
readonly GRN=$'\e[32m'
readonly YLW=$'\e[33m'
readonly BLU=$'\e[34m'
readonly MGN=$'\e[35m'
readonly CYN=$'\e[36m'
readonly DEF=$'\e[0m'

# Extended colors
readonly BLD=$'\e[1m'
readonly LBLU=$'\e[38;5;117m'
readonly PNK=$'\e[38;5;218m'
readonly BWHT=$'\e[97m'

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Command existence cache for performance
declare -A __HAS_CACHE=()

# Check if command exists (cached for performance)
has(){
  local cmd=$1
  # Return cached result if available
  if [[ -n ${__HAS_CACHE[$cmd]:-} ]]; then
    return "${__HAS_CACHE[$cmd]}"
  fi

  # Check and cache result
  if command -v "$cmd" &>/dev/null; then
    __HAS_CACHE[$cmd]=0
    return 0
  else
    __HAS_CACHE[$cmd]=1
    return 1
  fi
}

# Print error and exit
die(){
  printf '%b\n' "${RED}Error:${DEF} $*" >&2
  exit 1
}

# Print info message (green)
info(){ printf '%b\n' "${GRN}$*${DEF}"; }

# Print warning message (yellow)
warn(){ printf '%b\n' "${YLW}$*${DEF}"; }

# Print regular message (cyan)
msg(){ printf '%b\n' "${CYN}$*${DEF}"; }

# Print debug message (only if DEBUG=1)
debug(){
  [[ ${DEBUG:-0} -eq 1 ]] && printf '%b\n' "${MGN}[DEBUG]${DEF} $*" >&2
}

# Require root privileges
require_root(){
  [[ $EUID -eq 0 ]] || die "This script must be run as root"
}

# Require non-root
require_user(){
  [[ $EUID -ne 0 ]] || die "This script must NOT be run as root"
}

# =============================================================================
# CURL/FETCH UTILITIES
# =============================================================================

# Default curl options for secure, reliable downloads
readonly CURL_OPTS=(
  -fLSs
  --http2
  --proto '=https'
  --tlsv1.2
  --compressed
  --connect-timeout 15
  --retry 3
  --retry-delay 2
  --retry-max-time 60
  --progress-bar
)

# Fetch URL to file or stdout
# Usage: fetch <url> [output_file]
fetch(){
  local url=$1 out=${2:-}
  local opts=("${CURL_OPTS[@]}")
  [[ -n $out ]] && opts+=(-o "$out")
  curl "${opts[@]}" "$url"
}

# =============================================================================
# ARRAY UTILITIES
# =============================================================================

# Remove duplicates from array (preserves order)
# Usage: UniqueArr array_name
UniqueArr(){
  local -n arr="$1"
  local to=() xx
  declare -A seen
  for xx in "${arr[@]}"; do
    [[ -z ${seen[$xx]:-} ]] && to+=("$xx")
    seen[$xx]=1
  done
  arr=("${to[@]}")
}

# =============================================================================
# FILE/DIRECTORY UTILITIES
# =============================================================================

# Ensure directory exists
ensure_dir(){
  local dir=$1
  [[ -d $dir ]] || mkdir -p "$dir"
}

# Cleanup temporary files/directories on exit
# Usage: Add paths to __CLEANUP_PATHS array
declare -a __CLEANUP_PATHS=()

__cleanup_handler(){
  for path in "${__CLEANUP_PATHS[@]}"; do
    [[ -e $path ]] && rm -rf "$path"
  done
}

trap __cleanup_handler EXIT INT TERM

# Add path to cleanup list
add_cleanup(){
  __CLEANUP_PATHS+=("$1")
}

# =============================================================================
# VALIDATION UTILITIES
# =============================================================================

# Validate kernel source directory
validate_kernel_dir(){
  local kdir="${1:?Kernel source directory required}"
  [[ -d $kdir ]] || die "Kernel directory not found: $kdir"
  [[ -f $kdir/Makefile ]] || die "Not a kernel source tree: $kdir"
  grep -q "^VERSION = " "$kdir/Makefile" || die "Invalid kernel Makefile: $kdir/Makefile"
}

# Check required commands
require_commands(){
  local cmd missing=()
  for cmd in "$@"; do
    has "$cmd" || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    die "Required commands not found: ${missing[*]}"
  fi
}

# =============================================================================
# VERSION/PACKAGE UTILITIES (for Arch-based systems)
# =============================================================================

# Get installed package version
get_package_version(){
  local pkg="${1##*/}"
  if has expac; then
    expac -Q %v "$pkg" 2>/dev/null || echo ""
  elif has pacman; then
    pacman -Q "$pkg" 2>/dev/null | awk '{print $2}'
  else
    echo ""
  fi
}

# Check if package is installed
is_installed(){
  local pkg="${1##*/}"
  [[ -n $(get_package_version "$pkg") ]]
}

# =============================================================================
# LOGGING UTILITIES
# =============================================================================

# Log to file with timestamp
# Usage: log_file <file> <message>
log_file(){
  local file=$1; shift
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$file"
}

# =============================================================================
# PARALLEL EXECUTION UTILITIES
# =============================================================================

# Track background PIDs for parallel execution
declare -a __BG_PIDS=()

# Wait for all background jobs
wait_all(){
  if [[ ${#__BG_PIDS[@]} -gt 0 ]]; then
    wait "${__BG_PIDS[@]}" 2>/dev/null || true
    __BG_PIDS=()
  fi
}

# Run command in background and track PID
run_bg(){
  "$@" &
  __BG_PIDS+=($!)
}

# =============================================================================
# INIT COMPLETE
# =============================================================================
debug "lib-common.sh loaded from: $SCRIPT_DIR"
