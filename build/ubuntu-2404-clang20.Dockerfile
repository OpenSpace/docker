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
RUN apt install -y software-properties-common
RUN apt install -y gnupg
RUN apt install -y apt-transport-https
RUN apt install -y ca-certificates
ADD data/llvm-ubuntu-2404.list /etc/apt/sources.list.d/
ADD data/llvm-snapshot.gpg.key.gpg /etc/apt/trusted.gpg.d/
RUN mv /etc/apt/sources.list.d/llvm-ubuntu-2404.list /etc/apt/sources.list.d/llvm.list
RUN apt update
RUN apt install -y clang-20
RUN apt install -y clang-tools-20
RUN apt install -y clang-format-20
RUN apt install -y libfuzzer-20-dev
RUN apt install -y lldb-20
RUN apt install -y lld-20
RUN apt install -y libc++-20-dev
RUN apt install -y libc++abi-20-dev
RUN apt install -y libomp-20-dev
RUN apt install -y libunwind-20-dev
RUN apt install -y libpolly-20-dev
RUN apt install -y libclc-20-dev

RUN ln -s /usr/bin/clang++-20 /usr/bin/clang++
RUN ln -s /usr/bin/clang-20 /usr/bin/clang

ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++


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
