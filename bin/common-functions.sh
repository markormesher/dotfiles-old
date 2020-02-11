function print_info {
  echo -e '\e[36m[ dotfiles ][ info ]\e[0m  '"${1}"
}

function print_error {
  echo -e '\e[31m[ dotfiles ][ error ]\e[0m  '"${1}"
}

# check for the dependencies needed to run the dotfiles project itself
if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v brew > /dev/null; then
    print_error "Please install brew and coreutils before using the dotfiles project"
    exit 1
  fi

  if ! command -v gsed > /dev/null; then
    print_error "Please install coreutils before using the dotfiles project"
    exit 1
  fi
fi

# make the dotfiles project work on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias sed="gsed"
  alias readlink="greadlink"
  alias grep="ggrep"
fi

function host_has_tag {
  tag="${1}"
  "${HOME}/dotfiles/bin/get-host-tags" | grep -e '^'"${tag}"'$' > /dev/null 2>&1
}

function file_matches_host_tags {
  file="${1}"
  tags=$(cat "${file}" | (grep "# dot-tags" || :) | cut -d ' ' -f 3-)
  for tag in ${tags}; do
    if ! host_has_tag "${tag}"; then
      return 1
    fi
  done
  return 0
}
