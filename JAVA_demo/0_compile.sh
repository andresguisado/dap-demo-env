#!/bin/bash -x
javac ConjurJava.java
echo "Main-Class: ConjurJava" > manifest.txt
jar cvfm ConjurJava.jar manifest.txt *.class
