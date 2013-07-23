#!/bin/bash

IN_COORD_FILE=$1
OUT_COORD_FILE=$IN_COORD_FILE.reverse

while read line
do
    VAL=$line
    echo "-1 * $VAL" | bc >> $OUT_COORD_FILE
    echo -n .
done < $IN_COORD_FILE
echo done.
