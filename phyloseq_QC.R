rm(list=ls())
library(phyloseq)
library(ggplot2)
library(plyr)
library(cluster)
library(ade4)
library(vegan)
library(xlsx)

args= commandArgs(TRUE)
name=args[1]
otu=paste(name,".txt",sep='')
map=paste(name,".map",sep='')


a=read.table(otu,sep='\t',header=T,row.names=1,check=F,skip=1,comment.char="")
taxmat=matrix(unlist(strsplit(as.character(a$taxonomy),"[;]")),ncol=7,byrow=T)
taxmat=gsub("\\s", "", taxmat)
otumat=a[,-ncol(a)]
rownames(taxmat) <- rownames(otumat)
colnames(taxmat) <- c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")
OTU = otu_table(otumat, taxa_are_rows = TRUE)
TAX = tax_table(taxmat)
physeq = phyloseq(OTU, TAX)

b=read.table(map,sep='\t',header=T,row.names=1,check=F,comment.char="")
condition=(b[colnames(otumat),]$Treatment)
sampledata = sample_data(data.frame(Treatment=(condition), Depth = colSums(otumat), row.names = sample_names(physeq), stringsAsFactors = FALSE))
physeq=merge_phyloseq(physeq, sampledata)
physeq=prune_samples(rownames(b),physeq)
physeq=prune_taxa(taxa_sums(physeq) > 0, physeq)
OTU = otu_table(physeq)
TAX = tax_table(physeq)


alpha=data.frame(sample_data(physeq),estimate_richness(physeq))
pshannon= if (nlevels(alpha$Treatment)<3) wilcox.test(Shannon~Treatment,alpha)$p.value else kruskal.test(Shannon~Treatment,alpha)$p.value
pinv= if (nlevels(alpha$Treatment)<3) wilcox.test(InvSimpson~Treatment,alpha)$p.value else kruskal.test(InvSimpson~Treatment,alpha)$p.value
write.table(alpha,file=paste(name,"_diversity_index.txt",sep=''),sep='\t',quote=F,col=NA)

ncol=length(levels(factor(condition)))
color=factor(condition,labels=rainbow(ncol))
pdf(file=paste(name,"_diversity.pdf",sep=''),12,8)
rarecurve(t(OTU),step=1000,cex=0.8,col=as.character(color),ylab="Observed OTU",xlab="Sequencing depth")
plot_richness(physeq,color="Treatment",measures = c("InvSimpson","Shannon"))
plot_richness(physeq,x="Treatment",color="Treatment",measures = "InvSimpson",title=paste("p-value =",format(pinv,digits=4)))
plot_richness(physeq,x="Treatment",color="Treatment",measures = "Shannon",title=paste("p-value =",format(pshannon,digits=4)))
#plot_richness(physeq,x=nsamples(physeq),measures = c("InvSimpson","Shannon"))
dev.off()


lefse=OTU
taxa=paste(apply(TAX[,-1],1,paste, collapse="|"),rownames(TAX),sep="|")
rownames(lefse)=taxa
Class=as.character(b[colnames(lefse),]$Treatment)
write.table(rbind(Class,lefse),file=paste(name,"_lefse.txt",sep=''),sep='\t',quote=F,col=F)


Pr = transform_sample_counts(physeq, function(x) x / sum(x) )
gPr=tax_glom(Pr, "Genus")
oPfr = filter_taxa(Pr, function(x) mean(x) > 1e-5, TRUE)
gPfr=filter_taxa(gPr, function(x) mean(x) > 1e-3, TRUE)

pdf(file=paste(name,"_profile.pdf",sep=''),6,12)
plot_bar(gPfr, fill = "Genus")
plot_heatmap(gPfr, taxa.label = "Genus",max.label = 300)
#plot_heatmap(oPfr, taxa.label = "Species")
dev.off()

jDist <- distance(oPfr, method = 'jsd')
jMDS <- ordinate(oPfr, "MDS", distance = jDist)
q <- plot_ordination(oPfr, jMDS, color = "Treatment") + ggtitle("MDS with Jensen-Shannon divergence")+geom_point(size = 5, alpha = 0.5)

pdf(file=paste(name,"_MDS.pdf",sep=''),16,9)
q
q+geom_text(aes(label=row.names(jMDS$vectors)),hjust=0, vjust=0)
dev.off()


#library(DESeq2)
#diagdds = phyloseq_to_deseq2(physeq, ~ Treatment)
#diagdds = DESeq(diagdds, test="LRT", reduced= ~1)
#res = results(diagdds, cooksCutoff = FALSE)
#sigtab = res[which(res$padj < 0.05), ]
#sigtab = cbind(as(sigtab, "data.frame"), as(tax_table(physeq)[rownames(sigtab), ], "matrix"))
#res=cbind(as(res, "data.frame"), as(tax_table(physeq)[rownames(res), ], "matrix"))
#write.table(res,file=paste(name,"_DESeq2.txt",sep=''),sep='\t',quote=F,col=NA)

#scale_fill_discrete <- function(palname = "Set1", ...) {
 #   scale_fill_brewer(palette = palname, ...)
#}

# Phylum order
#x = tapply(sigtab$log2FoldChange, sigtab$Phylum, function(x) max(x))
#x = sort(x, TRUE)
#sigtab$Phylum = factor(as.character(sigtab$Phylum), levels=names(x))
# Genus order
#x = tapply(sigtab$log2FoldChange, sigtab$Genus, function(x) max(x))
#x = sort(x, TRUE)
#sigtab$Genus = factor(as.character(sigtab$Genus), levels=names(x))

#pdf(file=paste(name,"_DESeq2.pdf",sep=''),16,9)
#ggplot(sigtab, aes(x=Genus, y=log2FoldChange, color=Phylum)) + geom_point(size=6) +  theme(axis.text.x = element_text(angle = -90, hjust = 0, vjust=0.5))
#dev.off()
