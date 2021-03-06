#!/usr/bin/env Rscript
# R code for plotting the peaks table and alignment stats in various
# barplots, including dual ggplot barplots



# ~~~~~ GET SCRIPT ARGS ~~~~~~~ #
args <- commandArgs(TRUE); cat("Script args are:\n"); args

# path to the peaks table file
peaks_table_file <- args[1]

align_stats_file <- args[2]


# get the project Identifier
project_ID <- args[3]
peaks_branch <- project_ID

outdir <- args[4]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 






# ~~~~~ LOAD PEAKS FILE ~~~~~~~ #
# load the peaks file into a dataframe
peaks_table_df<-read.table(peaks_table_file,header = TRUE,sep = "\t",stringsAsFactors = FALSE,check.names = FALSE)

# convert the Sample column entries into rownames
rownames(peaks_table_df) <- peaks_table_df[["Sample"]]

# re order based on rownames
peaks_table_df <- peaks_table_df[order(rownames(peaks_table_df)),]
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 





# ~~~~~ LOAD ALIGN FILE ~~~~~~~ #
align_stats_df <- read.delim(align_stats_file, header = TRUE, sep=",",row.names = 1)
align_stats_df

# re order the rownames
align_stats_df <- align_stats_df[order(rownames(align_stats_df)),]

# save the values to be plotted into a transposed matrix, since thats what the barplot() likes
# # first just get the columns we want
Dup_Raw_Reads_df<-align_stats_df[,which(colnames(align_stats_df) %in% c("De.duplicated.alignments","Duplicated","Unaligned.Reads")) ] 
# reorder the columns because R is dumb
Dup_Raw_Reads_df<-Dup_Raw_Reads_df[c("De.duplicated.alignments","Duplicated","Unaligned.Reads")]

Dup_Raw_Reads_Matrix<-t(as.matrix(Dup_Raw_Reads_df))
# # divid the number of reads by 1million
Dup_Raw_Reads_Matrix<-signif(Dup_Raw_Reads_Matrix/1000000,digits = 4)

# # first just get the columns we want
Dup_Pcnt_Reads_df<-align_stats_df[,which(colnames(align_stats_df) %in% c("Percent.De.dup.Reads","Percent.Dup","Pcnt.Unaligned.Reads")) ]
# reorder
Dup_Pcnt_Reads_df<-Dup_Pcnt_Reads_df[c("Percent.De.dup.Reads","Percent.Dup","Pcnt.Unaligned.Reads")]
Dup_Pcnt_Reads_Matrix<-t(as.matrix(Dup_Pcnt_Reads_df))
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 




# ~~~~~~~~~~~ PLOT SETUP ~~~~~~~~~~ # 
# make align stats plot
# Set up the plots
BARPLOT_COLORS<-c("blue","purple","red")
# setup the matrix for the plot layout
Raw_Reads_Matrix_matrix<-structure(c(1L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 1L, 2L, 
                                     2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L, 1L, 2L, 2L, 2L, 2L, 2L, 3L, 
                                     3L, 3L, 3L, 3L, 1L, 2L, 2L, 2L, 2L, 2L, 3L, 3L, 3L, 3L, 3L),
                                   .Dim = c(11L,4L), 
                                   .Dimnames = list(NULL, c("V1", "V2", "V3", "V4")))
Raw_Reads_Matrix_matrix <- Raw_Reads_Matrix_matrix[(rowSums(Raw_Reads_Matrix_matrix < 3) > 0), , drop = FALSE]

# calculate some values for the figure margins
# based on the nchar() of the longest rowname, divided by a value
mar_divisor<-2.0 # # smaller number = larger margin ; might have to adjust this manually per-project
mar_widthLeft<-signif(
  max(4.1,
      max(nchar(row.names(align_stats_df)))/mar_divisor),
  4) # 65 is too much # this may not work in RStudio but should work in pdf() or command line R 


# calculate value for the plot label scaling factor
# Names_scale<-min(0.7, 
#                max(nchar(row.names(align_stats_df)))*.0075) # works alright up to 88 char's samplenames # this doesn't work as well, needs more tweaking
# ^ this also causes tiny labels for short names, too small, need both max and min cutoffs??
Names_scale<-0.7
# scaling factor for space between bars
Space_scale<-max(0.2, # default setting
                 nrow(align_stats_df)*.01) # needs to work with up to 61


cat("The longest sample name is ",max(nchar(row.names(align_stats_df))),sep = "\n")
cat("The number of samples is ",nrow(align_stats_df),sep = "\n")


cat("mar_widthLeft is ",mar_widthLeft,"",sep = "\n")
cat("Names_scale is ",Names_scale,"",sep = "\n")
cat("Space_scale is ",Space_scale,sep = "\n")

# write a PDF of the plot
# pdf(file = paste0(OutDir,"/alignment_barplots",mar_divisor,"-",mar_widthLeft,".pdf"),width = 8,height = 8) # ORIGINAL
pdf(file = paste0(outdir,"/alignment_barplots.pdf"),width = 8,height = 8)

# setup the panel layout
layout(Raw_Reads_Matrix_matrix) 
# need to set this for some reason
par(mar=c(0,0,4,0))
# call blank plot to fill the first panel
plot(1,type='n',axes=FALSE,xlab="",ylab="",main = "Sequencing Reads",cex.main=2) 
# set up the Legend in the first panel
legend("bottom",legend=c("Deduplicated","Duplicated","Unaligned"),fill=BARPLOT_COLORS,bty = "n",ncol=length(BARPLOT_COLORS),cex=1.0)
# plot margins # c(bottom, left, top, right) # default is c(5, 4, 4, 2) + 0.1
# par(mar=c(6,max(4.1,max(nchar(row.names(align_stats_df)))/1.5),0,3)+ 0.1) # ORIGINAL 
par(mar=c(6,mar_widthLeft,0,3)+ 0.1) 

# create barplot for the two matrices
# barplot(Dup_Raw_Reads_Matrix,horiz = T,col=BARPLOT_COLORS,border=NA,las=1,cex.names=0.7,xlab="Number of reads (millions)") 
# barplot(Dup_Pcnt_Reads_Matrix,horiz = T,col=BARPLOT_COLORS,border=NA,las=1,cex.names=0.7,xlab="Percent of reads")
barplot(Dup_Raw_Reads_Matrix,horiz = T,col=BARPLOT_COLORS,border=NA,las=1,cex.names=Names_scale,xlab="Number of reads (millions)",space=Space_scale) 

dev.off()
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 





# ~~~~~ START PEAKS PLOT ~~~~~~~ #
# plot layout setup
plot_layout_matrix<-structure(c(1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 1L, 2L, 2L, 2L, 2L, 
                                2L, 2L, 2L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 1L, 2L, 2L, 2L, 2L, 
                                2L, 2L, 2L), .Dim = c(8L, 4L), .Dimnames = list(NULL, c("V1", 
                                                                                        "V2", "V3", "V4")))
pdf(file = paste0(outdir,"/peaks_barplots.pdf"),width = 8,height = 8)
# setup the panel layout
layout(plot_layout_matrix)
# need to set this for some reason
# plot margins # c(bottom, left, top, right) # default is c(5, 4, 4, 2) + 0.1
par(mar=c(0,0,5,0))
# call blank plot to fill the first panel
plot(1,type='n',axes=FALSE,xlab="",ylab="",main = peaks_branch,cex.main=1.5) 
# set up the Legend in the first panel
# legend("bottom",legend=colnames(overlap_df),bty = "n",cex=1.0) # fill=BARPLOT_COLORS,,ncol=length(BARPLOT_COLORS)
# set some plot margin parameters to fit the names
par(mar=c(5,16,0,2)+ 0.1) 
barplot(t(peaks_table_df),
        # main=peaks_branch,
        cex.names = 0.7,
        horiz = T,
        # col=BARPLOT_COLORS,
        border=NA,
        las=1,
        # cex.names=Names_scale,
        xlab="Number of peaks",
        space=0.6
) 
# p <- recordPlot()
dev.off()
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 







# ~~~~~ START DUAL PLOT ~~~~~~~ #
dual_plot_matrix <- structure(c(1, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 
                                2, 1, 2, 2, 2, 2, 2, 3, 4, 4, 4, 4, 4, 3, 4, 4, 4, 4, 4, 3, 4, 
                                4, 4, 4, 4, 3, 4, 4, 4, 4, 4), .Dim = c(6L, 8L), .Dimnames = list(
                                  NULL, c("V1", "V2", "V3", "V4", "", "", "", "")))
dual_plot_matrix

# start the dual plot
pdf(file = paste0(outdir,"/dual_barplots.pdf"),width = 16,height = 8)
# setup the panel layout
layout(dual_plot_matrix) 

# call blank plot to fill the first panel
plot(1,type='n',axes=FALSE,xlab="",ylab="",main = "Sequencing Reads",cex.main=2) 
# set up the Legend in the first panel
par(mar=c(0,0,5,0))
legend("bottom",legend=c("Deduplicated","Duplicated","Unaligned"),fill=BARPLOT_COLORS,bty = "n",ncol=length(BARPLOT_COLORS),cex=1.0)

# plot margins # c(bottom, left, top, right) # default is c(5, 4, 4, 2) + 0.1
# par(mar=c(6,mar_widthLeft,0,3)+ 0.1) 
# par(mar=c(6,16,0,3)+ 0.1) 
par(mar=c(5,16,0,2)+ 0.1)
# create alignemnt barplot 
barplot(Dup_Raw_Reads_Matrix,horiz = T,
        col=BARPLOT_COLORS,
        border=NA,
        las=1,
        cex.names=Names_scale,
        xlab="Number of reads (millions)"
        #,space=Space_scale
) 


# start peaks plot
par(mar=c(0,0,5,0))
# call blank plot to fill the first panel
plot(1,type='n',axes=FALSE,xlab="",ylab="",main = peaks_branch,cex.main=1.5) 
# set up the Legend in the first panel

par(mar=c(5,16,0,2)+ 0.1) 
barplot(t(peaks_table_df),
        # main=peaks_branch,
        cex.names = 0.7,
        horiz = T,
        # col=BARPLOT_COLORS,
        border=NA,
        las=1,
        # cex.names=Names_scale,
        xlab="Number of peaks"
        #,space=0.6
)
dev.off()
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 





# ~~~~~ MERGE DATA SETS ~~~~~~~ #
# make 'sampleID' columns in both data sets
align_stats_df[["SampleID"]] <- rownames(align_stats_df)
peaks_table_df[["SampleID"]] <- rownames(peaks_table_df)

peaks_align_merge_df <- base::merge(align_stats_df,peaks_table_df,by="SampleID",all=TRUE)

# only keep these columns
peaks_align_merge_df <- peaks_align_merge_df[,c("SampleID","Total.reads","Aligned.reads","De.duplicated.alignments","Duplicated","Unaligned.Reads","Peaks")]

# melt it into long format
library("reshape2")
peaks_align_merge_long_df <- reshape2::melt(peaks_align_merge_df,id.vars="SampleID",variable.name="variable",value.name="value")


write.table(x = peaks_align_merge_long_df,file = paste0(outdir,"/peak_align_stats_long.tsv"),quote = FALSE,sep = '\t',row.names = FALSE,col.names = TRUE)
save.image(file=paste0(outdir,"/pre_plot-peak-stats.Rdata"),compress = TRUE)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 






# ~~~~~ MAKE MERGED PLOTS ~~~~~~~ #
library("grid")
library("ggplot2")
library("plyr")
library("gridExtra")
library("scales")

theme_set(theme_bw())
# set up the sample ID's along the center
g.mid<-ggplot(peaks_align_merge_long_df,aes(x=1,y=SampleID))+geom_text(aes(label=SampleID),size = 2)+
  # geom_segment(aes(x=0.94,xend=0.95,yend=SampleID))+ # geom_segment(aes(x=0.94,xend=0.96,yend=SampleID))+
  # geom_segment(aes(x=1.04,xend=1.05,yend=SampleID))+
  ggtitle("Samples")+
  ylab(NULL)+
  scale_x_continuous(expand=c(0,0),limits=c(0.94,1.065))+
  theme(axis.title=element_blank(),
        # panel.grid=element_line(size = 10),
        panel.grid.major.x=element_blank(),
        panel.grid.minor.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background=element_blank(),
        axis.text.x=element_text(color=NA),
        axis.ticks.x=element_line(color=NA),
        plot.margin = unit(c(1,-1,1,-1), "mm"))

# subset for just the peaks values, order by rownames e.g. Sample IDs
peaks_align_merge_peaksonly <- droplevels(subset(peaks_align_merge_long_df, variable=="Peaks"))
# make sure they are ordered by sample ID
# peaks_table_df <- peaks_table_df[order(rownames(peaks_table_df)),]
peaks_align_merge_peaksonly <- peaks_align_merge_peaksonly[order(peaks_align_merge_peaksonly[["SampleID"]]),]

# with(peaks_align_merge_peaksonly,order(-SampleID,value,))

# make barplot for just the peaks
g1 <- ggplot(data = peaks_align_merge_peaksonly, aes(x = SampleID, y = value)) +
  geom_bar(stat = "identity") + ggtitle(paste0(peaks_branch))+
  theme(axis.title.x = element_blank(), 
        axis.title.y = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(), 
        plot.margin = unit(c(1,-1,1,0), "mm")) +
  scale_y_reverse() + coord_flip()

# subset for just the align stats reads values to plot:
# c("Deduplicated","Duplicated","Unaligned")
peaks_align_merge_readsonly <- peaks_align_merge_long_df[peaks_align_merge_long_df[["variable"]] %in% c("De.duplicated.alignments","Duplicated","Unaligned.Reads"),]

# calculate max peaks for axis
max_peaks <- max(peaks_align_merge_long_df[with(peaks_align_merge_long_df, which(variable=="Total.reads")),][["value"]],na.rm = TRUE)


# make barplot for just the align stats
g2 <- ggplot(data = peaks_align_merge_readsonly, aes(x = SampleID, y = value/1000000, fill=variable)) +xlab(NULL)+
  geom_bar(stat = "identity") +  ggtitle("Millions of Reads per Sample") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank(), 
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        plot.margin = unit(c(1,0,1,-1), "mm")
  ) + coord_flip() + scale_fill_manual(values=c("blue", "purple", "red")) + labs(fill="Reads: ") + scale_y_continuous(labels = comma,breaks = seq(from=0,to = (max_peaks/1000000)+10,by = 10))
# , legend.box = "horizontal", legend.position = "top") + labs(fill="Reads: ") + coord_flip()

# put it all together
gg1 <- ggplot_gtable(ggplot_build(g1))
gg2 <- ggplot_gtable(ggplot_build(g2))
gg.mid <- ggplot_gtable(ggplot_build(g.mid))


# out_file_path <- "/ifs/home/kellys04/projects/PanosLab-Carlos-ChIPSeq_2016-06-06/analysis_dir/project_notes/peaks-per-sample_report_3/output/peaks.by_group.macs_broad/gg_peaks_alignemtn_barplots.pdf"
pdf(file = paste0(outdir,"/dual_ggbarplots.pdf"),width = 10,height = 8.5)
grid.arrange(gg1,gg.mid,gg2,ncol=3,widths=c(0.3,0.2,0.5)) # widths=c(0.4,0.2,0.4)
dev.off()
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ # 






# ~~~~~ SAVE PEAK ALIGN STATS ~~~~~~~ #
# save the table to a TSV table, to print in the report
peaks_align_merge_df_save <- peaks_align_merge_df[,c("SampleID","Peaks","De.duplicated.alignments")]
write.table(x = peaks_align_merge_df_save,file = paste0(outdir,"/peak_align_stats.tsv"),quote = FALSE,sep = '\t',row.names = FALSE,col.names = TRUE)

# save R session
save.image(file=paste0(outdir,"/peak-stats.Rdata"),compress = TRUE)
