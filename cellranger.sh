#/home/genomics/apps/cellranger-2.0.0/cellranger mkfastq -R /mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/ --csv=/mnt/genomics-archive/NextSeq500_RawData/170728_NS500624_0169_AH5NGFBGX3/SampleSheet.csv  --id=cell_test
#/home/genomics/apps/cellranger-2.0.0/cellranger count --fastqs=/home/genomics/test/FT1/outs/fastq_path --sample=FT1 --id=FT1_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38

###$1 is the folder name $2 is sequencing ID 


cd /home/genomics/genomics/data/Temp/Sequence_Temp/

mkdir $1

chmod $1

cd $1

mkdir fastq_$2

chmod fastq_$2

/home/genomics/apps/cellranger-2.1.0/cellranger mkfastq --run /home/genomics/genomics-archive/NextSeq500_RawData/$2 --samplesheet=/home/genomics/genomics-archive/NextSeq500_RawData/$2/SampleSheet.csv --output-dir=/home/genomics/genomics/data/Temp/Sequence_Temp/$1/fastq_$2 
#~/apps/cellranger-2.0.1/cellranger mkfastq -R $2 --id=$3_fastq --samplesheet=$2/SampleSheet.csv --output-dir=/home/genomics/genomics/data/Temp/$1 
#~/apps/cellranger-2.0.1/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/GRCh38
#~/apps/cellranger-2.0.1/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/mm10
#~/apps/cellranger-1.3.1/cellranger count --fastqs=$1 --sample=$2 --id=$2_results --transcriptome=/home/genomics/reference/CellRanger/mm10
