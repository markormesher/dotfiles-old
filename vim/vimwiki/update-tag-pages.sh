#! /usr/bin/env bash
set -euo pipefail

if [[ ! $(hostname) = chuck ]]; then
  exit 0
fi

vimwiki_dir="${HOME}/vimwiki"
script_dir="${HOME}/dotfiles/vim/vimwiki"

function get_tag_page {
  tag="$1"
  echo "${vimwiki_dir}/tag/${tag/@/}.md"
}

function make_tag_page {
  tag="$1"
  tag_page=$(get_tag_page "${tag}")
  if [[ ! -f "${tag_page}" ]]; then
    echo "# ${tag}" > "${tag_page}"
  fi
}

# reset tag pages
mkdir -p "${vimwiki_dir}/tag"
rm -f "${vimwiki_dir}/tag/"*

# place to keep track of tagged file vs mentioning files
work_dir="$(mktemp -d)"

find "${vimwiki_dir}" -type f -name '*.md' -not -path '*/tag/*' | while read file; do
  file_no_ext=$(echo "${file}" | rev| cut -d '.' -f 2- | rev)
  basename_no_ext=$(basename "${file}" | rev | cut -d '.' -f 2- | rev)

  # find tags on the first line and track the tagged files
  if head -n 1 "${file}" | grep '@' > /dev/null; then
    head -n 1 "${file}" | grep -o -E '@[a-z\-]+' | while read tag; do
      echo "${file}" >> "${work_dir}/tagged-${tag}"
      echo "${tag}" >> "${work_dir}/all-tags"
    done
  fi

  # find tags on later lines and track the mentioning files
  tail -n +2 "${file}" | (grep -o -E '(^| )@[a-z\-]+' || :) | while read tag; do
    echo "${file}" >> "${work_dir}/mentioning-${tag}"
      echo "${tag}" >> "${work_dir}/all-tags"
  done
done

# handle directly tagged files first
find "${work_dir}" -name 'tagged-*' | while read file; do
  tag=$(basename "${file}" | sed 's/tagged-//')
  tag_page=$(get_tag_page "${tag}")
  make_tag_page "${tag}"
  echo "## Notes Tagged as ${tag}" >> "${tag_page}"
  echo "" >> "${tag_page}"
  cat "${file}" | sort | uniq | while read note; do
    title=$(cat "${note}" | grep '^#' | head -n 1 | sed 's/# //')
    link="/$(basename "${note}")"
    echo "- [${title}](${link})" >> "${tag_page}"
  done
  echo "" >> "${tag_page}"
done

# handle files that mention tags second
find "${work_dir}" -name 'mentioning-*' | while read file; do
  tag=$(basename "${file}" | sed 's/mentioning-//')
  tag_page=$(get_tag_page "${tag}")
  make_tag_page "${tag}"
  echo "## Notes Mentioning ${tag}" >> "${tag_page}"
  echo "" >> "${tag_page}"
  cat "${file}" | sort | uniq | while read note; do
    title=$(cat "${note}" | grep '^#' | head -n 1 | sed 's/# //')
    link="/$(basename "${note}")"
    echo "- [${title}](${link})" >> "${tag_page}"
  done
  echo "" >> "${tag_page}"
done

# update the index file
echo "# Mark's VimWiki" > "${vimwiki_dir}/index.md"
echo "" >> "${vimwiki_dir}/index.md"
echo "## Tags" >> "${vimwiki_dir}/index.md"
echo "" >> "${vimwiki_dir}/index.md"
cat "${work_dir}/all-tags" | sort | uniq | while read tag; do
  echo "[${tag}](/tag/${tag/@/})" >> "${vimwiki_dir}/index.md"
done
