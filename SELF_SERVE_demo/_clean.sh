#!/bin/bash
pushd java
  ./_clean.sh
popd
rm policy/*.yaml logs/*
