#Usage: Rscript plot_expr_coords.r <least interesting / significant data> ... <most interesting / significant data>

#Example: Rscript plot_expr_coords.r WI-WIOB.minus-KC-WI.minus.combined WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos WI-WIOB.minus-KC-WI.minus.combined.manhattan.neg

require(graphics)

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

add_points <- function(P){
    rng = length(P)
    col_vector = rev(heat.colors(rng,alpha=1))
    for(i in 1:length(P)){
        addnl_points = read.table(P[i])
        col_val = col_vector[i]
        points(addnl_points,col=col_val,pch=16)
    }
    legend("right",c(P),col=col_vector,pch=16,bg="white")
}

args <- commandArgs(trailingOnly=TRUE)
print(paste("Accepting coordinate file: ",args))

initial_points = read.table(args[1])
plot(initial_points,xlab="Expression Increased in Vicious Biters                       Expression Increased in Weak Biters",cex.lab=0.7,ylab="Expression Decreased in Non-Biters                       Expression Increased in Non-Biters",main="WI-WIOB vs KC-WI Sequence Expression",col="black")

abline(a=0,b=0)
abline(v=0)
grid()

if(length(args) > 1){
    add_points(tail(args,-1))
}



q_counts = count_quads(initial_points)

legend("topright",legend=q_counts[1])
legend("topleft",legend=q_counts[2])
legend("bottomleft",legend=q_counts[3])
legend("bottomright",legend=q_counts[4])
