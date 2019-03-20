~/work/Downloads/lefse/format_input.py $1_lefse.txt $1_lefse.in  -c 1  -o 1000000 # -s 2 -u 3
~/work/Downloads/lefse/run_lefse.py  $1_lefse.in $1_lefse.res  -b 500
~/work/Downloads/lefse/plot_res.py $1_lefse.res $1_LEfSe.bar.pdf --format pdf --subclades -1
mkdir $1_biomarkers
~/work/Downloads/lefse/plot_features.py $1_lefse.in $1_lefse.res $1_biomarkers/ --format pdf
~/work/Downloads/lefse/plot_cladogram.py $1_lefse.res $1_LEfSe.cladogram.pdf --format pdf
~/work/Downloads/lefse/run_lefse.py  $1_lefse.in $1_LEfSe.all.txt  -a 1.0 -w 1.0 -l 0.0 -e 1 --min_c 1

