A = read.table("WI-WIOB.minus-KC-WI.minus.combined")
P = read.table("WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos")
N = read.table("WI-WIOB.minus-KC-WI.minus.combined.manhattan.neg")
plot(A,xlab="Expression Increased in Vicious Biters                       Expression Increased in Weak Biters",cex.lab=0.7,ylab="Expression Decreased in Non-Biters                       Expression Increased in Non-Biters",main="WI-WIOB vs KC-WI Minus Value Comparison",col="dark blue")
points(N,pch=16,col="red")
points(P,pch=16,col="green")
abline(a=0,b=0)
abline(v=0)
grid()
legend("topright",legend=1197)
legend("topleft",legend=235)
legend("bottomleft",legend=2191)
legend("bottomright",legend=1137)
