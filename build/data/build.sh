#!/bin/bash

# A shell script that will perform a build. It has an optional arguments to determine the branch.
# Extra arguments for the configure step can be passed through the OPENSPACE_CMAKE_ARGS
# environment variable, which the images use to switch off modules that cannot be built on
# that particular distribution.

if [ $# -gt 1 ]; then
  echo "Usage: $0 [branch]" >&2
  exit 1
fi

branch="${1:-master}"

# Clone the Git repository with 8 threads. We also only want the most recent commit
git clone --recursive --jobs 8 --depth 1 --shallow-submodules --branch "$branch" https://github.com/OpenSpace/OpenSpace
cd OpenSpace

# Split OPENSPACE_CMAKE_ARGS on whitespace so that each -D lands as its own argument
read -r -a extra_cmake_args <<< "${OPENSPACE_CMAKE_ARGS:-}"

# Build
cmake --preset linux-ninja-debug "${extra_cmake_args[@]}"
cmake --build --preset linux-ninja-debug
