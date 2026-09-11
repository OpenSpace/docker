FROM ubuntu:26.04

RUN apt update

# Set up the compiler
RUN apt install -y cmake
RUN apt install -y build-essential
RUN apt install -y git

# Set up vcpkg
RUN apt install -y curl
RUN apt install -y zip
RUN apt install -y unzip
RUN apt install -y autoconf
RUN apt install -y autoconf-archive
RUN apt install -y automake
RUN apt install -y libtool

WORKDIR "/"

# Install the remaining OpenSpace dependencies
RUN apt install -y freeglut3-dev
RUN apt install -y libxrandr-dev
RUN apt install -y libxinerama-dev
RUN apt install -y xorg-dev
RUN apt install -y libxcursor-dev
RUN apt install -y libxi-dev
RUN apt install -y libasound2-dev
RUN apt install -y libgdal-dev
RUN apt install -y qt6-base-dev
RUN apt install -y libmpv-dev
RUN apt install -y libvulkan-dev

# Install dependencies for running unit tests
RUN apt install -y xvfb


# Setting up the enviroment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY data/build.sh /


# Prepare vcpkg
WORKDIR /vcpkg
RUN git clone https://github.com/microsoft/vcpkg .
RUN ./bootstrap-vcpkg.sh -disableMetrics
ENV VCPKG_ROOT=/vcpkg
# /mnt/vcpkg-cache must be provided by the Docker host
ENV VCPKG_DEFAULT_BINARY_CACHE=/mnt/vcpkg-cache
ENV PATH="${VCPKG_ROOT}:${PATH}"
