#/home/genomics/apps/cellranger-2.0.0/cellranger mkfastq -R /mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/ --csv=/mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/SampleSheet.csv  --id=cell_test
#/home/genomics/apps/cellranger-2.0.0/cellranger count --fastqs=/home/genomics/test/FT1/outs/fastq_path --sample=FT1 --id=FT1_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38

###$1 is the sequencer name $2 is sequencing ID 
if [ "$1" = "NovaSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NovaSeq/Fastq_Generation"
	SEQ_PATH="/home/genomics/genomics-archive/NovaSeq_RawData"
	STR=$2
	OUTPUT_FOLDER=${STR:(-9):9}

elif [ "$1" = "NextSeq" ]; then

	FOLDER_PATH="/home/genomics/genomics/data/Temp/Sequence_Temp/NextSeq/Fastq_Generation"
        SEQ_PATH="/home/genomics/genomics-archive/NextSeq500_RawData"

else
	
	echo "Please set the select the correct sequencer for data processing!"

fi

cd $FOLDER_PATH
mkdir $2
chmod -R 775 $2
cd $2

/home/genomics/apps/cellranger-2.2.0/cellranger mkfastq --run $SEQ_PATH/$2 --samplesheet=$SEQ_PATH/$2/SampleSheet.csv --output-dir=$FOLDER_PATH/$2 

/usr/bin/perl /home/genomics/bin/bcl_summary_mail.pl $FOLDER_PATH/$2/Stats/DemultiplexingStats.xml $FOLDER_PATH/$2/ $2 $1 $FOLDER_PATH/$2/$OUTPUT_FOLDER/outs/qc_summary.json 

cd $FOLDER_PATH
chmod -R 775 $2
chown -R genomics $2

sendmail -vt < $FOLDER_PATH/$2/mail.txt


#rm mail.txt


