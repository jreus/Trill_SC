# Build with
#
# mkdir build; cd build
# cmake -DSC_PATH=~/supercollider3.10b/ -DBELA_PATH=~/Bela/ ..
# make && mv TrillCentroids.so ../../../ext/Trill/

cmake_minimum_required (VERSION 2.8)
set(PROJECT "TrillCentroids")
include(../CMakeLists-common.txt)
