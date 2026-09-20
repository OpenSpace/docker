FROM archlinux:base

# Set up the compiler. base-devel is kept for make and for the GCC libstdc++ headers that
# Clang compiles against, the same way the other images keep their system compiler. It
# also covers most of what vcpkg needs: autoconf, automake, libtool, bison, flex, pkgconf.
RUN pacman -Syu --noconfirm --needed base-devel cmake git ninja && pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

# Set up vcpkg
RUN pacman -Syu --noconfirm --needed curl zip unzip tar autoconf-archive python perl && pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

# Prepare vcpkg. VCPKG_COMMIT is the "default-registry" baseline from OpenSpace's
# vcpkg.json. vcpkg can only resolve a baseline that exists in this checkout, so a
# shallow clone of any other commit (a release tag, for instance) fails to configure.
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

# Set up Clang. Arch is a rolling release, so this tracks whatever Clang is current at
# build time rather than a pinned version. Unlike the versioned clang21 package, this one
# installs unversioned binaries straight into /usr/bin, so no symlinks are needed, and
# lldb matches the compiler version here rather than pulling a second LLVM alongside it.
RUN pacman -Syu --noconfirm --needed clang lld lldb && pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++

# Install the remaining OpenSpace dependencies. Arch ships headers in the main package,
# so there are no separate -devel/-dev packages to install here. libcups is in here for CEF,
# whose libcef.so links against libcups.so.2; the other distributions pull that in through
# their desktop stacks, but on Arch nothing else in this list depends on it.
RUN pacman -Syu --noconfirm --needed perl mesa glu libglvnd libxcb xcb-util xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xcb-util-cursor libxrender libxi libxkbcommon libxkbcommon-x11 fontconfig freetype2 wayland wayland-protocols libxxf86vm libxrandr libxfixes libxcomposite libxdamage libxss libxinerama libxcursor libx11 libxext xorgproto vulkan-headers mpv dbus at-spi2-core nss nspr libcups xorg-server-xvfb && pacman -Scc --noconfirm && rm -rf /var/cache/pacman/pkg/* /var/lib/pacman/sync/*

# Setting up the environment so that we can quickly build OpenSpace from the container
ENV CMAKE_EXPORT_COMPILE_COMMANDS=1
COPY --chmod=755 data/build.sh /
WORKDIR "/"
