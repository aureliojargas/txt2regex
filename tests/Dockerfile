# A handy Docker container so I can test the regex support in most of
# the programs that txt2regex supports.
#
# This is used by the tests/regex-tester.sh script.
# Use `make test-regex` to build the image and run the tests on it.

# FIXME For reproducible builds, I will need to switch to this image
# https://hub.docker.com/r/debian/snapshot/tags
FROM ubuntu:bionic-20200219

# To avoid "Configuring tzdata" prompt
ARG DEBIAN_FRONTEND=noninteractive

# flex: gcc libc6-dev
RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
    chicken-bin=4.12.0-0.3 \
    ed=1.10-2.1 \
    emacs-nox=47.0 \
    expect=5.45.4-1 \
    flex=2.6.4-6 \
    gawk=1:4.1.4+dfsg-1build1 \
    gcc \
    libc6-dev \
    mysql-server \
    nodejs=8.10.0~dfsg-2ubuntu0.4 \
    nvi=1.81.6-13 \
    original-awk=2012-12-20-6 \
    php7.2-cli=7.2.24-0ubuntu0.18.04.4 \
    postgresql=10+190ubuntu0.1 \
    procmail=3.22-26 \
    python3-minimal=3.6.7-1~18.04 \
    tcl=8.6.0+9 \
    vim=2:8.0.1453-1ubuntu1.3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# mysql-server=5.7.29-0ubuntu0.18.04.1 \
