#! /usr/bin/env bash
set -euo pipefail

cd ~/vimwiki/diary

# clear up old entries if they weren't used
( grep -Ril '// auto-generated diary entry' . || : ) | while read -r file; do
  rm -v "${file}"
done

# create an entry for today
curr_date=$(date +%Y-%m-%d)
cp ~/dotfiles/vim/vimwiki/diary-skeleton.md "./${curr_date}.md"
sed -i "s/{DATE}/${curr_date}/" "./${curr_date}.md"
echo "Created $(pwd)/${curr_date}.md"
