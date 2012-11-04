#!/usr/bin/perl

while (<>) {
	$bases += length(<>) - 1;
	$_ = <>;
	die "Does not seem to be a fastq file\n" unless /^\+/;
	<>;
	$reads++;
}
print "Reads: $reads\n";
print "Bases: $bases\n";
