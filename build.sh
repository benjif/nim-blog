#!/bin/bash

mkdir -p bin
nim c -o:bin/run -d:release src/main.nim
nim c -o:bin/refresh -d:release src/refresh.nim
