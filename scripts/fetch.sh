#!/usr/bin/env bash
set -eo pipefail
LC_ALL=C

# Lists to process: [list_url]="target_dir"
declare -A lists=(
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.17/Patches"]="lists/6.17"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.12/Patches"]="lists/6.12"
)

fetch_list(){
  local url=$1 dir=$2
  mkdir -p "$dir"
  local list
  list=$(curl -fsSL "$url") || { echo "Failed: $url" >&2; return 1; }
  
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*# ]] && continue
    [[ $line =~ ^[[:space:]]*$ ]] && continue
    
    local src dest
    if [[ $line =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+)$ ]]; then
      src=${BASH_REMATCH[1]}
      dest=${BASH_REMATCH[2]}
    else
      src=$line
      dest=$(basename "$line")
    fi
    
    curl -fsSL "$src" -o "${dir}/${dest}.tmp" && mv "${dir}/${dest}.tmp" "${dir}/${dest}" || {
      echo "Failed: $src" >&2
      rm -f "${dir}/${dest}.tmp"
    }
  done <<<"$list"
}

for url in "${!lists[@]}"; do
  fetch_list "$url" "${lists[$url]}"
done
