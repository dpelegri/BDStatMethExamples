
#' Title
#'
#' @param filename string File name that contains the results
#' @param ncolsX integer Columns of X
#' @param ncolsY integer Columns of Y
#'
#' @return Writes CCA components in hdf5 data file
#' @export
#'
#' @examples
#'     hdf5_filename <- "cca_tcga_small_rcpp.hdf5"
#'     ncolsX = 500
#'     ncols_Y = 200
#'     writeCCAComponents_hdf5("hdf5_filename", ncolsX, ncols_Y)
writeCCAComponents_hdf5 <- function(filename, ncolsX, ncolsY)
{
    if(!file.exists(filename)){
        message("ERROR - File does not exists")
        return()
    }
    
    # Read data from file
    h5f = H5Fopen(filename)
        XQ <- h5f$Step6$XQ[1:ncolsX, 1:ncolsX]
        YQ <- h5f$Step6$YQ[1:ncolsY, 1:ncolsY]
        XR <- h5f$Step3$Final_QR$XRt.R
        YR <- h5f$Step3$Final_QR$YRt.R
        d <- h5f$SVD$CrossProd_XQ_YQ$d
        u <- h5f$SVD$CrossProd_XQ_YQ$u
        v <- h5f$SVD$CrossProd_XQ_YQ$v
        xcenter <- h5f$NORMALIZED$data$mean.X
        ycenter <- h5f$NORMALIZED$data$mean.Y
        x.names <- h5f$data$.X_dimnames$`2`
        y.names <- h5f$data$.Y_dimnames$`2`
    h5closeAll()
    
    # Get qr compact (more or less)
    XR[lower.tri(XR, diag = F)] <- 0
    XQ[upper.tri(XQ, diag = T)] <- 0
    XQR <- XR + XQ
    
    YR[lower.tri(YR, diag = F)] <- 0
    YQ[upper.tri(YQ, diag = T)] <- 0
    YQR <- YR + YQ
    
    xcoef <- bdSolve(XQR, u)
    ycoef <- bdSolve(YQR, v)
    
    rownames(xcoef) <- as.matrix(x.names)
    rownames(ycoef) <- as.matrix(y.names)

    bdCreate_hdf5_matrix(filename, object = xcoef,
                 group = "Results",  dataset = "xcoef", overwriteDataset = TRUE)
    bdCreate_hdf5_matrix(filename = filename, object = ycoef,
                 group = "Results",  dataset = "ycoef", overwriteDataset = TRUE)
    
    bdCreate_hdf5_matrix(filename , object = as.matrix(diag(d)),
                 group = "Results", dataset = "cor", overwriteDataset = TRUE)
    
    bdCreate_hdf5_matrix(filename, object = xcenter,
                 group = "Results", dataset = "xcenter", overwriteDataset = TRUE)
    bdCreate_hdf5_matrix(filename, object = ycenter,
                 group = "Results", dataset = "ycenter", overwriteDataset = TRUE)
    
    bdblockmult_hdf5( filename = filename, group = "data", A = "X", B = "xcoef",
                      groupB = "Results", outgroup = "Results",
                      outdataset = "xscores", overwrite = TRUE)
    bdblockmult_hdf5(filename, group = "data", A = "Y", B = "ycoef",
                     groupB = "Results", outgroup = "Results",
                     outdataset = "yscores", overwrite = TRUE)
    
    sapply(paste0 ("Step",1:7), function (x) {
        invisible(bdRemove_hdf5_element( filename, element = x))
    })
    
}
