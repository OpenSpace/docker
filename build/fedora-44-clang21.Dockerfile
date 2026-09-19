FROM fedora:44

# Set up the compiler
RUN dnf install -y cmake gcc gcc-c++ git ninja-build && dnf clean all

# Set up vcpkg
RUN dnf install -y curl zip unzip autoconf autoconf-archive automake libtool python3 bison flex pkg-config && dnf clean all

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
RUN dnf install -y clang-21 clang-format-21 lldb-21 lld-21 && dnf clean all

RUN ln -s /usr/bin/clang++-21 /usr/bin/clang++
RUN ln -s /usr/bin/clang-21 /usr/bin/clang

ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++

# Install the remaining OpenSpace dependencies
RUN dnf install -y perl-core mesa-libGL-devel mesa-libGLU-devel libglvnd-devel libxcb-devel xcb-util-devel xcb-util-image-devel xcb-util-keysyms-devel xcb-util-renderutil-devel xcb-util-wm-devel xcb-util-cursor-devel libX11-xcb libXrender-devel libXi-devel libxkbcommon-devel libxkbcommon-x11-devel mesa-libEGL-devel fontconfig-devel freetype-devel wayland-devel wayland-protocols-devel libwayland-client libwayland-cursor libwayland-egl libXxf86vm-devel libXrandr-devel libXfixes-devel libXcomposite-devel libXdamage-devel libXScrnSaver-devel libXinerama-devel libXcursor-devel libX11-devel mpv-devel mesa-dri-drivers xorg-x11-server-Xvfb && dnf clean all

# Setting up the environment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY --chmod=755 data/build.sh /
WORKDIR "/"
