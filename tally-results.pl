#!/usr/bin/perl -w
#
# Written by Julian Catchen <catchen@cs.uoregon.edu>
#

#use lib '/mnt/netapp/home1/catchen/research/perl/lib/perl5/site_perl/5.8.3/';
use strict;
use Statistics::Descriptive;
use Bio::SeqIO;

my $debug   = 0;
my $in_path = ".";
my $fasta   = "";
my $type    = "";
my $ctg_len_lim = 500; # Only record coverage of contigs longer than this (in base pairs).

parse_command_line();

my (%paths, @files, $num_files, %counters, $file, $i);

%paths = (
    'phrap' => {
	'path'    => "ls -1 -F $in_path/ | grep /",
	'file'    => "(.+)\/",
	'barcode' => '(.+)/final.fa',
	'fasta'   => 'final.fa'
    },
    'velvet' => {
	'path'    => "ls -1 -F $in_path/ | grep /",
	'file'    => "(sample_[ACGT]{3,5})\/",
	'barcode' => 'sample_([ACGT]{3,5})\/contigs.fa',
	'fasta'   => 'contigs.fa'
    },
    'agg' => {
	'path'    => "ls -1 -F $in_path/ | grep /",
	'file'    => "(.+)\/",
	'barcode' => '(.+)\/contigs.fa',
	'fasta'   => 'contigs.fa'
    }
);

build_file_list(\@files);

$num_files = scalar(@files);

$i = 1;

foreach $file (@files) {

    $file .= "/" . $paths{$type}->{'fasta'};

    printf(STDERR "Processing file % 3s of % 3s [%s]\n", $i, $num_files, $file);

    process_sample($file, \%counters);

    $i++;
}

print_results(\%counters);

sub process_sample {
    my ($file, $counters) = @_;

    my ($barcode, $contigs, $contig, $buckets, @data, @cov, $c);

    ($barcode) = ($file =~ /$paths{$type}->{'barcode'}/);

    $counters->{$barcode} = {};
    $counters->{$barcode}->{'max'}    = 0;
    $counters->{$barcode}->{'count'}  = 0;
    $counters->{$barcode}->{'avg'}    = 0;
    $counters->{$barcode}->{'median'} = 0;
    $counters->{$barcode}->{'n50'}    = 0;
    $counters->{$barcode}->{'cov'}    = 0;
    $counters->{$barcode}->{'tot'}    = 0;

    # Check that the file exists
    return if (!-e "$in_path/$file");

    $contigs = Bio::SeqIO->new(-file => "$in_path/$file", -format => "fasta" );

    # Calculate average, max, median contig lengths
    while ($contig = $contigs->next_seq()){
	$counters->{$barcode}->{'count'}++;
	push(@data, $contig->length());

	if ($type ne "phrap" && $contig->length() > $ctg_len_lim) {
	    ($c) = ($contig->id() =~ /NODE_\d+_length_\d+\.?\d*_cov_(\d+\.?\d*)/);
	    push(@cov, $c);
	}
    }

    if (scalar(@data) > 0) {
	$counters->{$barcode}->{'n50'}   = n50(\@data);

	foreach $contig (@data) {
	    $counters->{$barcode}->{'tot'} += $contig;
	}

	my $stat = Statistics::Descriptive::Full->new();

	$stat->add_data(@data);

	$counters->{$barcode}->{'avg'}    = $stat->mean();
	$counters->{$barcode}->{'max'}    = $stat->max();
	$counters->{$barcode}->{'median'} = $stat->median();
    }

    if (scalar(@cov) > 0) {
	my $stat = Statistics::Descriptive::Full->new();

	$stat->add_data(@cov);

	$counters->{$barcode}->{'cov'} = $stat->mean();
    }

    #
    # Calculate distribution of contig sizes
    #
    $buckets = {};
    calc_distribution(\@data, $buckets);
    $counters->{$barcode}->{'dist'} = $buckets;
}

sub n50 {
    my ($data) = @_;

    #
    # The N50 size of a set of entities (e.g., contigs or scaffolds)
    # represents the largest entity E such that at least half of the
    # total size of the entities is contained in entities larger than
    # E. For example if we have a collection of contigs with sizes 7,
    # 4, 3, 2, 2, 1, and 1 kb, the N50 length is 4 because we can
    # cover 10 kb with contigs bigger than 4kb.
    #

    my ($n50, $contig_len, $total, $running) = 0;

    @{$data} = sort {$b <=> $a} @{$data};

    # Calculate the total length of the contigs
    foreach $contig_len (@{$data}) {
	$total += $contig_len;
    }

    $contig_len = 0;
    $total      = $total / 2;

    foreach $contig_len (@{$data}) {
	$running += $contig_len;
	$n50 = $contig_len;

	last if ($running >= $total);
    }

    return $n50;
}

sub calc_distribution {
    my ($ctg_lens, $buckets) = @_;

    my ($bucket, $len, $key);

    #
    # Sort the Sanger reads into 10bp buckets.
    #
    foreach $len (@{$ctg_lens}) {

	#
	# Round the insert length to the neares 100bp
	#
	$bucket = int($len / 100) * 100;

	$buckets->{$bucket}++;

	print STDERR "placing read $len into bucket $bucket.\n" if ($debug);
    }
}

sub print_results {
    my ($counters) = @_;

    my ($log, $barcode, $bucket);

    $log = $in_path . "/assembled.log";
    open(LOG, ">$log") or die("Unable to open log file: '$log'\n");

    print LOG 
	"Barcode\t",
	"Contigs\t",
	"Max Length\t",
	"Avg Length\t",
	"N50\t",
	"Mean Coverage\t",
	"Total Length\n";

    foreach $barcode (sort keys %{$counters}) {
	printf(LOG "%s\t%d\t%d\t%.2f\t%d\t%.2f\t%d\n", 
	       $barcode,
	       $counters->{$barcode}->{'count'},
	       $counters->{$barcode}->{'max'},
	       $counters->{$barcode}->{'avg'},
	       $counters->{$barcode}->{'n50'},
	       $counters->{$barcode}->{'cov'},
	       $counters->{$barcode}->{'tot'});
    }

    print LOG "\n\n";

    #
    # Print distribution of contig sizes
    #
    foreach $barcode (sort keys %{$counters}) {
	print LOG "# $barcode Contig length distribution\n";

	foreach $bucket (sort {$b <=> $a} keys %{$counters->{$barcode}->{'dist'}}) {
	    print LOG 
		$bucket, "\t",
		$counters->{$barcode}->{'dist'}->{$bucket}, "\n";
	}

	print LOG "\n\n";
    }

    close(LOG);

    print STDERR "Results written to '$log'\n";
}

sub build_file_list {
    my ($files) = @_;

    if (length($fasta) > 0) {
	push(@{$files}, $fasta);
	return;
    }

    my (@ls, $line, $file);

    @ls = `$paths{$type}->{'path'}`;

    foreach $line (@ls) {
	chomp $line;

	($file) = ($line =~ /$paths{$type}->{'file'}/);

	print STDERR "LINE: $line; FILE: $file\n" if ($debug);

	push(@{$files}, $file);
    }
}

sub parse_command_line {
    while (@ARGV) {
	$_ = shift @ARGV;
	if    ($_ =~ /^-p$/) { $in_path  = shift @ARGV; }
	elsif ($_ =~ /^-t$/) { $type     = shift @ARGV; }
	elsif ($_ =~ /^-f$/) { $fasta    = shift @ARGV; }
	elsif ($_ =~ /^-d$/) { $debug++; }
	elsif ($_ =~ /^-h$/) { usage(); }
	else {
	    usage();
	}
    }

    $in_path  = substr($in_path, 0, -1)  if (substr($in_path, -1)  eq "/");

    if ($type ne "phrap" && $type ne "velvet" && $type ne "agg") {
	print STDERR "You must specify the program used to generate the results.\n";
	usage();
    }
}

sub usage {
    print STDERR <<EOQ; 
tally-results.pl -p path -t type [-d] [-h]
  p: path to the sequence and quality score files.
  t: type of assembler used to generate the results, 'velvet', 'phrap', or 'agg'.
  h: display this help message.
  d: turn on debug output.

EOQ

  exit(0);
}
