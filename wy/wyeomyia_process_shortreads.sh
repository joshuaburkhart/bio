#!/bin/bash

#Usage: wyeomyia_process_shortreads.sh </full/path/to/unpaired/inputfile/1> </full/path/to/unpaired/inputfile/2> [<queue> <procs> <node name> <subdir>]

#Example: wyeomyia_process_shortreads.sh /home13/jburkhar/out/prcsr_out/sample_unbarcoded_1.fastq /home13/jburkhar/out/prcsr_out/sample_unbarcoded_2.fastq longfat 8 un4

QUEUE=$3
PROCS=$4
NODE_NAME=$5
SUBDR=$6/

: ${QUEUE:="longfat"}
: ${PROCS:="4"}
: ${NODE_NAME:="un5"}
: ${SUBDR:=""}

inputfile1=$(echo $1 | awk -F'/' '{print $NF}')
inputfile2=$(echo $2 | awk -F'/' '{print $NF}')

echo path to inputfile 1: $1
echo path to inputfile 2: $2
echo QUEUE: $QUEUE
echo PROCS: $PROCS
echo NODE_NAME: $NODE_NAME
echo SUBDR: $SUBDR
echo inputfile 1: $inputfile1
echo inputfile 2: $inputfile2

mkdir -p /home11/mmiller/Wyeomyia/output/prcsr_out/$SUBDR; \
wyeomyia_rq.sh \
"mkdir -p /scratch/$USER/\$PBS_JOBID/prcsr_out/$SUBDR && \
cp $1 /scratch/$USER/\$PBS_JOBID/ && \
cp $2 /scratch/$USER/\$PBS_JOBID/ && \
process_shortreads -1 /scratch/$USER/\$PBS_JOBID/$inputfile1 -2 /scratch/$USER/\$PBS_JOBID/$inputfile2 -o /scratch/$USER/\$PBS_JOBID/prcsr_out/$SUBDR -c -q -E phred33 && \
rm -f /scratch/$USER/\$PBS_JOBID/$inputfile1 && \
rm -f /scratch/$USER/\$PBS_JOBID/$inputfile2" \
$QUEUE prc_sr $PROCS $NODE_NAME
