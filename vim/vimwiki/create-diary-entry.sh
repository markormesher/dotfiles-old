#! /usr/bin/env bash
set -euo pipefail

cd ~/vimwiki/diary

# clear up old entries if they weren't used
( grep -Ril '// auto-generated diary entry' . || : ) | while read -r file; do
  rm -v "${file}"
done

# create an entry for today
curr_date=$(date +%Y-%m-%d)
new_file="$(pwd)/${curr_date}.md"
if [ ! -f "${new_file}" ]; then
  cp ~/dotfiles/vim/vimwiki/diary-skeleton.md "${new_file}"
  sed -i "s/{DATE}/${curr_date}/" "${new_file}"
  echo "Created ${new_file}"
else
  echo "${new_file} already exists"
fi

# update links
nvim ~/vimwiki/diary/diary.md +:VimwikiDiaryGenerateLinks +:q
