#!/bin/bash

#Usage: auto_kmer_filter.sh <max_k_freq (in thousands)> <min_k_freq>
#Example: auto_kmer_filter 400 1

mkdir /home13/jburkhar/research/out/kmr_fltr_out/kmer_$1K_max_$2_min_k19; rq.sh "cp /home13/jburkhar/research/out/prcsr_out/sample_unbarcoded.fq_1 /tmp/$USER/ && cp /home13/jburkhar/research/out/prcsr_out/sample_unbarcoded.fq_2 /tmp/$USER/ && mkdir /tmp/$USER/kmr_fltr_out && mkdir /tmp/$USER/kmr_fltr_out/kmer_$1K_max_$2_min_k19 && kmer_filter -1 /tmp/$USER/sample_unbarcoded.fq_1 -2 /tmp/$USER/sample_unbarcoded.fq_2 -o /tmp/$USER/kmr_fltr_out/kmer_$1K_max_$2_min_k19/ --k_len 19 --max_k_freq $1000 --min_k_freq $2 --record_kmers && rm -f /tmp/$USER/sample_unbarcoded.fq_1 && rm -f /tmp/$USER/sample_unbarcoded.fq_2" fatnodes kmer_filter_$1K_max_$2_min_k19 32
