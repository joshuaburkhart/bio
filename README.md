# bio: Software to support various bioinformatics research tasks
==============================================================

## USE CASES
------------

### Plot significantly expressed sequences, highlighting subgroups by manhattan distance.

Files Required   
KC-WI.txt (a file containing ma plot data)   
WI-WIOB.txt (a file containing ma plot data)   

Process   

Filter insignificant sequences   
ma_qual.rb KC-WI.txt 0.05 false   
ma_qual.rb WI-WIOB.txt 0.05 false   

Remove header from MA plot data   
tail -n+2 KC-WI.txt.qual.csv > KC-WI.txt.stripped   
tail -n+2 WI-WIOB.txt.qual.csv > WI-WIOB.txt.stripped   
Join on common identifying attribute   
ma_intersect.rb KC-WI.txt.stripped WI-WIOB.txt.stripped   

Extract values used for coordinates   
coord_extractor.sh KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv 2 2   

Combine minus values   
paste intsct.1 intsct.2 > intsct.123   

Filter by manhattan distance to find interesting sequences   
manhattan.rb intsct.123 4   

Plot with R   
Rscript ../bio/plot_expr_coords.r intsct.123 Manhattan_gt_4.0 Manhattan_lt_4.0   

### Plot significantly expressed sequences, highlighting pre-selected subgroup.   

Files Required   
KC-WI.txt (a file containing ma plot data)   
WI-WIOB.txt (a file containing ma plot data)   
insulin_signalers.genes (a file containing a list of sequence identifiers)   

Process   

Filter insignificant sequences   
ma_qual.rb KC-WI.txt 0.05 false   
ma_qual.rb WI-WIOB.txt 0.05 false   

Remove header from MA plot data   
tail -n+2 KC-WI.txt.qual.csv > KC-WI.txt.stripped   
tail -n+2 WI-WIOB.txt.qual.csv > WI-WIOB.txt.stripped   

Join on common identifying attribute   
ma_intersect.rb KC-WI.txt.stripped WI-WIOB.txt.stripped   

Match rows with sequence identifiers   
ma_foreign_matcher.sh insulin_signalers.genes KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv   

Extract values used for coordinates   
coord_extractor.sh KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv 2   
coord_extractor.sh insulin_signalers.genes-KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.foreign-intersect.csv 2   

Combine minus values   
pass resulting files as (x,y) coordinates to below coordinate combiner program   
ma_coord_combiner.rb KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.odd_coords    KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.even_coords   
ma_coord_combiner.rb insulin_signalers.genes-KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.foreign-intersect.csv.odd_coords insulin_signalers.genes-KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.foreign-intersect.csv.even_coords   

Rename preselected sequence combined coordinate file to something short & meaningful (for plotting)   
mv insulin_signalers.genes-KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.foreign-intersect.csv.even_coords-insulin_signalers.genes-KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.foreign-intersect.csv.odd_coords.combined  Insulin-Signalers   

Plot with R   
Rscript ../bio/plot_expr_coords.r    KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.odd_coords-KC-WI.txt.stripped-WI-WIOB.txt.stripped.intsct.csv.even_coords.combined Insulin-Signalers   

### Show three comparisons using a 3d scatter plot.   

Files Required   
PBSD10-PBLD10 (a file containing ma plot data)   
PBSD10-KCSD10 (a file containing ma plot data)   
PBLD10-KCLD10 (a file containing ma plot data)   

Process   

Filter insignificant sequences   
ma_qual.rb PBSD10-PBLD10 0.05 false   
ma_qual.rb PBSD10-KCSD10 0.05 false   
ma_qual.rb PBLD10-KCLD10 0.05 false   

Remove header from MA plot data   
tail -n+2 PBSD10-PBLD10.qual.csv > PBSD10-PBLD10.stripped   
tail -n+2 PBSD10-KCSD10.qual.csv > PBSD10-KCSD10.stripped   
tail -n+2 PBSD10-PBLD10.qual.csv > KCLD10-KCLD10.stripped   

Join on common identifying attribute   
ma_intersect.rb PBSD10-PBLD10.stripped PBLD10-KCLD10.stripped PBSD10-KCSD10.stripped   

Extract values used for coordinates   
coord_extractor.sh PBSD10-PBLD10.stripped-PBLD10-KCLD10.stripped-PBSD10-KCSD10.stripped.intsct.csv 2 3   

Combine coordinates   
paste intsct.1 intsct.2 intsct.3 > intsct.123   

Format as csv   
sed -i 's/\t/,/g' intsct.123   

Plot with octave   
3d_plot.oct   

### Align preselected sequences to those stored in NCBI databases, saving results to files.   

Files Required   
Contigs.fna (a file containing preselected sequences)   
Singletons.fna (a file containing preselected sequences)   
WI-WIOB.minus   

Process   

Format multi-line FASTA files into single-line FASTA files   
fa2oneline.pl Contigs.fna > Contigs.oneline.fna   

Create indexed seq files   
fasta_cleaner.sh Singletons.oneline.fna 7   
fasta_cleaner.sh Contigs.oneline.fna 6   

Filter interesting sequences   
ma_foreign_matcher.sh WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos.genes Singletons.oneline.fna.indexed   

Convert to simple FASTA   
cat Singletons.oneline.fna.indexed-WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos.genes.foreign-intersect.csv | awk -F' ' '{print ">"$1"\n"$2}' > Singletons.simple.fasta   

Query interesting sequences   
ncbi_blast.rb Singletons.simple.fasta   

## MISC. USAGE WITH MA DATA
---------------------------

Filter low quality data rows   

Split MA plot data into positive & negative expression (if required)   
ma_splitter.rb KC-WI.txt   

Keep whole files   
ma_qual.rb KC-WI.txt 0.05 false   

Remove header from MA plot data (if required)   
tail -n+2 WI-WIOB.txt.qual.csv > WI-WIOB.txt.stripped   

Find differences by subtraction (if required)   
ma_diff.rb <minuend ma data file> <subtrahend ma data file> <outfile name>   

Find intersections by removing the disjoint set (if required)   
ma_intersect.rb <ma file 1> ... <ma file n>   

Pull out minus values for graphing   
cat KC-WI.txt.neg.csv-WI-WIOB.txt.neg.csv.intsct.csv | awk 'NR%2' | awk -F ' ' '{print $2}' > KC-WI.minus   
cat KC-WI.txt.neg.csv-WI-WIOB.txt.neg.csv.intsct.csv | awk 'NR%2 - 1' | awk -F ' ' '{print $2}' > WI-WIOB.minus   

Combine minus values   
ma_coord_combiner.rb WI-WIOB.minus KC-WI.minus   

Filter by manhattan distance to find interesting sequences   
manhattan.rb WI-WIOB.minus-KC-WI.minus.combined 4   

Count genes in each quadrant   
count_quads.rb WI-WIOB.minus-KC-WI.minus.combined   

Plot and get residual formula with R (after updating quadrant counts in source)   
Rscript ../bio/plot_expr_coords.r WI-WIOB.minus-KC-WI.minus.combined   

Format multi-line FASTA files into single-line FASTA files (if required)   
fa2oneline.pl Contigs.fna > Contigs.nice.fna   

Create indexed seq files   
cat Singletons.fna | tr '\n' ' ' | grep -Po '(?<=>).+?(?=>)' | awk -F' ' '{print $1" "$7}' | tr -d "\r" > 
Singletons.fna.indexed   
cat Contigs.nice.fna | tr '\n' ' ' | grep -Po '(?<=>).+?(?=>)' | awk -F' ' '{print $1" "$6}' | tr -d "\r" > 
Contigs.nice.fna.indexed   

Filter interesting sequences (match first fields in both files, keeping lines from second file)   
ma_foreign_matcher.sh ../WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos.genes Singletons.fna.indexed   

Convert to FASTA   
cat WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos.genes-Singletons.fna.indexed.foreign-intersect.csv | awk -F' ' '{print ">"$1"\n"$2}' > Singletons.pos.genes.fasta   

Query interesting sequences   
ncbi_blast.rb Singletons.pos.genes.fasta   

Produce plottable .csv files from two MA and one DEET .seqs.csv files   
QUAD 1: PBSD10-PBSD22x_KCSD10-KCSD22Y   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBSD10-PBSD22.txt ../limma_files/limma.KCSD10-KCSD22.txt ../output/1432206265.seqs.csv   
QUAD 2: PBLD10-PBLD22X_KCLD10-KCLD22Y   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBLD10-PBLD22.gene.de.txt ../limma_files/limma.KCLD10-KCLD22.gene.de.txt ../output/1432206265.seqs.csv   
QUAD 3: PBLD10-PBSD10X_KCLD10-KCSD10Y   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBLD10-PBSD10.txt ../limma_files/limma.KCLD10-KCSD10.txt ../output/1432206265.seqs.csv   
QUAD 4: PBLD22-PBSD22X_KCLD22-KCSD22Y   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBLD22-PBSD22.txt ../limma_files/limma.KCLD22-KCSD22.gene.de.txt ../output/1432206265.seqs.csv   
QUAD 5: PBSD10-KCSD10X_PBLD10-KCLD10Y   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBSD10-KCSD10.gene.de.txt ../limma_files/limma.PBLD10-KCLD10.gene.de.txt ../output/1432206265.seqs.csv   
QUAD 6: PBSD22-KCSD22X_PBLD22-KCLD22Y   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBSD22-KCSD22.gene.de.txt ../limma_files/limma.PBLD22-KCLD22.gene.de.txt ../output/1432206265.seqs.csv   
QUAD 7: PBSD10-PBSD22 - PBLD10-PBLD22   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBSD10-PBSD22.txt ../limma_files/limma.PBLD10-PBLD22.gene.de.txt ../output/1432206265.seqs.csv   
QUAD 8: PBLD10-PBSD10 - PBLD22-PBSD22   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.PBLD10-PBSD10.txt ../limma_files/limma.PBLD22-PBSD22.txt ../output/1432206265.seqs.csv   
QUAD 9: KCLD10-KCSD10 - KCLD22-KCSD22   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.KCLD10-KCSD10.txt ../limma_files/limma.KCLD22-KCSD22.gene.de.txt ../output/1432206265.seqs.csv   
QUAD 10: KCSD10-KCSD22 - KCLD10-KCLD22   
$ ~/SoftwareProjects/bio/ma2plottable_csv.rb ../limma_files/limma.KCSD10-KCSD22.txt ../limma_files/limma.KCLD10-KCLD22.gene.de.txt ../output/1432206265.seqs.csv   

## MISC. USAGE WITH RNA SEQ DATA
--------------------------------

../../bio/rna_seq_intersect.rb KC.WI.all.values.csv.stripped WI.WIOB.all.values.csv.stripped   
cat KC.WI.all.values.csv.stripped-WI.WIOB.all.values.csv.stripped.intsct.csv | awk 'NR%2' | awk -F' ' '{print $7}' > KC-WI.log2foldChange   
cat KC.WI.all.values.csv.stripped-WI.WIOB.all.values.csv.stripped.intsct.csv | awk 'NR%2 - 1' | awk -F' ' '{print $7}' > WI-WIOB.log2foldChange   
../../bio/ma_coord_combiner.rb WI-WIOB.log2foldChange KC-WI.log2foldChange   
../../bio/count_quads.rb WI-WIOB.log2foldChange-KC-WI.log2foldChange.combined   

Rscript ../../bio/plot_expr_coords.r WI-WIOB.log2foldChange-KC-WI.log2foldChange.combined   

## MISC. MISC.
--------------

Match results with foreign genes (listed in a separate file)   
ma_foreign_matcher.sh <ma_intersect file> <foreign file indexed by gene>   

Pull GO numbers out of a gff3 file (from a gene predictor like Augustus http://bioinf.uni-greifswald.de/augustus/)   
cat Aedes-aegypti-Liverpool_BASEFEATURES_AaegL1.3.gff3 | grep -Po GO:[0-9]+ > go_nums_only.go   

Pull GO numbers out of expression data   

Find intersecting GO numbers   

Search expression data & sequence data for intersecting GO numbers   
