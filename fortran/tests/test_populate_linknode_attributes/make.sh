#!/bin/bash

echo Compiling Test ...

FC=gfortran-9
OPTFLAGS=-g
FFLAGS=-02
PROGRAM=SWMM
PRG_OBJ=$PROGRAM.o

cp ../../dll_mod.f08 .
cp ../../interface.f08 .

SOURCESF=" dll_mod.f08\
          interface.f08\
          main.f08"

# Linker
echo Compiling ...
$FC $SOURCESF -ldl -o $PROGRAM

rm dll_mod.f08
rm interface.f08
rm *.mod
rm libswmm5.so
cp ../../../libswmm5.so .