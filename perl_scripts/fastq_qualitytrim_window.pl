#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Inline 'C';

my ($quality_threshold, $min_length, $window, $offset, $paired) = (10, 20, 0, 64, 0);
GetOptions (
  "quality:i" => \$quality_threshold,
  "min:i" => \$min_length,
  "window:i" => \$window,
  "offset:i" => \$offset,
  "paired:i" => \$paired,
);

my $toprint;
my $first = 0; # variable that flips on each iteration, used for printing or discarding reads as pairs
while (<>) {
	$first = $first ? 0 : 1 if $paired; # flips value of $first for each iteration

	my $seqheader = $_;
	my $seqstring = <>;
	my $qualheader = <>;
	die "Does not seem to be a fastq file\n" unless $qualheader =~ /^\+/;
	chomp(my $qualstring = <>);

	my ($hqrun_start, $hqrun_length) = (0,0);
	maskqual($qualstring, $offset, $window, $quality_threshold, $hqrun_start, $hqrun_length);

	if ($hqrun_length < $min_length) {
		if ($paired and $first) { #skip next 4 lines
			for (1..4) { <> }
			$first = 0;
		}
		$toprint = "";
	} else {
		next if $paired and not $first and not $toprint;
		$toprint .= "$seqheader" . substr($seqstring,$hqrun_start,$hqrun_length) .
			"\n$qualheader" . substr($qualstring,$hqrun_start,$hqrun_length) . "\n";
		unless ($paired and $first) {
			print $toprint;
			$toprint = "";
		}
	}
}

__END__
__C__
void maskqual(char* qstring, int o, int w, int q, SV* hqrun_start, SV* hqrun_length) {
	
	int i;
	char qplus[strlen(qstring) + 2*w];

	for (i = 0; i < w; i++) {
		qplus[i] = q + o; /* won't affect quality sum */
	}
	for (i = w; i < strlen(qstring) + w; i++) {
		qplus[i] = qstring[i-w]; /* copy quality values */
	}
	for (i = strlen(qstring) + w; i < strlen(qstring) + 2*w; i++) {
		qplus[i] = q + o; /* won't affect quality sum */
	}

	int curr_hqrun_start = 0;
	int longest_hqrun_start = 0;
	int curr_hqrun_length = 0;
	int longest_hqrun_length = 0;

	for (i = w; i < strlen(qstring) + w; i++) {
		int sum = 0;
		int j;
		for (j = -w; j <= w; j++) {
			sum = sum + qplus[i+j] - o;
		}
		/* printf("%d ",sum/(2*w+1)); */
		if (sum >= q * (2*w+1)) {
			curr_hqrun_length++;
			if (curr_hqrun_length > longest_hqrun_length) {
				longest_hqrun_length = curr_hqrun_length;
				longest_hqrun_start = curr_hqrun_start;
			} 
		} else {
			curr_hqrun_length = 0;
			curr_hqrun_start = i-w+1;
		}
	}
	sv_setiv(hqrun_start,longest_hqrun_start);
	sv_setiv(hqrun_length,longest_hqrun_length);
}
