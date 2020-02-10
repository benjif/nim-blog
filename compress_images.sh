#!/bin/sh

for i in $(find -name \*.png); do
  optipng -o2 -strip all $i
done
