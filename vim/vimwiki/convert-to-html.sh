#! /usr/bin/env bash
set -euo pipefail

if [[ ! $(hostname) = chuck ]]; then
  exit 0
fi

vimwiki_dir="${HOME}/vimwiki"
html_dir="/var/web/wiki.markormesher.co.uk/html"
script_dir="${HOME}/dotfiles/vim/vimwiki"

# prepare the output directory
mkdir -p "${html_dir}"
rm -rf "${html_dir}/"*

# copy all media
cp -r "${vimwiki_dir}/media" "${html_dir}/."

find "${vimwiki_dir}" -type f -name '*.md' | while read file; do
  file_no_ext=$(echo "${file}" | rev| cut -d '.' -f 2- | rev)
  basename_no_ext=$(basename "${file}" | rev | cut -d '.' -f 2- | rev)

  # we're going to edit the input, so we'll work on a copy of it
  edited_input=$(mktemp)
  cat "${file}" > "${edited_input}"

  # convert < and > symbols
  sed -i 's/[^^]>/\&gt;/g' "${edited_input}"
  sed -i 's/</\&lt;/g' "${edited_input}"

  # convert partially complete checkboxes
  sed -i 's/\[[.oO]\]/[ ]/g' "${edited_input}"

  # convert unlinked urls
  sed -E -i 's|(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*))|[\1](\1)|g' "${edited_input}"

  html_output="${html_dir}/${file_no_ext}.html"
  html_output=$(echo "${html_output}" | sed "s#${vimwiki_dir}/##")
  mkdir -p $(dirname "${html_output}")

  pandoc \
    -i "${edited_input}" \
    -o "${html_output}" \
    -f markdown \
    -t html \
    --standalone \
    --metadata "pagetitle=${basename_no_ext}" \
    --include-in-header "${script_dir}/include-in-header.html" \
    --include-before-body "${script_dir}/include-before-body.html" \
    --include-after-body "${script_dir}/include-after-body.html"

  # update .md links to .html
  sed -i 's/.md"/.html")/g' "${html_output}"

  rm "${edited_input}"
done
