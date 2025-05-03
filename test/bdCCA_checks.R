library(rhdf5)
# library(BigDataStatMeth)
library(BDStatMethExamples)


# devtools::reload(pkgload::inst("BigDataStatMeth"))
# devtools::reload(pkgload::inst("BDStatMethExamples"))

# setwd("~/PhD/TREBALLANT/BDStatMethExamples")
setwd("/Users/mailos/PhD/dummy/Analyses/TCGA_CCA/")

hdf5_filename <- "cca_tcga_small_rcpp.hdf5"

bdCCA_hdf5_rcpp( hdf5_filename, "data/X", "data/Y", bcenter = TRUE, bscale = FALSE, overwrite = TRUE )



h5ls(hdf5_filename)




# devtools::reload(pkgload::inst("BigDataStatMeth"))

file <- "/Users/mailos/PhD/dummy/Analyses/TCGA_CCA/cca_tcga_small_rcpp.hdf5"
data_normal <- "/NORMALIZED/data/X"
data <- "/data/X"
means <- "/NORMALIZED/data/mean.X"
sds <- "/NORMALIZED/data/sd.X"


X <-  h5read(file,data)
X.norm <-  h5read(file,data_normal)


X.means <-  h5read(file, means)
X.sds <-  h5read(file, sds)


X[1:5,1:5]
Xnorm <- scale(X,TRUE, TRUE)
Xnorm[1:5,1:5]
X.norm[1:5,1:5]

all.equal(Xnorm, X.norm)

Xnorm[2165:2171,495:500]
X.norm[2165:2171,495:500]
all.equal(Xnorm[2165:2171,495:500],
          X.norm[2165:2171,495:500])


# Correctex
((X[,2] - X.means[2])[1:5])/X.sds[2]
((X[,1] - X.means[1])[1:5])/X.sds[1]

# Malament
((X[2,] - X.means[2])[1:5])/X.sds[2]
((X[1,] - X.means[1])[1:5])/X.sds[1]



scale(X,TRUE, FALSE)[1:5,1:5]




all.equal( round( diag(res), 5), ound( diagonal2, 5) )