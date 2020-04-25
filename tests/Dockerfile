# A handy Docker container so I can test the regex support in most of
# the programs that txt2regex supports.
#
# This is used by the tests/regex-tester.sh script.
# Use `make test-regex` to build the image and run the tests on it.

FROM ubuntu:18.04

# To avoid "Configuring tzdata" prompt
ARG DEBIAN_FRONTEND=noninteractive

# flex: gcc libc6-dev
RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
    chicken-bin \
    ed \
    emacs-nox \
    expect \
    flex \
    gawk \
    gcc \
    libc6-dev \
    mysql-server \
    nodejs \
    nvi \
    original-awk \
    php7.2-cli \
    postgresql \
    procmail \
    python3-minimal \
    tcl \
    vim \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
