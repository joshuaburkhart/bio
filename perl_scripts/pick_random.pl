#!/usr/bin/perl -w

use strict;
use warnings;

# Usage: pick_random.pl <lines per read> <proportion between 0 to 1> <file(s) with reads>
# Examples:
# To get 20% of the reads from a fasta file: pick_random.pl 2 0.2 reads.fasta  
# To get half the reads from a fastq file:   pick_random.pl 4 0.5 reads.fastq  

my $lines = shift @ARGV;
my $prop  = shift @ARGV;

while (<>)
{
	my $read = $_;
	for (2..$lines) { $_ = <>; $read .= $_ }
	print $read if rand() <= $prop;
}