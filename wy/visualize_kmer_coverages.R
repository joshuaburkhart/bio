.libPaths("~/tmp/")
library("plotrix")
data = read.table("stats.txt", header=TRUE)
weighted.hist(data$short1_cov,data$lgth,breaks=0:100,col="dark blue",plot=TRUE,freq=TRUE,xlim=c(0,100),ylab="Frequency",xlab="Coverage")
