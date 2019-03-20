#/home/genomics/apps/cellranger-2.0.0/cellranger mkfastq -R /mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/ --csv=/mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/SampleSheet.csv  --id=cell_test
#/home/genomics/apps/cellranger-2.0.0/cellranger count --fastqs=/home/genomics/test/FT1/outs/fastq_path --sample=FT1 --id=FT1_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38

###$1 is the folder name $2 is sequencing ID 



#/home/genomics/apps/cellranger-2.0.1/cellranger mkfastq --run /home/genomics/genomics-archive/NextSeq500_RawData/$2 --samplesheet=/home/genomics/genomics-archive/NextSeq500_RawData/$2/SampleSheet.csv --output-dir=/home/genomics/genomics/data/Temp/Sequence_Temp/$1/fastq 
#~/apps/cellranger-2.0.1/cellranger mkfastq -R $2 --id=$3_fastq --samplesheet=$2/SampleSheet.csv --output-dir=/home/genomics/genomics/data/Temp/$1 
#/home/genomics/apps/cellranger-2.1.0/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38 --localcores=15 --localmem=220
/home/genomics/apps/cellranger-2.1.0/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38 
#~/apps/cellranger-2.0.1/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/mm10
#~/apps/cellranger-1.3.1/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/mm10

echo "Subject: 10X data processing is done" | sendmail -v yizhou.wang@cshs.org
