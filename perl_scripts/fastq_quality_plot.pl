#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($offset, $sample) = (64, 1000);
GetOptions (
  "offset:i" => \$offset,
  "sample:i" => \$sample, # sample every $sample reads
);

my %count;
my %qualsf;

die "\n Example: fastq_quality_plot.pl -o 64 -s 1000 reads.fastq\n" . 
	" -o : fastq ascii value offset (default 64)\n" .
	" -s : sample after this many reads (default 1000)\n" . 
	" Takes paired or unpaired fastq reads as input\n\n" unless @ARGV;

while (<>) {
	my $seq_header = $_;
	my $dir = ($seq_header =~ /^\S+\/([12])\b/) ? $1 : 0;
	<>; # skip sequence
	$_ = <>; # quals header
	die "Does not appear to be a fastq file\n" unless /^\+/;
	my $quals = <>;
	$count{$dir}++;
	next if ($count{$dir} % $sample);
	my $cycle = 1;
	while ($quals =~ /(.)/g) {
		my $qual = ord($1) - $offset;
		$qualsf{$dir}{$cycle}{$qual}++;
		$cycle++;
	};
}

print STDERR "next process\n";
for my $dir (keys %qualsf) {	
	open QUALITYFILE, ">q_by_cycle_$dir.txt" or die $!;
	for my $cycle (sort {$a <=> $b} keys %{$qualsf{$dir}}) {
		my $sum_f = 0;
		my $sum_qual_f = 0;
		my $sum_qual2_f = 0;
		for my $qual (keys %{$qualsf{$dir}{$cycle}}) {
			$sum_f += $qualsf{$dir}{$cycle}{$qual};
			$sum_qual_f += $qual * $qualsf{$dir}{$cycle}{$qual};
			$sum_qual2_f += $qual * $qual * $qualsf{$dir}{$cycle}{$qual};
		}
		my $mean = 0;
		$mean = $sum_qual_f / $sum_f;
		my $std_dev = 0;
		$std_dev = sqrt ( ($sum_qual2_f/$sum_f) - ($mean * $mean) );
		print QUALITYFILE "$cycle\t$mean\t$std_dev\n";
	}
}
