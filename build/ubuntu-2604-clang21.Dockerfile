FROM ubuntu:26.04
ARG DEBIAN_FRONTEND=noninteractive

# Set up the compiler
RUN apt-get update && apt-get install -y cmake build-essential git ninja-build && rm -rf /var/lib/apt/lists/*

# Set up vcpkg
RUN apt-get update && apt-get install -y curl zip unzip autoconf autoconf-archive automake libtool python3 bison flex pkg-config zip rpm dpkg && rm -rf /var/lib/apt/lists/*

# Prepare vcpkg. VCPKG_COMMIT is the "default-registry" baseline from OpenSpace's vcpkg.json
# When OpenSpace moves its baseline, either rebuild with
#   --build-arg VCPKG_COMMIT=<new baseline>
# or update the checkout from inside a running container with
#   git -C /vcpkg fetch --depth 1 origin <new baseline> && git -C /vcpkg checkout FETCH_HEAD
ARG VCPKG_COMMIT=04a9d8e5212d01ee1dd9478eadd9caade4f8b0d4
RUN git init -q /vcpkg && \
    git -C /vcpkg remote add origin https://github.com/microsoft/vcpkg && \
    git -C /vcpkg fetch --depth 1 -q origin ${VCPKG_COMMIT} && \
    git -C /vcpkg checkout -q FETCH_HEAD && \
    /vcpkg/bootstrap-vcpkg.sh -disableMetrics
ENV VCPKG_ROOT=/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"
ENV VCPKG_DISABLE_METRICS=1

# Set up Clang21
RUN apt-get update && apt-get install -y clang-21 clang-tools-21 clang-format-21 lldb-21 lld-21 libomp-21-dev libunwind-21-dev && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/clang++-21 /usr/bin/clang++
RUN ln -s /usr/bin/clang-21 /usr/bin/clang

ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++

# Install OpenSpace dependencies
RUN apt-get update && apt-get install -y perl libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev libwayland-dev wayland-protocols libx11-dev libxext-dev libxfixes-dev libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-xinput-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-cursor-dev libegl-dev libgl-dev libdbus-1-dev libatspi2.0-dev libxrandr-dev libxxf86vm-dev libxinerama-dev libxcursor-dev libmpv-dev libnss3 libnspr4 xvfb libgl1-mesa-dri && rm -rf /var/lib/apt/lists/*

# Install AppImage packaging tools. support/cmake/packaging.cmake locates these via
# find_program() on PATH, and support/cmake/appimage.cmake uses them to build the AppImage
# during `cpack --preset linux-appimage`. linuxdeploy and its Qt plugin only ever publish
# a rolling "continuous" release; appimagetool has real version tags, so the "latest"
# redirect is used for it instead so this doesn't need to be re-pinned.
RUN curl -fL --retry 3 -o /usr/local/bin/linuxdeploy https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage && \
    curl -fL --retry 3 -o /usr/local/bin/linuxdeploy-plugin-qt https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage && \
    curl -fL --retry 3 -o /usr/local/bin/appimagetool https://github.com/AppImage/appimagetool/releases/latest/download/appimagetool-x86_64.AppImage && \
    chmod +x /usr/local/bin/linuxdeploy /usr/local/bin/linuxdeploy-plugin-qt /usr/local/bin/appimagetool

# Setting up the environment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY --chmod=755 data/build.sh /
WORKDIR "/"
