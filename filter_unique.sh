#!/bin/bash

#Usage: filter_unique.sh <super set> <sub set>

#Example: filter_unique.sh KCSD22-KCSD10.stripped PBSD22-PBSD10.stripped-KCSD22-KCSD10.stripped.intsct.csv

SUPER_SET=$1
SUB_SET=$2 #filter these lines out
RESULT=$SUPER_SET.unique
FILTERED_GENES=$SUPER_SET.filtered
rm -f $FILTERED_GENES $RESULT #clear files (if they exist)
LC_ALL=C
fgrep -vf $SUB_SET $SUPER_SET > $FILTERED_GENES
while read line
do
    VAL=$(echo $line | awk -F' ' '{print $2}')
    #if [ $(echo "$VAL > 0" | bc) -eq 1 ]; then
        echo $VAL >> $RESULT
    #fi
    echo -n .
done < "$FILTERED_GENES"
echo done.
