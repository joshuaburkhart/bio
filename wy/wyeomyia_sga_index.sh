#!/bin/bash

#Usage: wyeomyia_sga_index.sh </full/path/to/unpaired/inputfile> [<queue> <procs> <node name> <subdir>]

#Example: wyeomyia_sga_index /home13/jburkhar/out/sga_out/sga_preprocess_out/153435810.fastq longfat 2 un4 un4_execution

QUEUE=$2
PROCS=$3
NODE_NAME=$4
SUBDR=$5/

: ${QUEUE:="longfat"}
: ${PROCS:="4"}
: ${NODE_NAME:="un5"}
: ${SUBDR:=""}

inputfile=$(echo $1 | awk -F'/' '{print $NF}')
indexname=$(echo $inputfile | awk -F'.' '{$NF=""; print}' | awk -F'/' '{print $NF}' | tr ' ' '.')

echo path to inputfile: $1
echo QUEUE: $QUEUE
echo PROCS: $PROCS
echo NODE_NAME: $NODE_NAME
echo SUBDR: $SUBDR
echo inputfile: $inputfile
echo indexname: $indexname

mkdir -p /home11/mmiller/Wyeomyia/output/sga_out/sga_index_out/$SUBDR; \
wyeomyia_rq.sh \
"mkdir -p /scratch/$USER/\$PBS_JOBID/sga_out/sga_index_out/$SUBDR && \
cp $1 /scratch/$USER/\$PBS_JOBID/sga_out/sga_index_out/$SUBDR && \
sga index -a ropebwt -t $PROCS --no-reverse /scratch/$USER/\$PBS_JOBID/sga_out/sga_index_out/$SUBDR/$inputfilei && \
mv /home11/mmiller/Wyeomyia/output/queue_out/$indexname* /home11/mmiller/Wyeomyia/output/sga_out/sga_index_out/$SUBDR/" \
$QUEUE sga_index $PROCS $NODE_NAME
