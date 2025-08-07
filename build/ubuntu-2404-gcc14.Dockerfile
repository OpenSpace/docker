FROM ubuntu:24.04

RUN apt update


# Get a supported version for CMake and install
RUN apt install -y wget
RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.sh -q -O /tmp/cmake-install.sh
RUN chmod u+x /tmp/cmake-install.sh
RUN mkdir /opt/cmake
RUN /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake
RUN ln -s /opt/cmake/bin/* /usr/local/bin


# Set up the compiler
RUN apt install -y build-essential
RUN apt install -y git


## Install GCC 14 and enable
RUN apt install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/ppa
RUN apt update

RUN apt install -y gcc-14 g++-14
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 110 --slave /usr/bin/g++ g++ /usr/bin/g++-13 --slave /usr/bin/gcov gcov /usr/bin/gcov-13
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 120 --slave /usr/bin/g++ g++ /usr/bin/g++-14 --slave /usr/bin/gcov gcov /usr/bin/gcov-14


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
