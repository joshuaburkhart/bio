#!/bin/bash

#Usage: fasta_cleaner.sh <file with lots of label info> <space delimited position of sequence>

#Example: fasta_cleaner.sh Singletons.oneline.fna 7

FASTA_FILE=$1

cat $FASTA_FILE | tr '\n' ' ' | grep -Po '(?<=>).+?(?=>)' | awk -v seq_pos=$2 -F' ' '{print $1" "$seq_pos}' | tr -d "\r" > $FASTA_FILE.indexed
