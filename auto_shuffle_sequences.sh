#!/bin/bash

#Usage: ./auto_shuffle_sequences.sh <max_k_freq (in thousands)> <min_k_freq>
#Example: ./auto_shuffle_sequences.sh 400 1

rq.sh "cp /home13/jburkhar/research/out/kmr_fltr_out/kmer_$1K_max_$2_min_k19/sample_unbarcoded.fil.fq_1 /tmp/$USER/ && cp /home13/jburkhar/research/out/kmr_fltr_out/kmer_$1K_max_$2_min_k19/sample_unbarcoded.fil.fq_2 /tmp/$USER/ && mkdir /tmp/$USER/shuffle_out && shuffleSequences_fastq.pl /tmp/$USER/sample_unbarcoded.fil.fq_1 /tmp/$USER/sample_unbarcoded.fil.fq_2 /tmp/$USER/shuffle_out/Merged_$1K_max_$2_min_k19.fastq && rm -f /tmp/$USER/sample_unbarcoded.fil.fq_1 && rm -f /tmp/$USER/sample_unbarcoded.fil.fq_2" fatnodes shuffle_$1K_max_$2_min_k19 32
