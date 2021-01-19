#!/bin/bash

echo Compiling Test ...

FC=gfortran-9
OPTFLAGS=-g
FFLAGS=-02
PROGRAM=darray
PRG_OBJ=$PROGRAM.o

cp ../../dynamic_array.f08 .

SOURCESF=" dynamic_array.f08\
          test_dynamic_array.f08"

# Linker
echo Compiling ...
$FC $SOURCESF -ldl -o $PROGRAM

rm dynamic_array.f08
rm *.mod
rm libswmm5.so
cp ../../../libswmm5.so .