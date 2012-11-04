#!/bin/bash
#Usage: ./idx_match.sh <file with indecies> <file with indexed values>
#Example: ./idx_match.sh markers.txt singsnpstp.txt


OUT_FILE=subsample_$(date -n | tr ' ' '-')

touch $OUT_FILE

echo "writing results to \"$OUT_FILE\"..."

cat $1 | while read LINE
do
	egrep "^$LINE" $2 >> $OUT_FILE
done

sort -n $OUT_FILE > $OUT_FILE.sorted

echo "sorted results stored in \"$OUT_FILE.sorted\"..."
