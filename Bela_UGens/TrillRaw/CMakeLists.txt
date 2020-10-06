# See: https://cmake.org/cmake-tutorial/ for getting started with cmake
# Build with
#
# mkdir build; cd build
# cmake -DSC_PATH=~/supercollider3.10b/ -DBELA_PATH=~/Bela/ ..
# make && mv TrillRaw.so ../../../ext/Trill/

cmake_minimum_required (VERSION 2.8)
set(PROJECT "TrillRaw")
include(../CMakeLists-common.txt)
