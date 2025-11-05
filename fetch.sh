#!/usr/bin/env bash
LC_ALL=C
# Define sources and targets
declare -A files=(
  [6.12]=""
  [6.17]=""
  [6.18]=""
)
# Fetch each file
for t in "${!files[@]}"; do
  curl -fsL "${files[$t]}" -o "${t}.tmp" && mv "${t}.tmp" "$t"
done
# git commit if changes
git add lists/
if ! git diff --cached --quiet --ignore-blank-lines -abw; then
  git -c user.name="sync-bot" -c user.email="sync@localhost" commit -m "chore: update blocklists"
  git push
fi
