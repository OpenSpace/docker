FROM fedora:38


# Get a supported version for CMake and install
RUN dnf install -y wget
RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.sh -q -O /tmp/cmake-install.sh
RUN chmod u+x /tmp/cmake-install.sh
RUN mkdir /opt/cmake
RUN /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake
RUN ln -s /opt/cmake/bin/* /usr/local/bin


# Set up the compiler
RUN dnf install -y make
RUN dnf install -y automake
RUN dnf install -y gcc
RUN dnf install -y gcc-c++
RUN dnf install -y git


# Install the remaining OpenSpace dependencies
RUN dnf install -y glfw-devel
RUN dnf install -y libXi-devel
RUN dnf install -y libXinerama-devel
RUN dnf install -y libXrandr-devel
RUN dnf install -y libXxf86vm-devel
RUN dnf install -y libcurl-devel
RUN dnf install -y mesa-libGLU-devel
RUN dnf install -y qt6-qtbase-devel
RUN dnf install -y gdal-devel
RUN dnf install -y harfbuzz-devel
RUN dnf install -y zziplib-devel
RUN dnf install -y mpv-devel


# Install dependencies for running unit tests
RUN dnf install -y xorg-x11-server-Xvfb


# Setting up the enviroment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY data/build.sh /
