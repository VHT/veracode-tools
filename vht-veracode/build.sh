#!/bin/sh
javac -d dist -classpath "/veracode/veracode-wrapper.jar:commons-cli-1.4.jar:." -sourcepath src $(find ./src -name "*.java")
jar cvfm vht-veracode.jar Manifest.txt commons-cli-1.4.jar -C dist .
