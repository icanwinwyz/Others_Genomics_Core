FOLDER_PATH=$1

mkdir $FOLDER_PATH/Final_Results

cd $FOLDER_PATH/$2_results/

/home/genomics/anaconda2/bin/Rscript ~/genomics/bin/10X_expr_matrix_raw_nor_noQC.R ./ $2

mv $FOLDER_PATH/$2_results/$2_Expr* $FOLDER_PATH/Final_Results 

cp $FOLDER_PATH/$2_results/outs/*.cloupe $FOLDER_PATH/Final_Results/$2.cloupe

cp $FOLDER_PATH/$2_results/outs/web* /home/genomics/genomics-archive/NextSeq500_RawData/Results_Temp/$2_QC.html



