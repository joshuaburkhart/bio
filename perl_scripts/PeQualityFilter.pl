$file = $ARGV[0];
open(FILE, "<$file") or die;

$percent_filter = 50;
$length_filter = 50;
$phred = 33;

while (<FILE>) {

	$R1_ID1 = $_; chomp($R1_ID1);
	$R1_seq = <FILE>; chomp($R1_seq);
	$R1_ID2 = <FILE>; chomp($R1_ID2);
	$R1_qual = <FILE>; chomp($R1_qual);
	$R2_ID1 = <FILE>; chomp($R2_ID1);
	$R2_seq = <FILE>; chomp($R2_seq);
	$R2_ID2 = <FILE>; chomp($R2_ID2);
	$R2_qual = <FILE>; chomp($R2_qual);

	#calculate error probability for read one
	@ASCII = unpack("C*", $R1_qual);
	$prob = 100;
	$x = 1;
	$R1_length = length($R1_qual);
	foreach $value (@ASCII) {
		$value = $value - $phred;
		$prob = $prob * (1-(10**(-$value/10)));
		if ($prob < $percent_filter) {
			$R1_length = ($x-1);
			last;
		}
		$x++;
	}

	if ($R1_length >= $length_filter){
		
		#calculate error probability for read two
		@ASCII = unpack("C*", $R2_qual);
		$prob = 100;
		$x = 1;
		$R2_length = length($R2_qual);
		foreach $value (@ASCII) {
			$value = $value - $phred;
			$prob = $prob * (1-(10**(-$value/10)));
			if ($prob < $percent_filter) {
				$R2_length = ($x-1);
				last;
			}
			$x++;
		}

		if ($R2_length >= $length_filter){

			$R1_seq = substr($R1_seq,0,$R1_length);
			$R1_qual = substr($R1_qual,0,$R1_length);
			$R2_seq = substr($R2_seq,0,$R2_length);
			$R2_qual = substr($R2_qual,0,$R2_length);
		

			#print good sequences to output file
			print "$R1_ID1\n";
			print "$R1_seq\n";
			print "$R1_ID2\n";
			print "$R1_qual\n";
			print "$R2_ID1\n";
			print "$R2_seq\n";
			print "$R2_ID2\n";
			print "$R2_qual\n";
			
		}
	}

}
close(FILE);
