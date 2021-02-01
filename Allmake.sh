#!/bin/bash

echo downloading the Stormwater Management Model from US EPA repository ...
wget "https://github.com/USEPA/Stormwater-Management-Model/archive/v5.1.13.tar.gz"
tar -xvf *.tar.gz
rm *.tar.gz

mv Stormwater*/src .
rm -r Stormwater*

cp source_files/interface.h src/
cp source_files/interface.c src/
cp source_files/tests.h src/
cp source_files/tests.c src/
cp source_files/Makefile src/
cd src
make

cd ..
cp src/libswmm5.so .
rm -r src