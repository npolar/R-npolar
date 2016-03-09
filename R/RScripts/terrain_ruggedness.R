#!/usr/bin/env Rscript
# This program estimates the terrain ruggedness according to vector ruggedness by measuring
# the dispersion of vectors orthogonal to the terrain surface.
# Method is based on a method developed for measuring surface roughnes in
# geomorphology, see J. Mark Sappington, Kathleen M. Longshore, Daniel B. Thompson.
# "Quantifying landscape ruggedness for animal habitat analysis: A case study using bighorn sheep
# in the Mojave desert" Journal of wildlife management 71(5):1419-1426, 2007.
# Note: input - if your inputfile has several layers, take care whan naming the sgrd file so you get
# the right name..
#
# Prerequisite: If your raster has seveal layers, you need to convert those into one or pick
# one layer..if picking one, note that the filename of sgrd might be different. This program
# only convert a filename <filname.ext> to <filename.sgrd>, ex. file.jpg to file.sgrd.
# Alternatively define your own inputfilesgrd, and turn the gsub command into a comment..
#
# Run: inputfile <- "<filename of your terrain model>"
#      source("terrain_ruggedness")
#
# Author: srldl
#
#####################################################

#http://www.r-bloggers.com/rsaga-getting-started/
#Download RSAGA.

# Download SAGA 2.1.2. (NOT the newest versionas of 2016-03-02) from
# https://sourceforge.net/projects/saga-gis/files/SAGA%20-%202.1/
# Unpack – change catalogue name to SAGA-GIS. Move the directory to
# <your lib dir under R library\RSAGA\>

#install.packages("RSAGA","<your lib dir under r library>")
library("raster")
library("RSAGA")


#import raster image and convert to .sgrd
#RSAGA will accept only grid formats for processing..(aka .sgrd)
rsaga.import.gdal(inputfile)

#Now you should have new files generated on your disk –
# fil.mgrd, fil.sdat, fil.sgrd for each layer

#Convert inputfilename to the same filename with .sgrd extension
inputfilesgrd <-  gsub("[.][a-z]{3}", ".sgrd", inputfile)

#Get slope and aspect (see formula)
rsaga.slope.asp.curv(inputfilesgrd, "slope", "aspect", "curvature",method = "maxslope")

#Calculate xy and z rasters
rsaga.grid.calculus("slope.sgrd","z.sgrd", "cos(a)")
rsaga.grid.calculus("slope.sgrd","xy.sgrd", "sin(a)")

#Calculate aspect part of x,y from aspect
rsaga.grid.calculus("aspect.sgrd","x2.sgrd", "sin(a)")
rsaga.grid.calculus("aspect.sgrd","y2.sgrd", "cos(a)")

#Calculate x,y
rsaga.grid.calculus(c("xy.sgrd","y2.sgrd"),"y.sgrd", "a*b")
rsaga.grid.calculus(c("xy.sgrd","x2.sgrd"),"x.sgrd", "a*b")

#Must convert to asci grid first to make focal work
rsaga.sgrd.to.esri("x.sgrd","x_esri.asc", format = "ascii")
rsaga.sgrd.to.esri("y.sgrd","y_esri.asc", format = "ascii")
rsaga.sgrd.to.esri("z.sgrd","z_esri.asc", format = "ascii")


#Get 3x3 grid sums from x.sgrd,y.sgrd,z.sgrd
#Must check – does this function gives what we want? Is radius 1?
gapply("x_esri.asc", "x9esri.asc", fun="sum", radius=1, search.mode="square")
gapply("y_esri.asc", "y9esri.asc", fun="sum", radius=1, search.mode="square")
gapply("z_esri.asc", "z9esri.asc", fun="sum", radius=1, search.mode="square")

#Alternative to gapply..
#focal.function("x.sgrd", "x9esri.asc", fun="sum")
#focal.function("y.sgrd", "y9esri.asc", fun="sum")
#focal.function("z.sgrd", "z9esri.asc", fun="sum")

#Must now convert back from .ascii grid to .sgrd grid files again..
rsaga.esri.to.sgrd("x9esri.asc","x9.sgrd")
rsaga.esri.to.sgrd("y9esri.asc","y9.sgrd")
rsaga.esri.to.sgrd("z9esri.asc","z9.sgrd")

#Grid sums a*a
rsaga.grid.calculus("x9.sgrd","resx9.sgrd", "a*a")
rsaga.grid.calculus("y9.sgrd","resy9.sgrd", "a*a")
rsaga.grid.calculus("z9.sgrd","resz9.sgrd", "a*a")

#sum all three
rsaga.grid.calculus(c("resx9.sgrd","resy9.sgrd","resz9.sgrd"),"res_sum.sgrd", "a+b+c")

#Square root of all three = |r|
rsaga.grid.calculus("res_sum.sgrd","r.sgrd", "sqrt(a)")

#Finally 1 –(|r|/n)
rsaga.grid.calculus("r.sgrd","out.sgrd", "1-(a/9)")