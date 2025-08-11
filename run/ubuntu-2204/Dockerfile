FROM ubuntu:22.04

RUN export uid=1010 && \
    export gid=1000 && \
    mkdir -p /home/openspace && \
    mkdir -p /etc/sudoers.d && \
    echo "openspace:x:${uid}:${gid}:openspace,,,:/home/openspace:/bin/bash" >> /etc/passwd && \
    echo "openspace:x:${uid}:" >> /etc/group && \
    echo "openspacegroup:x:${gid}:" >> /etc/group && \
    echo "openspace ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/openspace
RUN echo "root:root" | chpasswd && \
    echo "openspace:openspace" | chpasswd
RUN chmod 0440 /etc/sudoers.d/openspace && \
    chown ${uid}:${gid} -R /home/openspace && \
    cd /home/openspace && \
    chown openspace:openspace -R .
RUN apt update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt install -y tzdata && \
    ln -fs /usr/share/zoneinfo/America/Denver /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata
RUN apt update && \
    apt install -y x11-xserver-utils && \
    apt install -y xauth && \
    apt install -y sudo && \
    apt install -y freeglut3-dev && \
    apt install -y git && \
    apt install -y gpg && \
    apt install -y wget && \
    apt install -y ca-certificates && \
    apt install -y libxrandr-dev && \
    apt install -y libxinerama-dev && \
    apt install -y xorg-dev && \
    apt install -y libxcursor-dev && \
    apt install -y libxi-dev && \
    apt install -y libasound2-dev && \
    apt install -y libgdal-dev && \
    apt install -y libboost1.74-dev && \
    apt install -y qt6-base-dev && \
    apt install -y libmpv-dev && \
    apt install -y libvulkan-dev && \
    apt install -y vim
RUN echo "user ALL=(ALL) ALL" >> /etc/sudoers && \
    apt install -y nemo && \
    apt install -y software-properties-common && \
    apt install -y synaptic && \
    apt update && \
    apt upgrade -y && \
    apt dist-upgrade -y && \
    apt autoclean -y && \
    apt autoremove -y && \
    apt install -y build-essential && \
    apt install -y software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt update -y
RUN apt install -y gcc-11 g++-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11 && \
    update-alternatives --config gcc && \
    apt install -y glew-utils && \
    apt install -y libpng-dev && \
    apt install -y libcurl4-openssl-dev
#Install latest version of CMake (ubuntu's default is too old)
#cmake < 4.0 is known to work
#Install CMake 3.26.4 from source
RUN wget -q https://github.com/Kitware/CMake/releases/download/v3.26.4/cmake-3.26.4.tar.gz && \
              tar -xf cmake-3.26.4.tar.gz && \
              cd cmake-3.26.4 && \
              ./bootstrap -- -DCMAKE_USE_OPENSSL=ON && \
              make -j\$(nproc) && \
              make install && \
              cd .. && rm -rf cmake-3.26.4*
#Build OpenSpace
RUN su openspace; \
    chown -R openspace:openspace .; \
    mkdir -p /home/openspace/source; \
    cd /home/openspace/source; \
    git clone --recursive https://github.com/OpenSpace/OpenSpace; \
    mkdir /home/openspace/source/OpenSpace/build; \
    cd /home/openspace/source/OpenSpace/build; \
    cmake -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++-11 \
    -DCMAKE_C_COMPILER:FILEPATH=/usr/bin/gcc-11 \
    -DASSIMP_BUILD_MINIZIP=1 /home/openspace/source/OpenSpace; \
    make -j4

USER openspace
ENV HOME /home/openspace
CMD /usr/bin/bash

