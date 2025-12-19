#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
set -euo pipefail
shopt -s nullglob globstar
export LC_ALL=C
IFS=$'\n\t'
s=${BASH_SOURCE[0]}; [[ $s != /* ]] && s=$PWD/$s; cd -P -- "${s%/*}"
has(){ command -v -- "$1" &>/dev/null; }

declare -A lists=(
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.17/patches.txt"]="lists/6.17"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.12/patches.txt"]="lists/6.12"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.18/patches.txt"]="lists/6.18"
)
readonly MAX_PARALLEL=${MAX_PARALLEL:-4}

fetch_file(){
  local src="$1" dest="$2"
  if curl -fsSL "$src" -o "${dest}.tmp" &>/dev/null; then mv "${dest}.tmp" "$dest"
  else echo "Failed: $src" >&2; rm -f "${dest}.tmp"; return 1; fi
}

fetch_list(){
  local url="$1" dir="$2" list
  mkdir -p "$dir"
  list=$(curl -fsSL "$url") || { echo "Failed: $url" >&2; return 1; }
  local -a pids=()
  local job_count=0
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*#|^[[:space:]]*$ ]] && continue
    local src dest
    if [[ $line =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+)$ ]]; then src=${BASH_REMATCH[1]}; dest=${BASH_REMATCH[2]}
    else src=$line; dest=$(basename "$line"); fi
    fetch_file "$src" "${dir}/${dest}" &
    pids+=($!)
    ((job_count++))
    if ((job_count>=MAX_PARALLEL)); then wait "${pids[@]}"; pids=(); job_count=0; fi
  done <<<"$list"
  [[ ${#pids[@]} -gt 0 ]] && wait "${pids[@]}"
}

for url in "${!lists[@]}"; do fetch_list "$url" "${lists[$url]}"; done
