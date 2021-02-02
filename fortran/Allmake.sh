#!/bin/bash

echo Copying files ...
cp ../../network_graph.f08 .
cp ../../dynamic_array.f08 .
cp ../../tables.f08 .
cp ../../errors.f08 .
cp ../../dll_mod.f08 .
cp ../../interface.f08 .
cp ../../objects.f08 .
cp ../../inflow.f08 .

echo Compiling Test ...

FC=gfortran-9
OPTFLAGS=-g
FFLAGS=-02
PROGRAM=SWMM
PRG_OBJ=$PROGRAM.o

SOURCESF=" dynamic_array.f08\
          tables.f08\
          errors.f08\
          dll_mod.f08\
          objects.f08\
          interface.f08\
          network_graph.f08\
          inflow.f08\
          main.f08"

# Linker
echo Compiling ...
$FC $SOURCESF -ldl -o $PROGRAM

rm network_graph.f08
rm dynamic_array.f08
rm errors.f08
rm tables.f08
rm dll_mod.f08
rm interface.f08
rm objects.f08
rm inflow.f08
rm *.mod
rm libswmm5.so
cp ../../../libswmm5.so .