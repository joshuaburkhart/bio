#!/bin/bash

#Usage: coord_extractor.sh <input file> <coordinate field index (indexed from 1, space delimited)> <number of files to create>

#Example: coord_extractor.sh KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv 2 3

if [ -z $3 ]; then
    NUM_F=2
else
    NUM_F=$3
fi

for i in $(seq 1 $NUM_F)
do
    cat $1 | awk -v fn=$NUM_F -v icr=$(($i % $NUM_F)) 'NR % fn == 0 + icr' | awk -v col=$2 -F' ' '{print $col}' > intsct.$i
done

