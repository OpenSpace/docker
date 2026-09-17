FROM ubuntu:26.04

RUN apt update

# Set up the compiler
RUN apt install -y cmake
RUN apt install -y build-essential
RUN apt install -y git
RUN apt install -y ninja-build

# Set up vcpkg
RUN apt install -y curl
RUN apt install -y zip
RUN apt install -y unzip
RUN apt install -y autoconf
RUN apt install -y autoconf-archive
RUN apt install -y automake
RUN apt install -y libtool

# Prepare vcpkg
RUN git clone https://github.com/microsoft/vcpkg /vcpkg
RUN /vcpkg/bootstrap-vcpkg.sh -disableMetrics
ENV VCPKG_ROOT=/vcpkg
# /mnt/vcpkg-cache must be provided by the Docker host
ENV VCPKG_DEFAULT_BINARY_CACHE=/mnt/vcpkg-cache
ENV PATH="${VCPKG_ROOT}:${PATH}"

# Install the remaining OpenSpace dependencies
RUN apt-get install -y pkg-config
RUN apt-get install -y '^libxcb.*-dev'
RUN apt-get install -y libx11-xcb-dev
RUN apt-get install -y libglu1-mesa-dev
RUN apt-get install -y libxrender-dev
RUN apt-get install -y libxi-dev
RUN apt-get install -y libxkbcommon-dev
RUN apt-get install -y libxkbcommon-x11-dev
RUN apt-get install -y libwayland-dev
RUN apt-get install -y wayland-protocols
RUN apt-get install -y libx11-dev
RUN apt-get install -y libx11-xcb-dev
RUN apt-get install -y libxext-dev
RUN apt-get install -y libxfixes-dev
RUN apt-get install -y libxi-dev
RUN apt-get install -y libxrender-dev
RUN apt-get install -y libxcb1-dev
RUN apt-get install -y libxcb-glx0-dev
RUN apt-get install -y libxcb-keysyms1-dev
RUN apt-get install -y libxcb-image0-dev
RUN apt-get install -y libxcb-shm0-dev
RUN apt-get install -y libxcb-icccm4-dev
RUN apt-get install -y libxcb-sync-dev
RUN apt-get install -y libxcb-xfixes0-dev
RUN apt-get install -y libxcb-shape0-dev
RUN apt-get install -y libxcb-randr0-dev
RUN apt-get install -y libxcb-render-util0-dev
RUN apt-get install -y libxcb-util-dev
RUN apt-get install -y libxcb-xinerama0-dev
RUN apt-get install -y libxcb-xkb-dev
RUN apt-get install -y libxcb-cursor-dev
RUN apt-get install -y libegl1-mesa-dev
RUN apt-get install -y libgl1-mesa-dev
RUN apt-get install -y libdbus-1-dev
RUN apt-get install -y libatspi2.0-dev
RUN apt-get install -y libxrandr-dev
RUN apt-get install -y libxxf86vm-dev
RUN apt-get install -y libxinerama-dev
RUN apt-get install -y libxcursor-dev
RUN apt-get install -y xorg-dev
RUN apt-get install -y libmpv-dev
RUN apt-get install -y libnss3
RUN apt-get install -y libnspr4
RUN apt install -y xvfb

# Setting up the enviroment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY data/build.sh /
WORKDIR "/"
