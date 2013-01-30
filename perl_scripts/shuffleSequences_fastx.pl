#!/usr/bin/perl

die "Usage: shuffleSequences_fastx.pl [2|4] <forward_fasta_or_fastq_file> <reverse_fasta_or_fastq_file> <output_file_name>\n" unless scalar @ARGV == 4;
$lines_per_seq = shift @ARGV;
die "Expecting first argument to be 2 or 4" unless $lines_per_seq =~ /^2|4$/;
$filename1 = shift @ARGV;
$filename2 = shift @ARGV;
$outfilename = shift @ARGV;

open $IN1, "<$filename1" or die "$filename1 not readable\n";
open $IN2, "<$filename2" or die "$filename1 not readable\n";
open $OUT, "> $outfilename" or die "Cannot create $outfilename\n";

while(<$IN1>) {
	print $OUT $_;
	for (2..$lines_per_seq) { $_ = <$IN1>; print $OUT $_ };
	for (1..$lines_per_seq) { $_ = <$IN2>; print $OUT $_ };
}
