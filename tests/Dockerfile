# A handy Docker container so I can test the regex support in most of
# the programs that txt2regex supports.
#
# This is used by the tests/regex-tester.sh script.
# Use `make test-regex` to build the image and run the tests on it.

FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
    gawk \
    nodejs \
    original-awk \
    php7.2-cli \
    postgresql \
    procmail \
    tcl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
