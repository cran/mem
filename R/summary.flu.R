summary.flu <-
function(object, ...){
  threshold<-as.data.frame(round(t(object$pre.post.intervals[1:2,3]),2))
  colnames(threshold)<-c("Pre","Post")
  rownames(threshold)<-"Threshold"
cat("Call:\n")
print(object$call)
cat("\nParameters:\n")
 cat("\t- Confidence intervals:\n")
 cat("\t\t+ General: ", output.ci(object$param.type, object$param.level),"\n")
  cat("\t\t+ Curve: ", output.ci(object$param.type.curve,object$param.level.curve),"\n")
  cat("\t\t+ Threshold: ", output.ci(object$param.type.threshold, object$param.level.threshold),"\n")
 cat("\t- Threshold calculation:\n")
  cat("\t\t+ Method: ", object$param.method,"\n")
  cat("\t\t+ Parameter: ", object$param.param,"\n")
  cat("\t\t+ Pre-epidemic values: ", if (object$param.n.max==-1) paste("Optimized: ",object$n.max,sep="") else object$n.max,"\n")
  cat("\t\t+ Tails of CI: ", object$param.tails,"\n")
 cat("\t- Bootstrap (if used):\n")
  cat("\t\t+ Technique: ", if (is.na(object$param.type.boot)) "-" else object$param.type.boot,"\n")
  cat("\t\t+ Bootstrap samples: ", if (is.na(object$param.iter.boot)) "-" else object$param.iter.boot,"\n")
cat("\nEpidemic:\n")
 cat("\t- Typical influenza season lasts ",round(object$ci.length[1,2],2)," weeks. CL ",100*object$param.level,"% of\t[",round(object$ci.length[1,1],2),",",round(object$ci.length[1,3],2),"]\n")
 cat("\t- This optimal ",object$mean.length," weeks influenza season includes the",round(object$ci.percent[2],2),"% of the total sum of rates\n\n")
 cat("\nThreshold:\n")
print(threshold)
}

