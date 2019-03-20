
cd /home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation

mkdir $1

#$1 is folder name $2 is sequencing ID
#cd /home/genomics/genomics-archive/NextSeq500_RawData
#cd /home/genomics/genomics/data/Temp
cd $1

#sed '1,/Sample_ID/d' /home/genomics/genomics-archive/NextSeq500_RawData/$1/SampleSheet.csv |  cut -d"," -f3|sort| uniq|while read V; do mkdir "$V";done

#sed '1,/Sample_ID/d' /home/genomics/genomics-archive/NextSeq500_RawData/$1/SampleSheet.csv |  cut -d"," -f3|sort| uniq > info.txt


bcl2fastq -R /home/genomics/genomics-archive/NextSeq500_RawData/$1 -o /home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation/$1 -p 30 --ignore-missing-bcl --no-lane-splitting --ignore-missing-filter


mkdir "Data_processing"

mv *.gz Data_processing

mv ./Data_processing/Undetermined* ./

chmod -R 775 /home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation/$1

perl /home/genomics/bin/bcl_summary_mail.pl /home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation/$1/Stats/DemultiplexingStats.xml /home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation/$1/Data_processing/ $1 NextSeq

sendmail -vt < ./mail.txt

rm mail.txt

#echo "Subject: the fastq generation for $1 is done!" | sendmail -v yizhou.wang@cshs.org

