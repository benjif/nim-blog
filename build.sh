#!/bin/bash

nim c -o:run -d:release src/main.nim
nim c -o:refresh -d:release src/refresh.nim
