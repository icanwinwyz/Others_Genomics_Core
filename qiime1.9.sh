export LC_ALL=C
#parallel_pick_otus_blast.py -i $1.fasta  -b /stf/home/cluster/GenomicsCore/NGS/Microbiome/$2.sort.fasta -O 500 -o otus_$2 #-s 0.97
make_otu_table.py -i $1_otus.txt -o $1_table.biom -t /stf/home/cluster/GenomicsCore/NGS/Microbiome/$2.taxonomy
#awk '{OFS="\t";for (i=2;i<=NF;i=i+1) print $1,$i }' $1_otus.txt |sort -k1,1 |join - /stf/home/cluster/GenomicsCore/NGS/Microbiome/$2.taxonomy -t'	'|sort -k2,2 >$1_otus.read.taxon
#filter_otus_from_otu_table.py -i $1_table.biom -o Filtered_otu_table_$1.biom --min_count_fraction 0.00001
biom convert -i $1_table.biom -o $1_table_$2.txt  --to-tsv --header-key="taxonomy"
summarize_taxa_through_plots.py -i $1_table.biom  -f -o Taxa_summary 
#make_otu_heatmap_html.py -i Filtered_otu_table_$1.biom  -o Heatmap
#alpha_rarefaction.py -i $1_table.biom  -m ../mapping.txt -o rarefaction/ -p /stf/home/cluster/GenomicsCore/NGS/Microbiome/params_ITS.txt
biom summarize-table -i $1_table.biom   -o $1_otu_table_summary.txt
export LC_ALL=C 
make_otu_table.py -i $1_otus.txt -o $1_greengene.biom -t /stf/home/cluster/GenomicsCore/NGS/Microbiome/gg_13_5_taxonomy.txt
#filter_otus_from_otu_table.py -i $1_greengene.biom -o $1_greengene_n5.biom --min_count_fraction 0.00001
biom convert -i $1_greengene.biom -o $1_greengene.txt  --to-tsv --header-key="taxonomy"
#pick_rep_set.py -i $1_otus.txt -f ../$1.fna -o $1.rep.fasta
#assign_taxonomy.py -i $1.rep.fasta -m rdp -o ./
#make_otu_table.py -i $1_otus.txt -t $1.rep_tax_assignments.txt -o $1_table.biom
#filter_otus_from_otu_table.py -i $1_table.biom -o $1_table_n5.biom --min_count_fraction 0.00001

make_otu_heatmap_html.py -i $1_table_n5.biom  -o Heatmap_16S
summarize_taxa_through_plots.py -f -i $1_table_n5.biom  -o Taxa_summary 
summarize_taxa_through_plots.py -f -i $1_greengene_n5.biom  -o Taxa_summary

#align_seqs.py -i ../$1.rep.fasta -o ./
#filter_alignment.py -i $1.rep_set_aligned.fasta  -o ./
#make_phylogeny.py -i $0.rep_set_aligned_filtered.fasta -o rep_phylo.tre
#alpha_rarefaction.py -i $1_table_n5.biom  -m ../mapping.txt -f -o rarefaction_16S -p /stf/home/cluster/tangjx/work/DB/params_16S.txt -t rep_phylo.tre -e $2
#beta_diversity_through_plots.py -i $1_table_n5.biom -f -m ../mapping.txt -o beta_diversity_16S -t rep_phylo.tre -e $2 
#jackknifed_beta_diversity.py -i $1_table_n5.biom -f -t rep_phylo.tre -m ../mapping.txt -o Jackknife_16S -e $2
#make_bootstrapped_tree.py -m Jackknife_16S/weighted_unifrac/upgma_cmp/master_tree.tre -s Jackknife_16S/weighted_unifrac/upgma_cmp/jackknife_support.txt -o jackknife_merged_Q20_weighted_unifrac_$1.pdf
#make_bootstrapped_tree.py -m Jackknife_16S/unweighted_unifrac/upgma_cmp/master_tree.tre -s Jackknife_16S/unweighted_unifrac/upgma_cmp/jackknife_support.txt -o jackknife_merged_Q20_unweighted_unifrac_$1.pdf
export LC_ALL=C

## Input files 
##concatented fasta file (*.fna)
## reference name either 16S(gg) or ITS(THF)

parallel_pick_otus_blast.py -i $1.fna  -b /stf/home/cluster/GenomicsCore/NGS/Microbiome/$2.sort.fasta -O 500 -o otus_$2 #-s 0.97

make_otu_table.py -i $1_otus.txt -o $1_table.biom -t /stf/home/cluster/GenomicsCore/NGS/Microbiome/$2.taxonomy
#awk '{OFS="\t";for (i=2;i<=NF;i=i+1) print $1,$i }' $1_otus.txt |sort -k1,1 |join - /stf/home/cluster/GenomicsCore/NGS/Microbiome/$2.taxonomy -t'      '|sort -k2,2 >$1_otus.read.taxon
#filter_otus_from_otu_table.py -i $1_table.biom -o Filtered_otu_table_$1.biom --min_count_fraction 0.00001
#convert_biom.py -i Filtered_otu_table_$1.biom -o $1_table_$2.txt -b --header_key taxonomy
biom convert -i $1_table.biom -o $1_table_$2.txt  --to-tsv --header-key="taxonomy"
/stf/csclp1/bin/Rscript /stf/home/cluster/GenomicsCore/bin/Percentage_OTU.R $1_table_$2
summarize_taxa_through_plots.py -i $1_table.biom  -f -o Taxa_summary
#make_otu_heatmap_html.py -i Filtered_otu_table_$1.biom  -o Heatmap
#alpha_rarefaction.py -i $1_table.biom  -m ../mapping.txt -o rarefaction/ -p /stf/home/cluster/GenomicsCore/NGS/Microbiome/params_ITS.txt
biom summarize-table -i $1_table.biom   -o $1_otu_table_summary.txt

