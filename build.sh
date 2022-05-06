#!/bin/bash

chmod +x ./gradlew
./gradlew clean bootJar
cp build/libs/*.jar ./