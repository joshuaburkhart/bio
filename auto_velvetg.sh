#!/bin/bash

#Usage: ./auto_velvetg.sh <max_k_freq (in thousands)> <min_k_freq> <k> <expected coverage>
#Example: ./auto_velvetg.sh 400 1 71 24

rq.sh "mkdir /tmp/$USER/velvet_out; cp -r /home13/jburkhar/research/out/velvet_out/velveth_$1K_max_$2_min_k$3 /tmp/$USER/velvet_out/ && velvetg /tmp/$USER/velvet_out/velveth_$1K_max_$2_min_k$3 -min_contig_lgth 100 -ins_length 500 -exp_cov $4 -read_trkg yes" fatnodes velvetg_$1K_max_$2_min_k$3 32
