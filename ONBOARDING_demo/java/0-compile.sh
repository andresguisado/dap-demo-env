#!/bin/bash -x
GSON=./gson/gson-2.8.5.jar
PAS=./pas/PASJava.jar
DAP=./dap/DAPJava.jar
JAVAREST=./javarest/JavaREST.jar

javac -cp $GSON:$PAS:$DAP:$JAVAREST OnboardProject.java 
echo "Main-Class: OnboardProject" > manifest.txt
echo "Class-Path: $GSON $PAS $DAP $JAVAREST" >> manifest.txt
jar cvfm OnboardProject.jar manifest.txt *.class 

rm manifest.txt
