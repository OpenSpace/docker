#!/bin/bash

# A shell script that will perform a build. It has to optional arguments:
#   0: The branch to build (defaults to "master")
#   1: The repository to build (defaults to "https://github.com/OpenSpace/OpenSpace")

args_array=("$@")
if [ ${#args_array[@]} -eq 0 ]; then
  args_array+=("master")
fi

if [ ${#args_array[@]} -eq 1 ]; then
  args_array+=("https://github.com/OpenSpace/OpenSpace")
fi

# Clone the Git repository with 8 threads. We also only want the most recent commit
git clone --recursive --jobs 8 --depth 1 --branch "${args_array[0]}" https://github.com/OpenSpace/OpenSpace
cd OpenSpace && mkdir build

# Build
cmake -S . -B ./build
cmake --build build --parallel 8
