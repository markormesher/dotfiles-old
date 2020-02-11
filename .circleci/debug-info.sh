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
echo "cat /etc/os-release"
cat /etc/os-release

echo
echo "ls -la"
ls -la

echo
echo "get-host-tags"
./bin/get-host-tags
