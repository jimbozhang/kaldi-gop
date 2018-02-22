#!/bin/sh

utils/check_dependencies.sh || exit
cd src/
[ -d build ] || mkdir build
cd build
cmake .. && make
