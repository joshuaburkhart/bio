#!/bin/bash
#Usage: ./idx_match.sh <file with indecies> <file with indexed values>
#Example: ./idx_match.sh markers.txt singsnpstp.txt


OUT_FILE=subsample_$(date "+%N" | tr ' ' '-')

touch $OUT_FILE

echo -n "Matching..."

cat $1 | while read LINE
do
	egrep "^$LINE" $2 >> $OUT_FILE
    echo -n "."
done
echo ""
sort -n $OUT_FILE > $OUT_FILE.sorted

echo "Results written to \"$OUT_FILE\""
echo "Sorted results written to \"$OUT_FILE.sorted\""
