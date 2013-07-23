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

findMaxs <- function(L){
    max_xs = 0
    max_ys = 0
    for(i in 1:length(L)){
        df = read.table(L[i])
        max_xs = append(max_xs,max(df[1]))
        max_ys = append(max_ys,max(df[2]))
    }
    return(c(max(max_xs),max(max_ys)))
}

findMins <- function(M){
    min_xs = 0
    min_ys = 0
    for(i in 1:length(M)){
        df = read.table(M[i])
        min_xs = append(min_xs,min(df[1]))
        min_ys = append(min_ys,min(df[2]))
    }
    return(c(min(min_xs),min(min_ys)))
}

add_points <- function(P){
    rng = length(P)
    col_vector = rev(heat.colors(rng,alpha=1))
    for(i in 1:length(P)){
        addnl_points = read.table(P[i])
        col_val = col_vector[i]
        points(addnl_points,pch=21,bg=col_val,col="black")
    }
    legend(.5,-.5,c(P),pch=21,pt.bg=col_vector,col="black",bg="white")
}

args <- commandArgs(trailingOnly=TRUE)
print(paste("Accepting coordinate file: ",args))

initial_points = read.table(args[1])
maxs = findMaxs(args)
mins = findMins(args)
plot(initial_points,xlim=c(mins[1],maxs[1]),ylim=c(mins[2],maxs[2]),xlab="Expression Increased in PBSD22                       Expression Increased in PBLD22",cex.lab=0.7,ylab="Expression Increased in KCSD22                       Expression Increased in KCLD22",main="KC Night vs PB Night Sequence Expression",col="black")

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
