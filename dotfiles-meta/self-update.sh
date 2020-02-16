#! /usr/bin/env bash
set -euo pipefail

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "${current_branch}" != "master" ]]; then
  echo "Not on master branch - exiting early"
  exit 0
fi

if [[ ! -z "$(git status --porcelain)" ]]; then
  echo "Git environment is not clean - exiting early"
  exit 0
fi

git pull
