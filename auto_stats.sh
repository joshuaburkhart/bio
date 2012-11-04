#!/bin/bash

#Usage: ./auto_stats.sh <max_k_freq (in thousands)> <min_k_freq> <k>
#Example: ./auto_stats.sh 400 1 71

contig_stats.pl -f /home13/jburkhar/research/out/velvet_out/velveth_$1K_max_$2_min_k$3/contigs.fa -t 500 -h | tr ' ' '_' |  awk '{ for (i = 1; i <= NF; i++) f[i] = f[i] " " $i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^  */, "", f[i]) ; for (i = 1; i <= n; i++) print f[i] }'
