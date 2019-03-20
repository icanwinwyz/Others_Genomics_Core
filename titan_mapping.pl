#!/usr/bin/perl -w
use strict;
use Data::Dumper qw(Dumper);
use Getopt::Long;
use Term::ANSIColor   qw(:constants);
$Term::ANSIColor::AUTORESET=1;

=head1 NAME

RNA-seq Mapping(STAR) QC RSEM pipeline v1.1

=head1 DESCRIPTION

This pipeline integrats the Mapping, gene counts/tpm by RSEM and RseQC

This pipeline is compatible for reads of "single-end" and "paired-end" which is specified by the option "-t".

=head1 USAGE

If the "SampleSheet(inputfile.txt)" supplied:

Mapping_auto.pl -e <your_email_address>

If no "SampleSheet(inputfile.txt)" supplied:

perl titan_mapping.pl -e <your_email_address> -t <SE|PE> -o <Human|Mouse> -p <project_ID> -n <1238> -qc

example: perl titan_mapping.pl -t SE -o Breunig -p CAG_GFP_PlateB -qc

=head1 REQUIREMENT

- Perl 5

- perl module: Getopt::Long

=head1 OPTIONS

Running options:

-e or --email [optional]
       Provide your email address if you would like to be notified after jobs completed.

-t or --type [required if no samplesheet supplied]
        The sequencing type is "single end (SE)" or "paired end (PE)"

-o or --organism
       	the reference genoem: Human or Mouse

-p or --project
       	project ID for this run

-qc or --qualitycontrol
		whether run quality contorl (RSeQC) or not after mapping

-n or --nodes
		which nodes the jobs will be ran on (not recommand using csclp1-0-0.local).The number of jobs shouldn't smaller than the number of nodes used

-h or --help
       	Help information


=head1 OUTPUT FILES

bam: folder saving all of bam/bai file after mapping

fastq: folder saving all of .fastq files

final_results: stat for mapping and counts and tpm matrixs.

genes_isoforms_results: folder saving *.genes.results and *.isoforms.results for each sample

log: folder saving all of log files during mapping

node_log: folder saving all or *.e* and *.o* files from clusters

others: useless files

RseQC_results: folder saving all of QC results for each sample (not generated if -qc deactive)

=head1 AUTHOR

If you have any questions, please email: yizhou.wang@cshs.org

Genomics CORE, 09/09/2016

=cut


my ($fastq_path,$email,$type,$org,$proj);
my $qc = 0;

GetOptions(
	'email|e=s' => \$email,
	'type|t=s' => \$type,
	'organism|o=s' => \$org,
	'project|p=s' => \$proj,
	'fastq_path|f=s' => \$fastq_path,
	'qualitycontrol|qc!' => \$qc,
	'help|h' => sub{exec('perldoc',$0);
	exit(0);},
);

my ($proj_ID,$organism,$seq,$file,@data,$number);

chdir $fastq_path;

if( defined $type && defined $org && defined $proj){
	if($type eq "PE"){
		system("ls *fastq.gz > input_file_fastq_tmp.txt");
		open IN, "input_file_fastq_tmp.txt" or die $!;
		my @data = <IN>;
		foreach my $line (@data){
			chomp $line;
			if ($line =~ /R1/){
				my @a = split("R1",$line);
				substr($a[0],-1) = "";
				my $new_name = join(".",$a[0],"R1","fastq.gz");
				if($new_name eq $line){
					next;
				}else{
					my $cmd = "mv $line $new_name";
					system($cmd);
				}
			}elsif($line =~ /R2/){
				my @a = split("R2",$line);
				substr($a[0],-1) = "";
				my $new_name = join(".",$a[0],"R2","fastq.gz");
				if($new_name eq $line){
					next;
				}else{
					my $cmd = "mv $line $new_name";
					system($cmd);
				}
				#	}else{
				#	die "please provide paired-end reads with right format when using the "PE" argument";
			}else{
				die "please provide paired-end reads!\n";
			}
		}

#		system("rm input_file_fastq_tmp.txt");
		system("ls *.fastq.gz|sed 's/.R[1\|2].*fastq.gz//g'|sort -u > input_fastq.txt");
	}elsif($type eq "SE"){
		#	system("ls *.fastq|sed 's/.[fastq|fq]//g' > input_fastq.txt");
		my $temp_cmd = "ls *.fastq.gz|sed 's/\\\(.fastq.gz\\|.fq.gz\\)//g' > input_fastq.txt";
		system($temp_cmd);
		#	system("ls *.fastq|sed 's/\(.fastq\|.fq\)//g' > input_fastq.txt");
	}
	$proj_ID = $proj;
	$organism = $org;
	$seq = $type;
	$file = "input_fastq.txt";
	open IN, $file;
	@data = <IN>;
	$number = scalar(@data);
	if($type eq "PE"){
		foreach my $line (@data){
			chomp $line;
			my $pair1 = $line.".R1".".fastq";
			my $pair2 = $line.".R2".".fastq";
#			print $pair1,"\t",$pair2,"\n";

			if (-e $pair1 && -e $pair2){
				next;
			}else{
				die "no pair mates found for $line!\n";
			}
		}
	}
	close IN;
}elsif( -e "inputfile.txt"){
	print "inputfile exists\n";
	$file = "inputfile.txt";
	open IN, $file or die $!;
	@data = <IN>;
	my $proj_ID_cmd = "awk \'{print \$2}\' $file|uniq";
	chomp($proj_ID = `$proj_ID_cmd`);
	$number = scalar(@data);
	my $comman_org = "awk \'\{print \$3\}\' inputfile\.txt\|uniq";
	chomp($organism = `$comman_org`);
	my $comman_seq = "awk \'\{print \$4\}\' inputfile\.txt\|uniq";
	chomp($seq = `$comman_seq`);
	#print $seq,"\n";
}else{
	die "FATAL ERROR: parameters are not defined or inputfile doesn't exist! See usage with -h\n";
}
print "The sequencing type is:  ";
print RED "$seq\n";
print "The organism is: ";
print RED "$organism\n";
print "The project name is: ";
print RED "$proj_ID\n";
if (defined $email){
	print "The complete notification will be sent to: ";
	print RED "$email\n";
}else{
	print GREEN "no email notification after job complete.\n";
}

my $cmd_path="/common/genomics-core/apps/sequencing_data_distri";

if ($qc ==1){
	print  "QC for samples?  ";
	print RED "YES!\n";
}else{
	print "QC for samples?  ";
	print GREEN "NO!\n";
}

open IN,"input_fastq.txt" or die $!;
open OUT,">run.sh" or die $!;
my @input=<IN>;
print OUT "bash /home/genomics/apps/sequencing_data_distri/loading.sh $organism\n";

foreach my $line(@input){
	chomp $line;
	print OUT "bash /home/genomics/apps/sequencing_data_distri/mapping_star.sh $organism $seq $line\n";
	}

print OUT "bash /home/genomics/apps/sequencing_data_distri/remove_ref.sh $organism\n";

foreach my $line(@input){
        chomp $line;
        print OUT "bash /home/genomics/apps/sequencing_data_distri/rsem_cal.sh $organism $seq $line\n";
        }

foreach my $line(@input){
        chomp $line;
        print OUT "bash /home/genomics/apps/sequencing_data_distri/rseqc.sh $organism $seq $line\n";
        }

print OUT "bash /home/genomics/apps/sequencing_data_distri/gene_results_summary.sh $proj_ID\n";
print OUT "bash /home/genomics/apps/sequencing_data_distri/rseqc_summary.sh\n";
print OUT "bash /home/genomics/apps/sequencing_data_distri/mkdir.sh\n";
print OUT "bash /home/genomics/apps/sequencing_data_distri/organize.sh $proj_ID $email $fastq_path\n";
close OUT;

system("sudo bash run.sh");
#print $nodes_number,"\n";
