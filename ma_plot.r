
count_quads <- function(T){
    q1 = 0
    q2 = 0
    q3 = 0
    q4 = 0
    for(i in 1:length(T[,1])){
        x = T[i,1] 
        y = T[i,2]
        if(x > 0 && y > 0){
            q1 = q1 + 1 
        }else if(x < 0 && y > 0){
            q2 = q2 + 1
        }else if(x < 0 && y < 0){
            q3 = q3 + 1
        }else if(x > 0 && y < 0){
            q4 = q4 + 1
        }else{
            print("ERROR")
            return(c(-1,-1,-1,-1))
        }
    }   
    return(c(q1,q2,q3,q4))
}

A = read.table("WI-WIOB.minus-KC-WI.minus.combined")
P = read.table("WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos")
N = read.table("WI-WIOB.minus-KC-WI.minus.combined.manhattan.neg")
plot(A,xlab="Expression Increased in Vicious Biters                       Expression Increased in Weak Biters",cex.lab=0.7,ylab="Expression Decreased in Non-Biters                       Expression Increased in Non-Biters",main="WI-WIOB vs KC-WI Minus Value Comparison",col="dark blue")
points(N,pch=16,col="red")
points(P,pch=16,col="green")
abline(a=0,b=0)
abline(v=0)
grid()
q_counts = count_quads(A)
legend("topright",legend=q_counts[1])
legend("topleft",legend=q_counts[2])
legend("bottomleft",legend=q_counts[3])
legend("bottomright",legend=q_counts[4])
