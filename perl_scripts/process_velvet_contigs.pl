#!/usr/bin/perl

# Sujai Kumar
# 2009-09-24

# -v velvet directory as input (can have multiple -v). assumes each directory has
#    contigs.fa
#    stats.txt
#    Log
# -o output_dir name (created in each velvet directory - should not be a path, just a name, eg "pc"
# -m min_contig_length, default 100
# -b binwidth (for contig length histogram), default 1000
# -d delimiter for table, default is "| " (useful for wiki, change to \t or , for excel)

# Gives back
# - N50
# - num of and bases in all contigs (greater than minimum)
# - num of and bases in contigs > 1 kb
# - num of and bases in contigs > 10 kb
# - Contig Histogram
# - Summed contig length (by number of contigs, in sorted order)- 

use strict;
use warnings;
use Getopt::Long;

my @velvetdirs;
my $output_dir = "pc";
my $min_contig_length = 0;
my $binwidth = 1000;
my $delimiter = "| ";

GetOptions (
	"velvetdirs=s"   => \@velvetdirs,
	"output_dir=s"  => \$output_dir,
	"min_contig_length=i" => \$min_contig_length,
	"binwidth=i" => \$binwidth,
	"delimiter=s" => \$delimiter,
);

print join($delimiter,"filename","N50","contigs in N50","Max contig length","contigs >$min_contig_length","bases in contigs >$min_contig_length","contigs >1k","bases in contigs >1k","contigs >10k","bases in contigs >10k","gc","reads used","exp_cov","cov_cutoff") . "\n";

for my $velvet_dir (@velvetdirs)
{
	system ("process_contigs.pl -i $velvet_dir/contigs.fa -m $min_contig_length -b $binwidth -d \"$delimiter\" -o $velvet_dir/$output_dir")==0 or die "Unable to run process_contigs.pl on $velvet_dir/contigs.fa\nCheck if process_contigs.pl is in path and whether $velvet_dir exists and is writable\n";
}