#!/bin/bash -e

docker build -t appserver:latest .
exit

# Compile java app
javac JavaDemo.java DAPJava.java
echo "Main-Class: JavaDemo" > manifest.txt
jar cvfm JavaDemo.jar manifest.txt *.class

