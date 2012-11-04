#!/bin/bash

#Usage: wyeomyia_kmer_dist.sh </full/path/to/unpaired/inputfile/1> </full/path/to/unpaired/inputfile/2> <k> [<queue> <procs> <node name> <subdir>]

#Example: wyeomyia_kmer_dist /home13/jburkhar/out/prcsr_out/sample_unbarcoded_1.fastq /home13/jburkhar/out/prcsr_out/sample_unbarcoded_2.fastq 19 longfat 4 un5

QUEUE=$4
PROCS=$5
NODE_NAME=$6
SUBDR=$7/

: ${QUEUE:="longfat"}
: ${PROCS:="4"}
: ${NODE_NAME:="un5"}
: ${SUBDR:=""}

inputfile1=$(echo $1 | awk -F'/' '{print $NF}')
inputfile2=$(echo $2 | awk -F'/' '{print $NF}')

echo path to inputfile 1: $1
echo path to inputfile 2: $2
echo k: $3
echo QUEUE: $QUEUE
echo PROCS: $PROCS
echo NODE_NAME: $NODE_NAME
echo SUBDR: $SUBDR
echo inputfile 1: $inputfile1
echo inputfile 2: $inputfile2

mkdir -p /home11/mmiller/Wyeomyia/output/kmr_fltr_out/kmer_dist_k$3/$SUBDR; \
wyeomyia_rq.sh \
"mkdir -p /scratch/$USER/\$PBS_JOBID && \
cp $1 /scratch/$USER/\$PBS_JOBID/ && \
cp $2 /scratch/$USER/\$PBS_JOBID/ && \
mkdir -p /scratch/$USER/\$PBS_JOBID/kmr_fltr_out/kmer_dist_k$3/$SUBDR && \
kmer_filter -1 /scratch/$USER/\$PBS_JOBID/$inputfile1 -2 /scratch/$USER/\$PBS_JOBID/$inputfile2 -o /scratch/$USER/\$PBS_JOBID/kmr_fltr_out/kmer_dist_k$3/$SUBDR --k_len $3 --k_dist > /scratch/$USER/\$PBS_JOBID/kmr_fltr_out/kmer_dist_k$3/$SUBDR/kmer_dist_k$3_$inputfile1-$inputfile2.txt && \
rm -f /scratch/$USER/\$PBS_JOBID/$inputfile1 && \
rm -f /scratch/$USER/\$PBS_JOBID/$inputfile2" \
$QUEUE kmr_dst_k$3 $PROCS $NODE_NAME
