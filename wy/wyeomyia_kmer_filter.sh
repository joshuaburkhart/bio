#!/bin/bash

#Usage: wyeomyia_kmer_filter.sh </full/path/to/unpaired/inputfile/1> </full/path/to/unpaired/inputfile/2> <maximum kmer frequency (in thousands)> <minimum kmer frequency> [<queue> <procs> <node name> <subdir>]

#Example: wyeomyia_kmer_filter /home13/jburkhar/out/prcsr_out/sample_unbarcoded_1.fastq /home13/jburkhar/out/prcsr_out/sample_unbarcoded_2.fastq 400 1 longfat 2 un5

QUEUE=$5
PROCS=$6
NODE_NAME=$7
SUBDR=$8/

: ${QUEUE:="longfat"}
: ${PROCS:="4"}
: ${NODE_NAME:="un5"}
: ${SUBDR:=""}

inputfile1=$(echo $1 | awk -F'/' '{print $NF}')
inputfile2=$(echo $2 | awk -F'/' '{print $NF}')

echo path to inputfile 1: $1
echo path to inputfile 2: $2
echo max kmer frequency: $3
echo min kmer frequency: $4
echo QUEUE: $QUEUE
echo PROCS: $PROCS
echo NODE_NAME: $NODE_NAME
echo SUBDR: $SUBDR
echo inputfile 1: $inputfile1
echo inputfile 2: $inputfile2

mkdir -p /home11/mmiller/Wyeomyia/output/kmr_fltr_out/kmer_maxfq-$3K_minfq-$4_k19/$SUBDR; \
wyeomyia_rq.sh \
"mkdir -p /scratch/$USER/\$PBS_JOBID && \
cp $1 /scratch/$USER/\$PBS_JOBID/ && \
cp $2 /scratch/$USER/\$PBS_JOBID/ && \
mkdir -p /scratch/$USER/\$PBS_JOBID/kmr_fltr_out/kmer_maxfq-$3K_minfq-$4_k19/$SUBDR && \
kmer_filter -1 /scratch/$USER/\$PBS_JOBID/$inputfile1 -2 /scratch/$USER/\$PBS_JOBID/$inputfile2 -o /scratch/$USER/\$PBS_JOBID/kmr_fltr_out/kmer_maxfq-$3K_minfq-$4_k19/$SUBDR --k_len 19 --max_k_freq $3000 --min_k_freq $4 --record_kmers && \
rm -f /scratch/$USER/\$PBS_JOBID/$inputfile1 && \
rm -f /scratch/$USER/\$PBS_JOBID/$inputfile2" \
$QUEUE kmr_fltr_$3-$4 $PROCS $NODE_NAME
