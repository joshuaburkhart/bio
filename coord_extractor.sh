#!/bin/bash

#Usage: coord_extractor.sh <input file> <coordinate field index (indexed from 1, space delimited)>

#Example: coord_extractor.sh KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv 2

#extract odd # lines (i.e. 1,3,5...) 
cat $1 | awk 'NR%2' | awk -v num=$2 -F' ' '{print $num}' > $1.odd_coords

#extract even # lines (i.e. 2,4,6...)
cat $1 | awk 'NR%2 - 1' | awk -v num=$2 -F' ' '{print $num}' > $1.even_coords
