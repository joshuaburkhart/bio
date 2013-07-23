#!/bin/bash

#Usage: add_zs.sh <0's possition (0=X, 1=Y)> <1 dimensional file>

#Example: add_zs.sh 0 KCSD22-KCSD10.stripped

XY=$1
OD_FILE=$2
RESULT=$OD_FILE.zs
rm -f $RESULT
while read line
do
    VAL=$line
    if [ $XY -eq 0 ]; then
        echo -e "0\t$VAL" >> $RESULT
    else
        echo -e "$VAL\t0" >> $RESULT
    fi
    echo -n .
done < $OD_FILE
echo done.
