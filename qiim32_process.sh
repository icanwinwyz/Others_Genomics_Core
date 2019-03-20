qiime tools import  --input-path 16S_sample.map --output-path 16S_sample.qza --type SampleData[PairedEndSequencesWithQuality] --source-format PairedEndFastqManifestPhred33
qiime demux summarize --i-data 16S_sample.qza --o-visualization 16S_sample.qzv
#qiime tools view 16S_sample.qzv
qiime dada2 denoise-paired --i-demultiplexed-seqs 16S_sample.qza --o-table 16S_table-dada2.qza --o-representative-sequences 16S_table-dada2-rep.qza  --p-trunc-q 19 --p-trunc-len-f 0 --p-trunc-len-r 0 --verbose >16S.log
qiime feature-table summarize --i-table 16S_table-dada2.qza   --o-visualization 16S_table.qzv  # --m-sample-metadata-file sample-metadata.tsv
qiime feature-table tabulate-seqs   --i-data 16S_table-dada2-rep.qza  --o-visualization 16S_rep-seqs.qzv

qiime tools export ITS_table-dada2.qza   --output-dir .

qiime feature-classifier classify-sklearn --i-classifier /home/genomics/reference/Qiime2/gg-13-8-99-nb-classifier.qza --i-reads  16S_table-dada2-rep.qza  --o-classification 16S_taxonomy.qza
qiime metadata tabulate --m-input-file 16S_taxonomy.qza  --o-visualization 16S_taxonomy.qzv


qiime diversity alpha --i-table 16S_table-dada2.qza --o-alpha-diversity 16S_alpha-rarefaction.qzv --p-metric shannon

qiime tools import --input-path THFv1.6.sort.fasta --output-path THFv1.6.seq.qza  --type 'FeatureData[Sequence]' 
qiime tools import --input-path THFv1.6.sort.taxonomy  --output-path THFv1.6.tax.qza  --type 'FeatureData[Taxonomy]'  --source-format HeaderlessTSVTaxonomyFormat  
qiime feature-classifier fit-classifier-naive-bayes   --i-reference-reads THFv1.6.seq.qza --i-reference-taxonomy THFv1.6.tax.qza  --o-classifier THFv1.6.classifier.qza

