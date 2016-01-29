# This script takes two raster images, where C is smaller than S.
# C is padded so that each pixel represent the same distance in meters 
# and afterwards enlaged to fit S in size.
# The two are then stacked on top of each other and displayed both as 
# separate layers and as a single image.


# load libraries
library(raster)
c <- raster("vegetasjonskart.png")
plot(c)
readline("Press <Enter> to continue")

#Expand the base array - add minus x to min and +x to max value
ext <- extent(-20,699,-20,729)
expanded = extend(c, ext, value=0)
plot(expanded)

#Enlarge the map twice the size
p = disaggregate(c,2) 
plot(p,main="twice the size")

s=raster(nrow=40, ncol=40)

#Overlay the å legge punktene over på kartet
r <- overlay(s, p, fun=function(x,y){return(x+y)})
a = unstack(r)

#Plot both layers separately
plot(a)

#View both layers as an image -sandwich style
image(a) 


# unload the libraries
detach("package:raster")