#!/bin/bash

#Usage: wyeomyia_sga_correct.sh </full/path/to/dir/with/index> </full/path/to/unpaired/inputfile> [<queue> <procs> <node name> <subdir>]

#Example: wyeomyia_sga_correct /home13/jburkhar/out/sga_out/sga_index_out/ /home13/jburkhar/out/sga_out/sga_index_out/153435810.fastq longfat 2 un4 un4_execution

QUEUE=$3
PROCS=$4
NODE_NAME=$5
SUBDR=$6/

: ${QUEUE:="longfat"}
: ${PROCS:="4"}
: ${NODE_NAME:="un5"}
: ${SUBDR:=""}

indexdir=$1
inputfile=$(echo $2 | awk -F'/' '{print $NF}')

echo path to inputfile: $1
echo QUEUE: $QUEUE
echo PROCS: $PROCS
echo NODE_NAME: $NODE_NAME
echo SUBDR: $SUBDR
echo inputfile: $inputfile
echo indexdir: $indexdir
echo files in input dir: `ls $indexdir`

mkdir -p /home11/mmiller/Wyeomyia/output/sga_out/sga_correct_out/$SUBDR; \
wyeomyia_rq.sh \
"mkdir -p /scratch/$USER/\$PBS_JOBID/sga_out/sga_correct_out/$SUBDR && \
cp -n $2 /scratch/$USER/\$PBS_JOBID/sga_out/sga_correct_out/$SUBDR && \
cp -n $indexdir/* /scratch/$USER/\$PBS_JOBID/sga_out/sga_correct_out/$SUBDR && \
cd /scratch/$USER/\$PBS_JOBID/sga_out/sga_correct_out/$SUBDR && \
sga correct -k 41 --discard --learn -t $PROCS -o /scratch/$USER/\$PBS_JOBID/sga_out/sga_correct_out/$SUBDR/reads.ec.k41.fastq /scratch/$USER/\$PBS_JOBID/sga_out/sga_correct_out/$SUBDR/$inputfile" \
$QUEUE sga_correct $PROCS $NODE_NAME
