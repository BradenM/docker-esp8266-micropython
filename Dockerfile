FROM phusion/baseimage:0.9.19

LABEL maintainer="bradenmars@bradenmars.me"
LABEL description="MicroPython ESP8266 Build Dockerfile"

ARG REPO=https://github.com/micropython/micropython.git
ARG BRANCH=master

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
COPY modules/*.py /micropython/ports/esp8266/modules/

USER micropython

RUN cd /esp-open-sdk && make STANDALONE=y

ENV PATH=/esp-open-sdk/xtensa-lx106-elf/bin:$PATH

USER root

# Add Entrypoint
ADD docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh \
    && /docker-entrypoint.sh build

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["build"]
