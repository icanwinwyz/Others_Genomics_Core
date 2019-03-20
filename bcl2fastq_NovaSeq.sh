###$1 is the sequencer name $2 is sequencing ID
if [ "$1" = "NovaSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation"
	SEQ_PATH="/home/genomics/genomics-archive/NovaSeq_RawData"
	STR=$2
	OUTPUT_FOLDER=${STR:(-9):9}

elif [ "$1" = "NextSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation"
        SEQ_PATH="/home/genomics/genomics-archive/NextSeq500_RawData"

elif [ "$1" = "MiSeq" ]; then
	
	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/MiSeq/Fastq_Generation"
        SEQ_PATH="/home/genomics/genomics-archive/MiSeq_RawData"

else

	echo "Please set the select the correct sequencer for data processing!"

fi

cd $FOLDER_PATH
mkdir $2
chmod 775 $2
cd $2


bcl2fastq -R $SEQ_PATH/$2 -o $FOLDER_PATH/$2 -p 30 --ignore-missing-bcl --no-lane-splitting --ignore-missing-filter

if [ "$1" = "NovaSeq" ]; then

	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/ $2 NovaSeq $FOLDER_PATH/$2/$OUTPUT_FOLDER/outs/qc_summary.json

	sendmail -vt < ./mail.txt
	
#	chmod -R 775 $FOLDER_PATH/$2
	
#	chown genomics -R $FOLDER_PATH/$2
	
	rm mail.txt

elif [ "$1" = "NextSeq" ]; then

	mkdir "Data_processing"

	mv *.gz Data_processing

	mv ./Data_processing/Undetermined* ./

	chmod -R 775 $FOLDER_PATH/$2

	chown genomics -R $FOLDER_PATH/$2	

	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/Data_processing $2 NextSeq
#echo "Subject: the fastq generation for $1 is done!" | sendmail -v yizhou.wang@cshs.org
	sendmail -vt < ./mail.txt

	rm mail.txt

elif [ "$1" = "MiSeq" ]; then

	/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/ $2 MiSeq

        sendmail -vt < ./mail.txt
	
	chmod -R 775 $FOLDER_PATH/$2

	chown genomics -R $FOLDER_PATH/$2

        rm mail.txt

fi
