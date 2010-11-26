plot.epidemic <-
function(x, ...){
  opar<-par(mfrow=c(1,1))
  par(mfrow=c(1,1))
  semanas<-length(x$i.data)
  i.epi<-x$optimum.map[4]
  f.epi<-x$optimum.map[5]
matplot(1:semanas,x$i.data,type="l",xlab="Week",ylab="Rate",col="#808080",lty=c(1,1))
if (is.na(i.epi)){
    puntos<-x$i.data
    points(1:semanas,puntos,pch=19,type="p",col="#00C000",cex=1.5)
}else{
    # pre
    puntos<-x$i.data
    puntos[i.epi:semanas]<-NA
    points(1:semanas,puntos,pch=19,type="p",col="#00C000",cex=1.5)
    # epi
    puntos<-x$i.data
    if (i.epi>1) puntos[1:(i.epi-1)]<-NA
    if (f.epi<semanas) puntos[(f.epi+1):semanas]<-NA
    points(1:semanas,puntos,pch=19,type="p",col="#800080",cex=1.5)
    # post
    puntos<-x$i.data
    puntos[1:f.epi]<-NA
    points(1:semanas,puntos,pch=19,type="p",col="#FFB401",cex=1.5)
  }    
      
  legend(semanas*0.70,max.fix.na(x$i.data)*0.99,legend=c("Crude rate","Pre-epi period","Epidemic","Post-epi period"),
    lty=c(1,1,1,1),
    lwd=c(1,1,1,1),
    col=c("#808080","#C0C0C0","#C0C0C0","#C0C0C0"),
    pch=c(NA,21,21,21),
    pt.bg=c(NA,"#00C000","#800080","#FFB401"),
    cex=1)
  par(opar)
}

