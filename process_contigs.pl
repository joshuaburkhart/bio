#!/usr/bin/perl

# Sujai Kumar
# 2009-09-24

# -i contigs as input, in fasta format
# -o output_dir (created if it doesn't exist)
# -m min_contig_length, default 0
# -b binwidth (for contig length histogram), default 1000
# -d delimiter for table, default is "| " (useful for wiki, change to \t or , for excel)

# Gives back
# - N50
# - num of and bases in all contigs
# - num of and bases in contigs > 1 kb
# - num of and bases in contigs > 10 kb
# - Contig Histogram
# - Summed contig length (by number of contigs, in sorted order)- 

use strict;
use warnings;
use Getopt::Long;

my $infile;
my $output_dir = "pc";
my $graphics; # plot graphs only if -g is true
my $min_contig_length = 0;
my $binwidth = 1000;
my $delimiter = "| ";

GetOptions (
	"infile=s"      => \$infile,
	"output_dir=s"  => \$output_dir,
	"min_contig_length=i" => \$min_contig_length,
	"binwidth=i" => \$binwidth,
	"delimiter=s" => \$delimiter,
);

### create output_dir if it doesn't exist
if (-d $output_dir) {
	print STDERR "DIR $output_dir exists, existing process_contigs.pl output files will be overwritten\n";
} else {
	mkdir $output_dir or die "Unable to create $output_dir\n";
	print STDERR "DIR $output_dir created\n";
}

#--------------- Read in contigs from fasta file -------------------

&multilinefastafile2singleline ($infile);
my $insequences = &fastafile2hash($infile);
my @sequences;

my $all_contigs_length;
my $gc_count = 0;
open  LENGTH,">$output_dir/contig_lengths_gc.txt" or die $!;
print LENGTH "length\tgc\n";
for my $chrontig (keys %{$insequences})
{
	next if length($$insequences{$chrontig}{seq}) < $min_contig_length;
	my $gc_seq = ($$insequences{$chrontig}{seq} =~ tr/gcGC/gcGC/);
	$gc_count += $gc_seq;
	print LENGTH length($$insequences{$chrontig}{seq}) . "\t" . ($gc_seq/length($$insequences{$chrontig}{seq})) . "\n";
	$all_contigs_length += length($$insequences{$chrontig}{seq});
	push @sequences, [length($$insequences{$chrontig}{seq}), $chrontig, $$insequences{$chrontig}{seq}, ($gc_seq/length($$insequences{$chrontig}{seq}))];
}
close LENGTH;

#--------------- Get stats from velvet directory if -i inputfasta is a velvet contigs.fa -------------------

my ($reads_used, $reads_total, $exp_cov, $cov_cutoff, $velvettag) = ("-","-","-","-","-");

# if $infile is a velvet contigs.fa file, then its possible that there is an outfile and a Log file in the same dir. Use that to get Exp cov and Number of reads used
$infile =~ m'^(.*?)[^/]+$';
my $curdir = $1; $curdir = "." unless $curdir;
if (-e "$curdir/out")
{
	`tail -3 $curdir/out` =~ m'Coverage = (\d+\.\d+).*cutoff = (\d+\.\d+).*using (\d+)/(\d+)'s;
	$exp_cov = $1;
	$cov_cutoff = $2;
	$reads_used  = $3;
	$reads_total = $4;
}
if (-e "$curdir/Log") 
{
	my $logcontent = do { local( @ARGV, $/ ) = "$curdir/Log" ; <> } ;
	if ($logcontent =~ m'.*velvetg\d*\s+\S+\s+(.+?)\n.+?using (\d+)/(\d+).+?$'s)
	{
		$velvettag = "_$1";
		$reads_used  = $2;
		$reads_total = $3;
		$velvettag =~ s/-exp_cov\s+(\S+)/c$1/;
		$velvettag =~ s/-cov_cutoff\s+(\S+)/t$1/;
		$velvettag =~ s/-max_coverage\s+(\S+)/m$1/;
		$velvettag =~ s/-ins_length(\d?)\s+(\S+)/i$1$2/;
		$velvettag =~ s/-ins_length_sd(\d?)\s+(\S+)/s$1$2/;
		$velvettag =~ s/\s+//g;
	}
}

#--------------- Gather Plots Data, Find N50, Print sorted contig file -------------------

my $contig1k_count = 0;
my $contig1k_length = 0;
my $contig10k_count = 0;
my $contig10k_length = 0;

open SORTED, ">$output_dir/sorted_contigs.fa" or die $!;
open STATS, ">$output_dir/contig_stats.txt" or die $!;

my $N50_value = 0;
my $N50_found = 0;
my $N50_contigs = 0;

my @sorted_by_contig_length = sort {$b->[0] <=> $a->[0]} @sequences;
my $max_contig_length = $sorted_by_contig_length[0]->[0];

my $summed_contig_length = 0;
foreach (@sorted_by_contig_length) {

	my $curr_contig_length = $_->[0];

	$summed_contig_length += $curr_contig_length;
	
	### sorted contigs file
	print SORTED ">". $_->[1] . "$velvettag\n" . $_->[2] . "\n";

	if ($curr_contig_length >= 1000) {
		$contig1k_count++;
		$contig1k_length += $curr_contig_length;
	}
	if ($curr_contig_length >= 10000) {
		$contig10k_count++;
		$contig10k_length += $curr_contig_length;
	}
	
	$N50_contigs++ unless $N50_found;
	
	if ($summed_contig_length > ($all_contigs_length / 2) and $N50_found == 0) {
		$N50_value = $curr_contig_length;
		$N50_found = 1;
	}
}

print STATS "N50 " . $N50_value . "\n";
print STATS "Number of contigs in N50 " . $N50_contigs . "\n";
print STATS "Max_contig_size " . $max_contig_length . "\n";
print STATS "Number of contigs (>$min_contig_length) " . @sequences . "\n";
print STATS "Number of bases in contigs (>$min_contig_length) " . $all_contigs_length . "\n";
print STATS "Number of contigs >=1kb " . $contig1k_count . "\n";
print STATS "Number of bases in contigs >=1kb " . $contig1k_length . "\n";
print STATS "Number of contigs >=10kb " . $contig10k_count . "\n";
print STATS "Number of bases in contigs >=10kb " . $contig10k_length . "\n";
print STATS "GC Content of contigs " . (100 * $gc_count/$all_contigs_length) . "\n";
print STATS "Reads used $reads_used/$reads_total\n";
print STATS "Expected coverage $exp_cov\n";
print STATS "Coverage cutoff $cov_cutoff\n";

print STDOUT join($delimiter,($infile,$N50_value,$N50_contigs,$max_contig_length,(scalar @sequences),$all_contigs_length,$contig1k_count,$contig1k_length,$contig10k_count,$contig10k_length,int(10000 * $gc_count/$all_contigs_length)/100),$reads_used,$exp_cov,$cov_cutoff) . "\n";

open  TMP,">$output_dir/process_contigs.R" or die $!;
print TMP <<R;
contigs=read.table("$output_dir/contig_lengths_gc.txt",header=TRUE)
pdf("$output_dir/contig_lengths_gc.pdf",10,10)
par(mfrow=c(2,2))
hist(contigs\$gc,breaks=100)
plot(cumsum(sort (contigs\$length,decreasing=TRUE)),xlab="Number of contigs",ylab="Cumulative contig length")
dev.off()
R
close TMP;
# run R script
system("R -f $output_dir/process_contigs.R >/dev/null 2>&1");

###################################################################################################
sub multilinefastafile2singleline
{
	my $fastafile = shift @_;
	unless (`wc -l $fastafile | cut -f1 -d' '` == (`grep -c '^>' $fastafile` * 2))
	{
		my $tmpfile = rand();
		open FA,  "<$fastafile" or die "Can't open $fastafile\n";
		open TMP, ">$tmpfile" or die "Can't open $tmpfile for multiline fasta to singleline\n";
		my $i = 0;
		while (<FA>) {
			$i++;
			if (/^>/) { print TMP "\n" unless $i == 1; print TMP }
			elsif (/^\s*$/) { next }
			elsif (/\d/) { chomp; print TMP; print TMP " " }
			else { chomp; print TMP }
		}
		print TMP "\n";
		close FA;
		close TMP;
		rename $tmpfile,$fastafile or die $!
	}
}
###################################################################################################
sub fastafile2hash
{
	my $fastafile = shift @_;
	my $changecase = "N"; $changecase = shift @_ if @_;
	my %sequences;
	open FA, "<$fastafile" or die $!;
	while (<FA>)
	{
		next unless /^>(\S+)(.*)/;
		$sequences{$1}{desc} = $2;
		if ($changecase eq "L")    { chomp($sequences{$1}{seq} = lc(<FA>)) }
		elsif ($changecase eq "U") { chomp($sequences{$1}{seq} = uc(<FA>)) }
		elsif ($changecase eq "N") { chomp($sequences{$1}{seq} = <FA>) }
	}
	return \%sequences;
}
