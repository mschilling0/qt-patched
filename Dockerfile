FROM rockylinux:8

ARG QT_VERSION
ARG QT_INSTALL_PREFIX=/opt
ARG QT_INSTALL_DIR="${QT_INSTALL_PREFIX}/Qt-${QT_VERSION}"

USER root

RUN groupadd -g 1001 qt_builder_group && \
    useradd -u 1001 -g 1001 qt_builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN dnf -y --setopt=tsflags=nodocs  update && \
    dnf install -y --setopt=tsflags=nodocs  'dnf-command(config-manager)' && \
    dnf -y --setopt=tsflags=nodocs  update && \
    dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf install -y --setopt=tsflags=nodocs  dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf -y --setopt=tsflags=nodocs  update && \
    dnf install -y --setopt=tsflags=nodocs  \
    gcc \
    gcc-c++ \
    which \
    make \
    perl \
    ruby \
    gperf \
    flex \
    bison \
    xcb-util-wm-devel \
    xcb-proto \
    glx-utils \
    libjpeg-turbo \
    pcre2-utf16 \
    libxcb-devel \
    xcb-util-devel \
    xcb-util-image-devel \
    xcb-util-keysyms-devel \
    xcb-util-renderutil-devel \
    libxkbcommon-devel \
    libxkbcommon-x11-devel \
    libicu-devel \
    libxslt-devel \
    freetype-devel \
    fontconfig-devel \
    pciutils-devel \
    cups-devel \
    pulseaudio-libs-devel \
    libcap-devel \
    alsa-lib-devel \
    libXrandr-devel \
    libXcomposite-devel \
    libXcursor-devel \
    libXtst-devel \
    dbus-devel \
    perl-version \
    harfbuzz-devel \
    at-spi2-atk-devel \
    mesa-libGL-devel \
    gstreamer1-devel \
    gstreamer1-plugins-base-devel \
    wayland-devel \
    mesa-libEGL-devel && \
    dnf clean all -y && \
    rm -rf /var/cache /var/log/yum.*

COPY "qt-patched-${QT_VERSION}.tar.gz" "qt-patched-${QT_VERSION}.tar.gz"

RUN tar -xzf "qt-patched-${QT_VERSION}.tar.gz" && \
( \
cd "qt-everywhere-src-${QT_VERSION}" && \
./configure --prefix="${QT_INSTALL_DIR}" -release -no-use-gold-linker -qt-pcre -qt-zlib -qt-libpng \
            -no-reduce-exports -no-gstreamer -no-icu -no-openssl -no-opengl \
            -no-sqlite -skip qtwebengine -skip qtlocation -skip qtwebsockets \
            -opensource -confirm-license -bundled-xcb-xinput -xcb -xcb-xlib \
            -nomake examples -nomake tests && \
make -j $(($(nproc) / 2)) && \
make -j $(($(nproc) / 2)) install \
) && \
rm -rf qt*

USER qt_builder
