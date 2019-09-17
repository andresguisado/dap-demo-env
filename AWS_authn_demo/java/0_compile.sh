#!/bin/bash -x
pushd JavaDemo
#mvn clean
#mvn install dependency:copy-dependencies
mvn -e package
popd
