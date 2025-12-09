#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob globstar
IFS=$'\n\t'
LC_ALL=C LANG=C

# Lists to process: [list_url]="target_dir"
declare -A lists=(
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.17/patches.txt"]="lists/6.17"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.12/patches.txt"]="lists/6.12"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.18/patches.txt"]="lists/6.18"
)
# Maximum parallel downloads (adjust based on your connection)
readonly MAX_PARALLEL=${MAX_PARALLEL:-4}

fetch_file(){
  local src="$1" dest="$2"
  if curl -fsSL "$src" -o "${dest}.tmp" &>/dev/null; then
    mv "${dest}.tmp" "$dest"
  else
    echo "Failed: $src" >&2
    rm -f "${dest}.tmp"
    return 1
  fi
}

fetch_list(){
  local url="$1" dir="$2" list
  mkdir -p "$dir"
  list=$(curl -fsSL "$url") || {
    echo "Failed: $url" >&2
    return 1
  }
  local -a pids=()
  local job_count=0
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*# || $line =~ ^[[:space:]]*$ ]] && continue
    local src dest
    if [[ $line =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+)$ ]]; then
      src=${BASH_REMATCH[1]}
      dest=${BASH_REMATCH[2]}
    else
      src=$line
      dest=$(basename "$line")
    fi
    # Parallel download with job control
    fetch_file "$src" "${dir}/${dest}" &
    pids+=($!)
    ((job_count++))
    # Limit parallel jobs
    if ((job_count >= MAX_PARALLEL)); then
      wait "${pids[@]}"
      pids=()
      job_count=0
    fi
  done <<<"$list"
  # Wait for remaining jobs
  [[ ${#pids[@]} -gt 0 ]] && wait "${pids[@]}"
}
# Fetch all lists
for url in "${!lists[@]}"; do
  fetch_list "$url" "${lists[$url]}"
done
