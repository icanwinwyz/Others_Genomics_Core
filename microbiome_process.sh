## Adapter trimming and quality filtering ##
#/home/genomics/anaconda2/bin/cutadapt -a AGATCGGAAGAGC -O 10 -q 19 -o $1.r1.fastq.gz  /home/genomics/genomics-archive/MiSeq_RawData/$2/Data/Intensities/BaseCalls/$1_L001_R1_001.fastq.gz >>log1
#/home/genomics/anaconda2/bin/cutadapt -a AGATCGGAAGAGC -O 10 -q 19 -o $1.r2.fastq.gz  /home/genomics/genomics-archive/MiSeq_RawData/$2/Data/Intensities/BaseCalls/$1_L001_R2_001.fastq.gz >>log2


/home/genomics/anaconda2/bin/cutadapt -a AGATCGGAAGAGC -O 10 -q 19 -o $1.r1.fastq.gz  ./$1_R1_001.fastq.gz >>log1
/home/genomics/anaconda2/bin/cutadapt -a AGATCGGAAGAGC -O 10 -q 19 -o $1.r2.fastq.gz  .//$1_R2_001.fastq.gz >>log2

zcat $1.r1.fastq.gz|wc -l| awk '{print $0/4}' >$1.tmp


## Seqprep to merge paired-end reads that are overlapping into a single long read ##
/home/genomics/anaconda2/bin/SeqPrep -f $1.r1.fastq.gz  -r $1.r2.fastq.gz -1 $1.seqprep_unassembled_R1.fastq.gz -2 $1.seqprep_unassembled_R2.fastq.gz -s $1.seqprep_joined.fastq.gz
zcat $1.seqprep_unassembled_R1.fastq.gz $1.seqprep_joined.fastq.gz|wc -l|awk '{print $0/4}'|paste $1.tmp - >$1.count

## looking for ITS and 16S specific primer sequences and converting the fastq file into a fasta file ##
zcat $1.seqprep_joined.fastq.gz $1.seqprep_unassembled_R1.fastq.gz |grep -B1 '^CTTGGTCATTTAGAGGAAGTAA\|^GCTGCGTTCTTCATCGATGC' |grep -v "^--$" |cut -f1,5- -d':'|sed s/@M03606:/\>$1/|awk '{y= i++ % 2 ; L[y]=$0; if(y==1 && length(L[1])>100) {printf("%s\n%s\n",L[0],L[1]);}}' >$1_ITS.fasta
zcat $1.seqprep_joined.fastq.gz $1.seqprep_unassembled_R1.fastq.gz |grep -B1 '^CTGCTGCCTTCCGTA\|^CTGCTGCCTCCCGTA\|^AGAGTTTGATCATGGCTCAG\|^AGAGTTTGATCCTGGCTCAG'  |grep -v "^--$" |cut -f1,5- -d':'|sed s/@M03606:/\>$1/|awk '{y= i++ % 2 ; L[y]=$0; if(y==1 && length(L[1])>100) {printf("%s\n%s\n",L[0],L[1]);}}' >$1_16S.fasta

zcat $1.seqprep_joined.fastq.gz $1.seqprep_unassembled_R1.fastq.gz |grep -B1 '^ACGGGGCGCAGCAGGCGCGA\|^ACGGGGTGCAGCAGGCGCGA\|^GGACTACAGGGGTATCTAAT\|^GGACTACACGGGTATCTAAT\|^GGACTACCGGGGTATCTAAT\|^GGACTACCCGGGTATCTAAT\|^GGACTACGGGGGTATCTAAT\|^GGACTACGCGGGTATCTAAT' |grep -v "^--$" |cut -f1,5- -d':'|sed s/@M03606:/\>$1/|awk '{y= i++ % 2 ; L[y]=$0; if(y==1 && length(L[1])>100) {printf("%s\n%s\n",L[0],L[1]);}}' >$1_Arch.fasta

wc -l $1_ITS.fasta|awk '{print $2"\t"$1/2}'|paste $1.count - >$1.tmp
wc -l $1_16S.fasta|awk '{print $2"\t"$1/2}'|paste $1.tmp - >$1.count

rm $1.tmp

## Merge all the fasta files into one ##
#rm 16S*_ITS.fasta ITS*_16S.fasta Undetermined_*fasta
#cat *_ITS.fasta > ITS.fna
#cat *_16S.fasta > 16S.fna

