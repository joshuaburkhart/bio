#!/bin/bash

#Usage: ma_foreign_matcher.sh <ma_intersect file> <foreign file indexed by gene>

#Example: ma_foreign_matcher.sh KC-WI.txt.pos.csv-WI-WIOB.txt.neg.csv.intsct.csv contig_summaries.csv

TMP=$(date | tr ' ' '-')
cat $1 | while read LINE
do GENE=$(echo $LINE | awk -F' ' '{print $1}')
    echo "matching $GENE..."
    egrep "^$GENE" $2 >> $TMP
done
uniq $TMP > $1-$2.foreign-intersect.csv
rm $TMP

