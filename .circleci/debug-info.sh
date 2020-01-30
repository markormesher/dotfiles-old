#! /usr/bin/env bash
set -euo pipefail

echo
echo "whoami"
whoami

echo
echo "sudo -l"
sudo -l

echo
echo "pwd"
pwd

echo
echo "lsb_release -a"
lsb_release -a

echo
echo "ls -la"
ls -la
