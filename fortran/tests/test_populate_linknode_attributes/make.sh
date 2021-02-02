#!/bin/bash

echo Compiling Test ...

FC=gfortran-9
OPTFLAGS=-g
FFLAGS=-02
PROGRAM=SWMM
PRG_OBJ=$PROGRAM.o

cp ../../Allmake.sh .
chmod +x Allmake.sh
./Allmake.sh