#! /bin/sh

# exit if a command fails
set -e

apk update

# install base
apk add openssl \
    gzip \
    bash \
    sed

# install s3 tools
apk add python3
python3 -m pip install awscli
apk del

# cleanup
rm -rf /var/cache/apk/*
