FROM phusion/baseimage:0.9.19

LABEL maintainer="bradenmars@bradenmars.me"
LABEL description="MicroPython ESP8266 Build Dockerfile"
LABEL org.opencontainers.image.source https://github.com/bradenm/micropy-build

ARG REPO
ARG BRANCH
ARG PORT_PATH

ENV REPO ${REPO:-https://github.com/micropython/micropython.git}
ENV BRANCH ${BRANCH:-master}
ENV PORT_PATH ${PORT_PATH:-ports/esp8266}

RUN apt-get update \
    && apt-get install -y \
    apt-utils \
    autoconf \
    automake \
    bash \
    bison \
    build-essential \
    flex \
    gawk \
    gcc \
    g++ \
    git \
    gperf \
    help2man \
    libexpat-dev \
    libffi-dev \
    libreadline-dev \
    libtool \
    libtool-bin \
    make \
    ncurses-dev \
    pkg-config \
    python \
    python-dev \
    python-serial \
    python-setuptools \
    texinfo \
    sed \
    unrar-free \
    unzip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --no-create-home micropython \
    && git clone --recursive https://github.com/pfalcon/esp-open-sdk.git \
    && git clone $REPO micropython \
    && cd micropython && git checkout $BRANCH && git submodule update --init \
    && chown -R micropython:micropython ../esp-open-sdk ../micropython

# Copy Modules to freeze
COPY esp8266/modules/.gitkeep esp8266/modules/*.py /micropython/ports/esp8266/modules/
# Workaround to allow empty modules directory
RUN rm /micropython/ports/esp8266/modules/.gitkeep

USER micropython

RUN cd /esp-open-sdk && make STANDALONE=y

ENV PATH=/esp-open-sdk/xtensa-lx106-elf/bin:$PATH

USER root

# Build mpy-cross
RUN cd /micropython && make -C mpy-cross V=1

# Build ESP8266
RUN cd /micropython/${PORT_PATH} && make V=1

# Setup Entrypoint
# Must copy entrypoint or build from parent dir with -f option
# See BradenM/micropy-build on GitHub
COPY ./docker-entrypoint.py /docker-entrypoint.py

ENTRYPOINT ["/usr/bin/python3", "/docker-entrypoint.py"]