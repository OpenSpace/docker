FROM ubuntu:22.04

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


## Build GCC 14 and enable
RUN apt install -y libmpfr-dev libgmp3-dev libmpc-dev
RUN wget http://ftp.gnu.org/gnu/gcc/gcc-14.3.0/gcc-14.3.0.tar.gz
RUN tar -xf gcc-14.3.0.tar.gz
WORKDIR "/gcc-14.3.0"
RUN ./configure -v --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --prefix=/usr/local/gcc-14.3.0 --enable-languages=c,c++ --disable-multilib --program-suffix=-14.3.0
RUN make -j4

WORKDIR "/"

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 110 --slave /usr/bin/g++ g++ /usr/bin/g++-11 --slave /usr/bin/gcov gcov /usr/bin/gcov-11
RUN update-alternatives --install /usr/bin/gcc gcc /usr/local/gcc-14.3.0/bin/gcc-14.3.0 120 --slave /usr/bin/g++ g++ /usr/local/gcc-14.3.0/bin/g++-14.3.0 --slave /usr/bin/gcov gcov /usr/local/gcc-14.3.0/bin/gcov-14.3.0 gcov


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
