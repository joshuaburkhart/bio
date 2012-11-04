#!/bin/bash

#Usage: wyeomyia_stats.sh </path/to/contigs.fa>
#Example: wyeomyia_stats.sh $Y/output/velvet_out/velveth_maxfq-250K_minfq-5_k69/contigs.fa

contig_stats.pl -f $1 -t 500 -h | \
tr ' ' '_' | \
awk '{ for (i = 1; i <= NF; i++) f[i] = f[i] " " $i ; if (NF > n) n = NF } END { for (i = 1; i <= n; i++) sub(/^  */, "", f[i]) ; for (i = 1; i <= n; i++) print f[i] }'
