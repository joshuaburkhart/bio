#!/bin/bash

#Usage: ma_foreign_matcher.sh <file with genes of interest> <foreign file indexed by gene>

#Example: ma_foreign_matcher.sh WI-WIOB.minus-KC-WI.minus.combined.manhattan.neg.genes contig_summaries.csv

TMP=$(date | tr ' ' '-')
cat $1 | while read LINE
do GENE=$(echo $LINE | awk -F' ' '{print $1}')
    echo "matching $GENE..."
    egrep "^$GENE" $2 >> $TMP
done
uniq $TMP > $1-$2.foreign-intersect.csv
rm $TMP

