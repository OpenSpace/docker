FROM fedora:44

# Set up the compiler
RUN dnf install -y cmake gcc gcc-c++ git ninja-build

# Set up vcpkg
RUN dnf install -y curl zip unzip autoconf autoconf-archive automake libtool python3 bison flex pkg-config

# Prepare vcpkg
RUN git clone https://github.com/microsoft/vcpkg /vcpkg
RUN /vcpkg/bootstrap-vcpkg.sh -disableMetrics
ENV VCPKG_ROOT=/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"
ENV VCPKG_DISABLE_METRICS=1

# Install the remaining OpenSpace dependencies
RUN dnf install -y perl-core mesa-libGL-devel mesa-libGLU-devel libglvnd-devel libxcb-devel xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-renderutil-devel xcb-util-wm-devel xcb-util-cursor-devel libX11-xcb libXrender-devel libXi-devel libxkbcommon-devel libxkbcommon-x11-devel mesa-libEGL-devel fontconfig-devel freetype-devel wayland-devel wayland-protocols-devel libwayland-client libwayland-cursor libwayland-egl libXxf86vm-devel libXrandr-devel libXfixes-devel libXcomposite-devel libXdamage-devel libXScrnSaver-devel libXinerama-devel libXcursor-devel libX11-devel mpv-devel

# Get a supported version for CMake and install
# RUN dnf install -y wget
# RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.0/cmake-3.25.0-linux-x86_64.sh -q -O /tmp/cmake-install.sh
# RUN chmod u+x /tmp/cmake-install.sh
# RUN mkdir /opt/cmake
# RUN /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake
# RUN ln -s /opt/cmake/bin/* /usr/local/bin


# Set up the compiler
# RUN dnf install -y make
# RUN dnf install -y automake
# RUN dnf install -y gcc
# RUN dnf install -y gcc-c++
# RUN dnf install -y git


# Install the remaining OpenSpace dependencies
# RUN dnf install -y glfw-devel
# RUN dnf install -y libXi-devel
# RUN dnf install -y libXinerama-devel
# RUN dnf install -y libXrandr-devel
# RUN dnf install -y libXxf86vm-devel
# RUN dnf install -y libcurl-devel
# RUN dnf install -y mesa-libGLU-devel
# RUN dnf install -y qt6-qtbase-devel
# RUN dnf install -y gdal-devel
# RUN dnf install -y harfbuzz-devel
# RUN dnf install -y zziplib-devel
# RUN dnf install -y mpv-devel


# Install dependencies for running unit tests
# RUN dnf install -y xorg-x11-server-Xvfb


# Setting up the enviroment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY --chmod=755 data/build.sh /
WORKDIR "/"
