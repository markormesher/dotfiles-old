#!/usr/bin/env bash

TXT_BOLD="`tput bold`"
TXT_BLACK="`tput setaf 0`"
TXT_RED="`tput setaf 1`"
TXT_GREEN="`tput setaf 2`"
TXT_YELLOW="`tput setaf 3`"
TXT_MAGENTA="`tput setaf 5`"
TXT_CYAN="`tput setaf 6`"
TXT_RESET="`tput sgr0`"

host=$(hostname)
time=$(date +"%F %H:%M:%S")

echo -n "[${host}] [${time}] "
