#!/bin/bash

Running=true

trap close INT
function close() {
    Running=false
}

cd /home/benji/nim-blog

while $Running
do
    bin/run
done
