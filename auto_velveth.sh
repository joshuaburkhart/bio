#!/bin/bash

#Usage: ./auto_velveth.sh <max_k_freq (in thousands)> <min_k_freq> <k> [<queue> <procs>]
#Example: ./auto_velveth.sh 400 1 71 generic 12

QUEUE=$4
PROCS=$5

: ${QUEUE:="fatnodes"}
: ${PROCS:="32"}

echo QUEUE: $QUEUE
echo PROCS: $PROCS

mkdir /home13/jburkhar/research/out/velvet_out/velveth_$1K_max_$2_min_k$3; rq.sh "cp /home13/jburkhar/research/out/shuffle_out/Merged_$1K_max_$2_min_k19.fastq /tmp/$USER/ && mkdir /tmp/$USER/velvet_out && mkdir /tmp/$USER/velvet_out/velveth_$1K_max_$2_min_k$3 && velveth /tmp/$USER/velvet_out/velveth_$1K_max_$2_min_k$3 $3 -fastq -shortPaired /tmp/$USER/Merged_$1K_max_$2_min_k19.fastq && rm -f /tmp/$USER/Merged_$1K_max_$2_min_k19.fastq" $QUEUE velveth_$1K_max_$2_min_k$3 $PROCS
