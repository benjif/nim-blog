#!/bin/sh

for i in public/images/*.png; do
  optipng -o2 -strip all $i
done
