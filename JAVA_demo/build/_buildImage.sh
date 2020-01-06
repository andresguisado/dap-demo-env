#!/bin/bash -e

source ../config/dap.config

# Compile java app
javac JavaDemo.java DAPJava.java
echo "Main-Class: JavaDemo" > manifest.txt
jar cvfm JavaDemo.jar manifest.txt *.class

cp $MASTER_CERT_FILE ./conjur-dev.pem
cp ~/conjur-install-images/jre-9.0.4_linux-x64_bin.tar.gz .
docker build -t javatest:latest .
rm -f jre-9.0.4_linux-x64_bin.tar.gz
