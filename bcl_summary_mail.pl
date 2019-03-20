#!/usr/bin/perl -w
use strict;

use JSON;
use Encode;
use Data::Dumper;




my $file = $ARGV[0];
my $fastq_path = $ARGV[1]; 
my $proj_ID = $ARGV[2];
my $seq_type= $ARGV[3];


open IN, $file or die $!;

my @data = <IN>;

my @number = `grep -A 100 \"Project name=\\\"all\\\"\" $file |grep \"<BarcodeCount>\"`;

my $add_total = 0;
my $add_unde = 0;

foreach my $line (@number){
	my @a = split(">",$line);
	my @b = split("</",$a[1]);
	$add_total = $add_total + $b[0];
} 

my @unde;

if ($seq_type eq "NextSeq"){

	@unde = `grep -A 18 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

}elsif($seq_type eq "NovaSeq"){

	@unde = `grep -A 10 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

}elsif($seq_type eq "MiSeq"){

	@unde = `grep -A 3 \"<Sample name=\\\"Undetermined\\\">\" $file|grep \"<BarcodeCount>\"`;

}

foreach my $line (@unde){
	my @a = split(">",$line);
        my @b = split("</",$a[1]);
	$add_unde = $add_unde + $b[0];
}

my $perce = sprintf("%.2f",$add_unde*100/$add_total)."%";


$add_unde =~ s/(?<=\d)(?=(?:\d\d\d)+\b)/,/g;;
$add_total =~ s/(?<=\d)(?=(?:\d\d\d)+\b)/,/g;


open OUT, "> mail.txt" or die $!;


print OUT "To: genomics\@cshs.org\n";
#print OUT "To: yizhou.wang\@cshs.org\n";
print OUT "Subject: Fastq generation is done for $seq_type $proj_ID\n";
print OUT "From: titan_automation\n\n";
print OUT "Total number of reads yielded = $add_total;\n\n";
print OUT "Number of undetermined reads = $add_unde;\n\n";
print OUT "$perce of reads is undetermined;\n\n";
print OUT "The Fastq files are saved in \n";
print OUT "\n";
print OUT $fastq_path,"\n";
print OUT "\n";
print OUT "you can use this path to perform mapping and QC next.\n\n";


if($seq_type eq "NovaSeq"){
	print OUT "Sample_Name\tReads_Yield\n";
	my $json_file = $ARGV[4];
	my $context;
	open TXT, $json_file or die "Can't open $json_file!\n";
	while (<TXT>) {
		$context .= $_;
	}
	close TXT;
	my $obj=decode_json($context);
	my $test = ${$obj}{"sample_qc"};
	foreach my $keys (sort keys %$test){
	print OUT join("  =   ",$keys,&commify(${$obj}{"sample_qc"}{$keys}->{"all"}{"number_reads"})),"\n";
	}
}
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}


__END__
sub commify {
	my $num  = shift;
#	my ($num_l,$num_r) = split /\./, $num;
	$num_l =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
#    	my $tmp = reverse $num_r;
    	$tmp =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
	$num_r = reverse $tmp;
	return ($num_r eq "") ? $num_l : sprintf("%s.%s",$num_l,$num_r);
}
#print $cmd,"\n";

#my @number = system($cmd);


#foreach my $line (@data){
	
