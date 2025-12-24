#!/usr/bin/env bash
# shellcheck enable=all shell=bash source-path=SCRIPTDIR external-sources=true
# shellcheck source=./lib-common.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-common.sh"

declare -A lists=(
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.17/patches.txt"]="lists/6.17"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.12/patches.txt"]="lists/6.12"
  ["https://raw.githubusercontent.com/Ven0m0/Linux-Kernel-Patches/main/6.18/patches.txt"]="lists/6.18"
)
readonly MAX_PARALLEL=${MAX_PARALLEL:-4}

fetch_file(){
  local src="$1" dest="$2"
  debug "Fetching: $src -> $dest"
  if fetch "$src" "${dest}.tmp" &>/dev/null; then
    mv "${dest}.tmp" "$dest"
    info "✓ $(basename "$dest")"
    return 0
  else
    warn "✗ Failed: $(basename "$src")"
    rm -f "${dest}.tmp"
    return 1
  fi
}

fetch_list(){
  local url="$1" dir="$2" list
  ensure_dir "$dir"

  info "Fetching patch list from: $url"
  list=$(fetch "$url") || { warn "Failed to fetch list: $url"; return 1; }

  local -a files=() srcs=() dests=()
  local line src dest

  # Parse list and build arrays
  while IFS= read -r line; do
    [[ $line =~ ^[[:space:]]*#|^[[:space:]]*$ ]] && continue
    if [[ $line =~ ^([^[:space:]]+)[[:space:]]+([^[:space:]]+)$ ]]; then
      src=${BASH_REMATCH[1]}
      dest=${BASH_REMATCH[2]}
    else
      src=$line
      # Use parameter expansion instead of basename subprocess
      dest="${line##*/}"
    fi
    srcs+=("$src")
    dests+=("${dir}/${dest}")
  done <<<"$list"

  # Download in parallel with rolling window
  local idx=0 active=0
  local -a pids=()

  while ((idx < ${#srcs[@]})) || ((${#pids[@]} > 0)); do
    # Start new jobs up to MAX_PARALLEL
    while ((idx < ${#srcs[@]}) && (${#pids[@]} < MAX_PARALLEL)); do
      fetch_file "${srcs[$idx]}" "${dests[$idx]}" &
      pids+=($!)
      ((idx++))
    done

    # Wait for any job to complete (more efficient than waiting for all)
    if ((${#pids[@]} > 0)); then
      wait -n "${pids[@]}" 2>/dev/null || true
      # Remove completed PID from array
      local -a new_pids=()
      for pid in "${pids[@]}"; do
        kill -0 "$pid" 2>/dev/null && new_pids+=("$pid")
      done
      pids=("${new_pids[@]}")
    fi
  done

  info "Completed fetching ${#srcs[@]} files to $dir"
}

for url in "${!lists[@]}"; do fetch_list "$url" "${lists[$url]}"; done
