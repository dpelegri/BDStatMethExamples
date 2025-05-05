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

# 
# 
# 
# # devtools::reload(pkgload::inst("BigDataStatMeth"))
# 
# filename <- "/Users/mailos/PhD/dummy/Analyses/TCGA_CCA/cca_tcga_small_rcpp.hdf5"
# ncolsX <- 500
# ncolsY <- 339
# 
# 
#     
#     # Read data from file
#     h5f = H5Fopen(filename)
#     XQ <- h5f$Step6$XQ[1:ncolsX, 1:ncolsX]
#     YQ <- h5f$Step6$YQ[1:ncolsY, 1:ncolsY]
#     XR <- h5f$Step3$Final_QR$XRt.R
#     YR <- h5f$Step3$Final_QR$YRt.R
#     d <- h5f$SVD$CrossProd_XQ_x_YQ$d
#     u <- h5f$SVD$CrossProd_XQ_x_YQ$u
#     v <- h5f$SVD$CrossProd_XQ_x_YQ$v
#     xcenter <- h5f$NORMALIZED$data$mean.X
#     ycenter <- h5f$NORMALIZED$data$mean.Y
#     x.names <- h5f$data$.X_dimnames$`2`
#     y.names <- h5f$data$.Y_dimnames$`2`
#     h5closeAll()
#     
#     # Get qr compact (more or less)
#     XR[lower.tri(XR, diag = F)] <- 0
#     XQ[upper.tri(XQ, diag = T)] <- 0
#     XQR <- XR + XQ
#     XQR[1:5,1:5]
#     
#     
#    
#     YR[lower.tri(YR, diag = F)] <- 0
#     YQ[upper.tri(YQ, diag = T)] <- 0
#     YQR <- YR + YQ
#     YQR[1:5,1:5]
#     
#     