FROM ubuntu:26.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

# Set up the compiler
RUN apt-get install -y cmake build-essential git ninja-build

# Set up vcpkg
RUN apt-get install -y curl zip unzip autoconf autoconf-archive automake libtool python3 bison flex pkg-config

# Prepare vcpkg
RUN git clone https://github.com/microsoft/vcpkg /vcpkg
RUN /vcpkg/bootstrap-vcpkg.sh -disableMetrics
ENV VCPKG_ROOT=/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"
ENV VCPKG_DISABLE_METRICS=1

# Install OpenSpace dependencies
RUN apt-get install -y libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev libwayland-dev wayland-protocols libx11-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-xinput-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-cursor-dev libegl-dev libgl-dev libdbus-1-dev libatspi2.0-dev libxrandr-dev libxxf86vm-dev libxinerama-dev libxcursor-dev xorg-dev libmpv-dev libnss3 libnspr4 xvfb libgl1-mesa-dri

# Setting up the environment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY --chmod=755 data/build.sh /
WORKDIR "/"
