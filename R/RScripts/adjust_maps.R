# This script takes two raster images, where C is smaller than S.
# C is padded so that each pixel represent the same distance in meters
# and afterwards enlaged to fit S in size.
# The two are then stacked on top of each other and displayed both as
# separate layers and as a single image.


# load libraries
library(raster)
c <- raster("image.png")
plot(c)
readline("Press <Enter> to continue")

#Expand base array (padding), here 1 pixel each side
p <- extend(r, c(1,1))

#Create a new, empty raster with the final dimensions
s <- raster(nrow=2000, ncol=2000)

# Resample old extended picture into new raster with correct dimensions
# ngb is nearest neighbor, need this one rather than bilinear so
# values are not changed..
s <- resample(ext, s, method='ngb')
#result in s
plot(s)


# unload the libraries
detach("package:raster")