#!/bin/bash

cp ../../libswmm5.so .
cp ../swmm5_wrapper.py .
python quick_test.py
# rm swmm5_wrapper.py
# rm libswmm5.so