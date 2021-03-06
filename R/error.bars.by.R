"error.bars.by" <-
function (x,group,data=NULL,by.var=FALSE,x.cat=TRUE,ylab =NULL,xlab=NULL,main=NULL,ylim= NULL, 
xlim=NULL, eyes=TRUE,alpha=.05,sd=FALSE,labels=NULL, v.labels=NULL, pos=NULL, 
arrow.len=.05,add=FALSE,bars=FALSE,within=FALSE,colors=c("black","blue","red"), 
 lty,lines=TRUE, legend=0,pch,density=-10,...)  # x   data frame with 
    {

    if(!lines) {typ <- "p"} else {typ <- "b"}
    n.color <- length(colors)
    
      #first, see if they are in formula mode   added August 18, 2018
  formula <- FALSE
   if(inherits(x, "formula")) {  ps <- fparse(x)
   formula <- TRUE
   if(is.null(data)) stop("You must specify the data if you are using formula input") 
     x <- data[ps$y]
   group <- data[ps$x]
   
   if(is.null(ylab)) ylab <- colnames(x)
   if(is.null(xlab)) xlab <- colnames(group)
   if(missing(by.var)) by.var=TRUE
   if(missing(lines)) lines <- FALSE
   }
   if(NCOL(group)==1) {n.grp1 <- length(table(group))} else {n.grp1 <- length(table(group[1]))}
   
    nvar <- NCOL(x)
   # if(is.null(nvar)) nvar <- 1  #added May 21, 2016 to handle the case of a single variable
    if(by.var & (nvar > n.color)) {colors <- rainbow(nvar)}
    if(!missing(density)) {col12 <- col2rgb(colors,TRUE)/255
    colors <- rgb(col12[1,],col12[2,],col12[3,],.5)
               n.color <- nvar}
    #density = -10
    
    if(missing(lty)) lty <- 1:8
 
    legend.location <- c("bottomright", "bottom", "bottomleft", "left", "topleft", "top", "topright", "right",  "center","none")
    
    all.stats <- describe(x)
        min.x <- min(all.stats$min,na.rm=TRUE)
   		max.x <- max(all.stats$max,na.rm=TRUE)
    	max.se <- max(all.stats$se,na.rm=TRUE)
    	if(sd) max.se <- max(all.stats$sd,na.rm=TRUE)
    if(is.null(ylim)) {if(is.na(max.x) | is.na(max.se) | is.na(min.x) | is.infinite(max.x)| is.infinite(min.x) | is.infinite(max.se)) {
                        ylim=c(0,1)} else {
     if(sd) { ylim <- c(min.x - max.se,max.x+max.se) } else {
    ylim=c(min.x - 2*max.se,max.x+2*max.se)}} }
    
    
    if(is.null(main)) {if(sd) {main <- paste("Means + Standard Deviations") } else {main <- paste((1-alpha)*100,"% confidence limits",sep="")} }
    
 if (bars) { #draw a bar plot and add error bars -- this is ugly but some people like it
    group.stats <- describeBy(x,group,mat=TRUE)   
           n.var <- dim(all.stats)[1]
           n.group <- length(group.stats[[1]])/n.var
           group.means <- matrix(group.stats$mean,ncol=n.group,byrow=TRUE)
           
            if(missing(pch)) pch <- seq(15,(15+n.group))
          
           if(sd) {group.se <- matrix(group.stats$sd,ncol=n.group,byrow=TRUE)} else { group.se <- matrix(group.stats$se,ncol=n.group,byrow=TRUE)}
           group.n <- matrix(group.stats$n,ncol=n.group,byrow=TRUE)
           if(within) {group.smc <- matrix(unlist(by(x,group,smc)),nrow=n.group,byrow=TRUE)
                       group.sd <- matrix(group.stats$sd,ncol=n.group,byrow=TRUE)
                       if(sd) {group.se <- sqrt(group.se^2 * (1-group.smc))} else { group.se <- sqrt(group.sd^2 *(1-group.smc)/group.n) }}
           
           rownames(group.means) <- rownames(all.stats)
           if(is.null(labels)) {colnames(group.means) <- paste("Group",1:n.group)} else {colnames(group.means) <- labels }
           
           if (is.null(ylab)) ylab <- "Dependent Variable"
          
           if(missing(ylim)) ylim=c(0,max.x+2*max.se)
           if(by.var)  {
           if (is.null(xlab)) xlab <- "Variables"
           mp <- barplot(t(group.means),beside=TRUE,ylab=ylab,xlab=xlab,ylim=ylim,main=main,col=colors,...)
            for(i in 1:n.var) {
             for (j in 1:n.group) {
         	 xcen <- group.means[i,j]
    	 	 xse  <- group.se[i,j]
    	 	if(sd) {ci <- 1} else {ci <- qt(1-alpha/2,group.n[i,j])}
    	 	
       if(is.finite(xse) && xse>0)    arrows(mp[j,i],xcen-ci*xse,mp[j,i],xcen+ci* xse,length=arrow.len, angle = 90, code=3,col = par("fg"), lty = NULL, lwd = par("lwd"), xpd = NULL)
          }} } else {
           if (is.null(xlab)) xlab <- "Grouping Variable"
           mp <- barplot(group.means,beside=TRUE,ylab=ylab,xlab=xlab,ylim=ylim,main=main,col=colors,...)
            for(i in 1:n.var) {
             for (j in 1:n.group) {
         	 xcen <- group.means[i,j]
    	 	 xse  <- group.se[i,j]
    	 	if(sd) {ci <- 1} else {ci <- qt(1-alpha/2,group.n[i,j])}
        if(is.finite(xse) && xse>0)     arrows(mp[i,j],xcen-ci*xse,mp[i,j],xcen+ci* xse,length=arrow.len, angle = 90, code=3,col = par("fg"), lty = NULL, lwd = par("lwd"), xpd = NULL)
          }} }
         
         
          axis(2,...)
          box()
            if(legend >0  ){
       if(!is.null(v.labels)) {lab <- v.labels} else {lab <- paste("V",1:n.var,sep="")} 
       legend(legend.location[legend], lab, col = colors[(1: n.color)],pch=pch[1: n.var],
       text.col = "green4", lty = lty[1:n.var],
       merge = TRUE, bg = 'gray90')}
               
  } else {   #the normal case is to not use bars
    group.stats <- describeBy(x,group)
    n.group <- length(group.stats)   #this is total number of groups but it may  be 2 x 2 or n x m
    n.var <- ncol(x)
     if(is.null(n.var)) n.var <- 1 
    #first set up some defaults to allow the specification of colors, lty, and pch dynamically and with defaults
    if(missing(pch)) pch <- seq(15,(15+n.group))
    if(missing(lty)) lty <- 1:8
     if(within) {group.smc <- by(x,group,smc) }
     z <- dim(x)[2]
     if(is.null(z)) z <- 1 
     
    if (is.null(ylab)) ylab <- "Dependent Variable"
     
     if(!by.var) {
        
      	if (is.null(xlab)) xlab <- "Independent Variable"
    	for (g in 1:n.group) {
   	 	x.stats <- group.stats[[g]]   
   	 	if (within) { x.smc <- group.smc[[g]]  
    	              if(sd) {x.stats.$se <- sqrt(x.stats$sd^2* (1- x.smc))} else { x.stats$se <- sqrt((x.stats$sd^2* (1- x.smc))/x.stats$n)}
    	               }
        if (missing(xlim)) xlim <- c(.5,n.var+.5)
    	if(!add) {plot(x.stats$mean,ylim=ylim,xlim=xlim, xlab=xlab,ylab=ylab,main=main,typ=typ,lty=(lty[((g-1) %% 8 +1)]),axes=FALSE,col = colors[(g-1) %% n.color +1], pch=pch[g],...)
    	axis(1,1:z,colnames(x),...)
    	axis(2,...)
    	box()
    	} else {points(x.stats$mean,typ = typ,lty=lty[((g-1) %% 8 +1)],col = colors[(g-1) %% n.color +1],  pch=pch[g]) 
    	       }
    	if(!is.null(labels)) {lab <- labels} else {lab <- paste("V",1:z,sep="")}
   
     if (length(pos)==0) {locate <- rep(1,z)} else {locate <- pos}
     	if (length(labels)==0) lab <- rep("",z) else lab <-labels
        for (i in 1:z)  
    	{xcen <- x.stats$mean[i]
    	
    	 if(sd) {xse <- x.stats$sd[i] } else {xse  <- x.stats$se[i]}
    	
    	if(sd) {ci <- 1} else { if(x.stats$n[i] >1) {ci <- qt(1-alpha/2,x.stats$n[i]-1)} else {ci <- 0}}  #corrected Sept 11, 2013
    	  if(is.finite(xse) & xse>0)  {
    	  arrows(i,xcen-ci*xse,i,xcen+ci* xse,length=arrow.len, angle = 90, code=3,col = colors[(g-1) %% n.color +1], lty = NULL, lwd = par("lwd"), xpd = NULL)
    	 if (eyes) {catseyes(i,xcen,xse,x.stats$n[i],alpha=alpha,density=density,col=colors[(g-1) %% n.color +1] )}
    	#text(xcen,i,labels=lab[i],pos=pos[i],cex=1,offset=arrow.len+1)     #puts in labels for all points
    	}
    	}
     add <- TRUE
   #  lty <- "dashed"
     }   #end of g loop 
     
       if(legend >0  ){
       if(!is.null(labels)) {lab <- labels} else {lab <- paste("G",1:n.group,sep="")} 
       legend(legend.location[legend], lab, col = colors[(1: n.color)],pch=pch[1: n.group],
       text.col = "green4", lty = lty[1:8],
       merge = TRUE, bg = 'gray90')
   }
    }    else  { # end of not by var loop
    
    #alternatively, do it by variables rather than by groups, or if we have two grouping variables, treat them as two variables
     if (is.null(xlab)) xlab <- "Grouping Variable"
    
    n.vars <- dim(x)[2]
    if(is.null(n.vars)) n.vars <- 1  #if we just have one variable to plot
     var.means <- matrix(NaN,nrow=n.vars,ncol=n.group)
     var.n <- var.se <- matrix(NA,nrow=n.vars,ncol=n.group)
     

 #if there are two or more grouping variables,this strings them out
    for (g in 1:n.group) {
   	 	var.means[,g] <- group.stats[[g]]$mean    #problem with dimensionality -- if some grouping variables are empty
   	 	if(sd) {var.se[,g] <- group.stats[[g]]$sd}  else {var.se[,g] <- group.stats[[g]]$se }
   	 	var.n [,g] <- group.stats[[g]]$n
   	 	}
   	 	
   	 if(x.cat) {x.values <- 1:n.grp1}  else {
   	   x.values <- as.numeric(names(group.stats))  }  
   	 
    for (i in 1:n.vars) {	
 
    	if(!add) {
    	if(missing(xlim)) xlim <- c(.5,n.grp1 + .5)
    	if(is.null(v.labels)) v.labels <- names(unlist(dimnames(group.stats)[1]))
    	 plot(x.values,var.means[1,1:n.grp1],ylim=ylim,xlim = xlim, xlab=xlab,ylab=ylab,main=main,typ = typ,axes=FALSE,lty=lty[1],pch=pch[1],col = colors[(i-1) %% n.color +1],...)
    		if(x.cat) {axis(1,1:n.grp1,v.labels,...) } else {axis(1)}
    		axis(2,...)
    		box() 
    	 if(n.grp1 < n.group) {
    
    	 points(x.values,var.means[i,(n.grp1 +1):n.group],typ = typ,lty=lty[((i-1) %% 8 +1)],col = colors[(i) %% n.color + 1], pch=pch[i],...) #the first grouping variable
    	 }
    		add <- TRUE
    		} else {
    		  points(x.values,var.means[i,1:(n.grp1)],typ = typ,lty=lty[((i-1) %% 8 +1)],col = colors[(i) %% n.color + 1], pch=pch[i],...) 
    		 if(n.grp1 < n.group) { points(x.values,var.means[i,(n.grp1 +1):(n.group)],typ = typ,lty=lty[((i-1) %% 8 +1)],col = colors[(i) %% n.color + 1], pch=pch[i],...) }
    		        # points(x.values,var.means[i,],typ = typ,lty=lty,...)
    		}
    
    	if(!is.null(labels)) {lab <- labels} else {lab <- paste("G",1:z,sep="")}
   
    	if (length(pos)==0) {locate <- rep(1,z)} else {locate <- pos}
     	if (length(labels)==0) lab <- rep("",z) else lab <-labels

       # for (g in 1:n.group)  {
    		xcen <- var.means[i,]
    	 	xse  <- var.se[i,]
    	 	
    	   if(sd) {ci <- rep(1,n.group)} else { ci <- qt(1-alpha/2,var.n-1)} 
    	  # }
    	   for (g in 1:n.grp1) {
    	   x.stats <- group.stats[[g]]  
    	   if(x.cat)  {arrows(g,xcen[g]-ci[g]*xse[g],g,xcen[g]+ci[g]* xse[g],length=arrow.len, angle = 90, code=3, col = colors[(i-1) %% n.color +1], lty = NULL, lwd = par("lwd"), xpd = NULL)
    	 if (eyes) { 
    	        catseyes(g,xcen[g],xse[g],group.stats[[g]]$n[i],alpha=alpha,density=density,col=colors[(i-1) %% n.color +1] )}}  else {
    	     
    	            arrows(x.values[g],xcen[g]-ci[g]*xse[g],x.values[g],xcen+ci[g]* xse[g],length=arrow.len, angle = 90, code=3,col = colors[(i-1) %% n.color +1], lty = NULL, lwd = par("lwd"), xpd = NULL)
    	            if (eyes) {catseyes(x.values[g],xcen[g],xse[g],x.stats$n[g],alpha=alpha,density=density,col=colors[(i-1) %% n.color +1] )}} 
    	  #text(xcen,i,labels=lab[i],pos=pos[i],cex=1,offset=arrow.len+1)     #puts in labels for all points
   		}
   		 if(n.grp1 < n.group) {
   		  for (g in 1: n.grp1) {
    	   if(x.cat)  {arrows(g,xcen[g+n.grp1]-ci[g+n.grp1]*xse[g+n.grp1],g,xcen[g+n.grp1]+ci[g+n.grp1]* xse[g+n.grp1],length=arrow.len, angle = 90, code=3, col = colors[(i) %% n.color +1], lty = NULL, lwd = par("lwd"), xpd = NULL)
    	 if (eyes) { 
    	        catseyes(g,xcen[g+n.grp1],xse[g+n.grp1],group.stats[[g+n.grp1]]$n[i],alpha=alpha,density=density,col=colors[(i) %% n.color +1] )}}
    	        }}  else {
    	     
    	            arrows(x.values[g],xcen[g+n.grp1]-ci[g+n.grp1]*xse[g+n.grp1],x.values[g+n.grp1],xcen+ci[g+n.grp1]* xse[g+n.grp1],length=arrow.len, angle = 90, code=3,col = colors[(i-1) %% n.color +1], lty = NULL, lwd = par("lwd"), xpd = NULL)
    	            if (eyes) {catseyes(x.values[g],xcen[g+n.grp1],xse[g+n.grp1],x.stats$n[g+n.grp1],alpha=alpha,density=density,col=colors[(i-1) %% n.color +1] )}} 
    	
    	
    	  #text(xcen,i,labels=lab[i],pos=pos[i],cex=1,offset=arrow.len+1)     #puts in labels for all points
 
 
     #lty <- "dashed"
     }   #end of i loop 
      if(legend >0  ){
       if(!is.null(labels)) {lab <- labels} else {lab <- paste("V",1:z,sep="")} 
       legend(legend.location[legend], lab, col = colors[(1: n.color)],pch=pch[1: n.vars],
       text.col = "green4", lty = lty[1:8],
       merge = TRUE, bg = 'gray90')
   }
    }  #end of by var is true loop
   
    } # end of if not bars condition
  invisible(group.stats) }
   
   #corrected Feb 2, 2011 to plot alpha/2 rather than alpha 
   #modifed Feb 2, 2011 to not plot lines if they are not desired.
   #modified May 21, 2016 to handle a case of a single vector having no columns
   #modified April 9, 2019 to include v.labels for plots