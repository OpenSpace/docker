#!/bin/bash

# A shell script that will perform a build. It has an optional arguments to determine the branch.

if [ $# -gt 1 ]; then
  echo "Usage: $0 [branch]" >&2
  exit 1
fi

branch="${1:-master}"

# Clone the Git repository with 8 threads. We also only want the most recent commit
git clone --recursive --jobs 8 --depth 1 --shallow-submodules --branch "$branch" https://github.com/OpenSpace/OpenSpace
cd OpenSpace

# Build
cmake --preset linux-ninja-debug
cmake --build --preset linux-ninja-debug
