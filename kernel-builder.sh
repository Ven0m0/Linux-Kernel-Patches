#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
export LC_ALL=C LANG=C DEBIAN_FRONTEND=noninteractive HOME="${HOME:-/home/${SUDO_USER:-$USER}}"

VERSION="1.0.0"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

#──────────── Color & Style ────────────
RED=$'\e[31m' GRN=$'\e[32m' YLW=$'\e[33m' DEF=$'\e[0m'
BLU=$'\e[34m' MGN=$'\e[35m' CYN=$'\e[36m' BLD=$'\e[1m'
LBLU=$'\e[38;5;117m' PNK=$'\e[38;5;218m' BWHT=$'\e[97m'

#──────────── Helpers ──────────────────
has(){ command -v "$1" &>/dev/null; }
die(){ printf '%b\n' "${RED}Error:${DEF} $*" >&2; exit 1; }
info(){ printf '%b\n' "${GRN}$*${DEF}"; }
warn(){ printf '%b\n' "${YLW}$*${DEF}"; }
msg(){ printf '%b\n' "${CYN}$*${DEF}"; }
readonly CURL_OPTS=(-fLSs --http2 --proto '=https' --tlsv1.2 --compressed --connect-timeout 15 --retry 3 --retry-delay 2 --retry-max-time 60 --progress-bar)
fetch(){ local url=$1 out=${2:-}; local opts=("${CURL_OPTS[@]}"); [[ -n $out ]] && opts+=(-o "$out"); curl "${opts[@]}" "$url"; }

#──────────── PORTED/ADAPTED FROM AKM ─────────────────
LocalVersion(){ # e.g. LocalVersion linux
  local pkg="${1##*/}"
  if has expac; then
    expac -Q %v "$pkg" 2>/dev/null || printf ''
  else
    pacman -Q "$pkg" 2>/dev/null | awk '{print $2}'
  fi
}
Exist(){ local version="$1"; [[ -n "$version" ]] && printf TRUE || printf FALSE; }
UniqueArr(){ # de-duplicate list, usage: UniqueArr arr
  local -n arr="$1"
  local to=(); local xx yy
  for xx in "${arr[@]}"; do
    for yy in "${to[@]}"; do [[ "$xx" == "$yy" ]] && break; done
    [[ "$xx" != "$yy" ]] && to+=("$xx")
  done
  arr=("${to[@]}")
}
AvailableKernelsAndHeaders(){ # Print available kernels (Arch-family, CLI)
  if ! has expac; then die "expac required for kernel package detection"; fi
  local headers kernels kernel header
  headers=($(expac -Ss '%r/%n' 'linux[-]*[^ pi]*-headers' \
    | grep -Pv 'testing/linux-|linux-api-headers'))
  for header in "${headers[@]}"; do
    kernel="${header%-headers}"
    printf "%s %s\n" "$kernel" "$header"
  done
  [[ -v akm_kernels_headers_user ]] && [[ "${#akm_kernels_headers_user[@]}" -gt 0 ]] && printf "%s\n" "${akm_kernels_headers_user[@]}"
}
akm_load_config(){
  local conf=/etc/akm.conf
  [[ -f $conf ]] || return
  # shellcheck disable=SC1090
  source "$conf"
  [[ -n "${KERNEL_HEADER_WITH_KERNEL:-}" ]] && connect_header_with_kernel="$KERNEL_HEADER_WITH_KERNEL"
  [[ -n "${AKM_KERNELS_HEADERS:-}" ]] && akm_kernels_headers_user=("${AKM_KERNELS_HEADERS[@]}")
  [[ -n "${AKM_WINDOW_WIDTH:-}" ]] && akm_window_width="$AKM_WINDOW_WIDTH"
  [[ -n "${AKM_PREFER_SMALL_WINDOW:-}" ]] && small_font="$AKM_PREFER_SMALL_WINDOW"
}
parse_repo_type(){
  if has pacman-conf && pacman-conf --repo-list | grep -q "\-testing$"; then
    echo "Testing"
  else
    echo "Stable"
  fi
}
#─────────────────────────────────────────────

#──────────── Usage ────────────────────
show_usage(){
  cat <<EOF
${GRN}Usage:${DEF} ${0##*/} [command] [options]

${YLW}Commands:${DEF}
  ${CYN}catgirl${DEF}         Build optimized catgirl-edition kernel
  ${CYN}tkg${DEF}             Build TKG (Frogging-Family) packages
  ${CYN}patches${DEF}         Manage and apply kernel patches
  ${CYN}list${DEF}            List available patches by version
  ${CYN}kernels${DEF}         List available installed/packaged kernels [ADDED]
  ${CYN}help${DEF}            Show this help message
EOF
}

#───── Kernel/Package Info & List/Install (AKM-inspired) ─────
list_kernels(){
  info "Available Kernel Packages (Arch-family style):"
  local kernels=()
  mapfile -t kernels < <(AvailableKernelsAndHeaders)
  local item ix=0
  for item in "${kernels[@]}"; do
    ((ix++))
    set -- $item
    printf "  %s) %s\n     %s\n" "$ix" "$1" "$2"
    v1=$(LocalVersion "$1")
    v2=$(LocalVersion "$2")
    printf "     %s: %s\n     %s: %s\n" "$1" "${v1:-not installed}" "$2" "${v2:-not installed}"
    exist1=$(Exist "$v1")
    exist2=$(Exist "$v2")
    printf "     Installed: %s (kernel) %s (headers)\n" "$exist1" "$exist2"
    echo
  done
}

#──────────── Main Command Handling ────────────────
main(){
  cd "$SCRIPT_DIR"
  [[ $# -eq 0 ]] && show_usage && exit 1
  case $1 in
    catgirl) shift; build_catgirl "$@" ;;
    tkg) shift; build_tkg "$@" ;;
    patches) shift; manage_patches "$@" ;;
    compile) bash scripts/compile.sh ;;
    config) bash scripts/config.sh ;;
    fetch) bash scripts/fetch.sh ;;
    list) list_patches ;;
    kernels) list_kernels ;; # ADDED
    help|--help|-h) show_usage ;;
    *) die "Unknown command: $1"; show_usage ;;
  esac
}
main "$@"
