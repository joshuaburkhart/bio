#!/bin/bash

#Usage: filter_unique.sh <super set> <sub set>

#Example: filter_unique.sh KCSD22-KCSD10.stripped PBSD22-PBSD10.stripped-KCSD22-KCSD10.stripped.intsct.csv

SUPER_SET=$1
SUB_SET=$2 #filter these lines out
RESULT=$SUPER_SET.unique
rm -f $FILTERED_GENES #clear file if it exists
FILTERED_GENES=$SUPER_SET.genes
grep -vf $SUB_SET $SUPER_SET > $FILTERED_GENES
while read line
do
    VAL=$(echo $line | awk -F' ' '{print $2}')
    if [ $(echo "$VAL > 0" | bc) -eq 1 ]; then
        echo $VAL >> $RESULT
    fi
    echo -n .
done < "$FILTERED_GENES"
echo done.
