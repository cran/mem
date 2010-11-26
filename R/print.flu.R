print.flu <-
function(x, ...){
  threshold<-as.data.frame(round(t(x$pre.post.intervals[1:2,3]),2))
  colnames(threshold)<-c("Pre","Post")
  rownames(threshold)<-"Threshold"
cat("Call:\n")
print(x$call)
 cat("\nThreshold:\n")
print(threshold)
}

