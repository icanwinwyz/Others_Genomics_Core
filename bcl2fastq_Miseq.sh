
cd /home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation

mkdir $1 

#$1 is folder name $2 is sequencing ID
#cd /home/genomics/genomics-archive/NextSeq500_RawData
#cd /home/genomics/genomics/data/Temp
cd $1

mv /var/www/html/upload/final/comments_$1.txt ./

sed '1,/Sample_ID/d' /home/genomics/genomics-archive/MiSeq_RawData/$1/SampleSheet.csv |  cut -d"," -f9|sort| uniq| while read V; do mkdir "$V"; done

sed '1,/Sample_ID/d' /home/genomics/genomics-archive/MiSeq_RawData/$1/SampleSheet.csv |  cut -d"," -f9|sort| uniq > info.txt

bcl2fastq -R /home/genomics/genomics-archive/MiSeq_RawData/$1 -o /home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation/$1 -p 30 --ignore-missing-bcl --no-lane-splitting --ignore-missing-filter

#sed '1,/Sample_ID/d' /home/genomics/genomics-archive/MiSeq_RawData/$1/SampleSheet.csv |   cut -d"," -f1,9|sed 's/,/"\t"/g'| sed 's/"//g'| while read v u ; do mv "$v"*gz ./$u; done


#mkdir "Data_processing"

#mv *.gz Data_processing

#mv ./Data_processing/Undetermined* ./

chmod -R 775 /home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation/$1

#perl /var/www/html/script/format.pl temp.txt 

perl /home/genomics/bin/bcl_summary_mail_Miseq.pl /home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation/$1/Stats/DemultiplexingStats.xml /home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation/$1 $1 $2 $3 $4 comments_$1.txt $5 info.txt

sendmail -vt < ./mail.txt

rm mail.txt
rm info.txt
rm comments*.txt
#rm temp.txt
#echo "Subject: the fastq generation for $1 is done!" | sendmail -v yizhou.wang@cshs.org

