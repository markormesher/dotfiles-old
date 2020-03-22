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

  # we're going to edit some files, so we'll work on a copies of them
  edited_input=$(mktemp)
  edited_header=$(mktemp)
  edited_before_body=$(mktemp)
  edited_after_body=$(mktemp)
  cat "${file}" > "${edited_input}"
  cat "${script_dir}/include-in-header.html" > "${edited_header}"
  cat "${script_dir}/include-before-body.html" > "${edited_before_body}"
  cat "${script_dir}/include-after-body.html" > "${edited_after_body}"

  # convert < and > symbols
  sed -i 's/[^^]>/\&gt;/g' "${edited_input}"
  sed -i 's/</\&lt;/g' "${edited_input}"

  # convert partially complete checkboxes
  sed -i 's/\[[.oO]\]/[ ]/g' "${edited_input}"

  # convert unlinked urls
  sed -E -i 's#((https?://[-a-z0-9.]*[-a-z0-9])(/\S*[^?!., ])?)#[\2/~/](\1)#g' "${edited_input}"

  # rendered date
  render_date=$(date +"%Y-%m-%d %H:%M:%S")
  sed -i "s|{DATE}|${render_date}|" "${edited_after_body}"

  # remove "back to root" on root page
  if [[ "${basename_no_ext}" = "index" ]]; then
    sed -i '/.*Back to Root.*/d' "${edited_before_body}" "${edited_after_body}"
  fi

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
    --include-in-header "${edited_header}" \
    --include-before-body "${edited_before_body}" \
    --include-after-body "${edited_after_body}"

  # update .md links to .html
  sed -i 's/.md"/.html")/g' "${html_output}"

  rm "${edited_input}" "${edited_header}" "${edited_after_body}" "${edited_before_body}"
done
