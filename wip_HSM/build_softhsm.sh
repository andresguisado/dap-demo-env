#!/bin/bash

# Assumes running on Ubuntu 16.04

SOFTHSM_VERSION=2.5.0

main() {
  install
  build
}

install() {
  apt-get update
  apt-get install libssl-dev libcppunit-dev
  wget https://dist.opendnssec.org/source/softhsm-${SOFTHSM_VERSION}.tar.gz
  tar xvf softhsm-${SOFTHSM_VERSION}.tar.gz
}

build() {
  cd softhsm-${SOFTHSM_VERSION}
  ./configure
  make
  make -C src/lib/test check
  cd ..
  echo "Libraries built:" $(ls softhsm-${SOFTHSM_VERSION}/src/lib/.libs/lib*.so)
}

main "$@"
