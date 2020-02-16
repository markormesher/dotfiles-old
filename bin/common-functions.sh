TXT_BOLD="$(if [[ -t 1 ]]; then tput bold; fi)"
TXT_BLACK="$(if [[ -t 1 ]]; then tput setaf 0; fi)"
TXT_RED="$(if [[ -t 1 ]]; then tput setaf 1; fi)"
TXT_GREEN="$(if [[ -t 1 ]]; then tput setaf 2; fi)"
TXT_YELLOW="$(if [[ -t 1 ]]; then tput setaf 3; fi)"
TXT_BLUE="$(if [[ -t 1 ]]; then tput setaf 3; fi)"
TXT_MAGENTA="$(if [[ -t 1 ]]; then tput setaf 5; fi)"
TXT_CYAN="$(if [[ -t 1 ]]; then tput setaf 6; fi)"
TXT_RESET="$(if [[ -t 1 ]]; then tput sgr0; fi)"

function print_debug {
  if [ ! -z ${DEBUG+x} ]; then
    echo "[ dotfiles ][ ${TXT_MAGENTA}${TXT_BOLD}DEBUG${TXT_RESET} ]  ${1}"
  fi
}

function print_info {
  echo "[ dotfiles ][ ${TXT_CYAN}${TXT_BOLD}INFO${TXT_RESET} ]  ${1}"
}

function print_warn {
  echo "[ dotfiles ][ ${TXT_YELLOW}${TXT_BOLD}WARN${TXT_RESET} ]  ${1}"
}

function print_error {
  echo "[ dotfiles ][ ${TXT_RED}${TXT_BOLD}ERROR${TXT_RESET} ]  ${1}"
}

# check for the dependencies needed to run the dotfiles project itself
if [[ "${OSTYPE}" == "darwin"* ]]; then
  if ! command -v brew > /dev/null; then
    print_error "Please install brew and coreutils before using the dotfiles project"
    exit 1
  fi

  if ! command -v gsed > /dev/null; then
    print_error "Please install coreutils before using the dotfiles project"
    exit 1
  fi
fi

function host_has_tag {
  tag="$1"
  "${HOME}/dotfiles/bin/get-host-tags" | grep -e '^'"${tag}"'$' > /dev/null 2>&1
}

function file_matches_host_tags {
  file="$1"
  tags=$(cat "${file}" | (grep " dot-tags " || :) | cut -d ' ' -f 3-)
  for tag in ${tags}; do
    if ! host_has_tag "${tag}"; then
      return 1
    fi
  done
  return 0
}
