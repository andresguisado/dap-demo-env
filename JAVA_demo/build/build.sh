#!/bin/bash -x
javac JavaDemo.java DAPJava.java
echo "Main-Class: JavaDemo" > manifest.txt
jar cvfm JavaDemo.jar manifest.txt *.class
