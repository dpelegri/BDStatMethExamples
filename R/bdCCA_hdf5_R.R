#' Canonical Correlation Analysis
#' 
#' This function is an application of the BigDataStatMeth functions to generate new methods. This function perform a Canonical Correlation Analysis
#' from two matrices stored in hdf5 data file. This function applies matrix partitioning, merge bloks to create a full matrix, apply a function to different blocks, etc.
#' 
#' @export
#' 
#' @param filename string file name where dataset to normalize is stored.
#' @param X Dataset, path inside the hdf5 data file.
#' @param Y Dataset, path inside the hdf5 data file.
#' @param m Integer, number of blocks in which we want to partition the matrix to perform the calculations.
#' @param bcenter, Boolean, if true, dataset is centered to perform calculus.
#' @param bscale, Boolean, if true, dataset is centered to perform calculus.
#' @param bycols, Boolean by default = true, true indicates that the imputation will be done by columns, otherwise, the imputation will be done by rows.
#' @param overwriteResults, Boolean, if true, datasets existing inside a file must be overwritten if we are using the same names.
#' @param keepInteResults, Boolean, if false, intermediate results will be removed.
#' @return hdf5 data file with CCA results, 
#' @examples
#'    print ("Example in vignette")
#' 

bdCCA_hdf5 <- function(filename, X, Y, m = 10,
                       bcenter = TRUE, bscale = FALSE, bycols = FALSE,
                       overwriteResults = FALSE, keepInteResults = FALSE)
{
    
    matrices <- c(X, Y)
    sapply( matrices,
            getQRbyBlocks,
            file = filename,
            m = m,
            center = bcenter,
            scale = bscale,
            bcols = bycols,
            overwrt = overwriteResults )
    
    # Step 7
    #   tQXQY <- crossprod(t(QX), QY)[1:ncol(x), ]
    res <- bdCrossprod_hdf5(filename = filename,
                            group = "Step6", A = "XQ",
                            groupB = "Step6", B = "YQ",
                            outdataset = "CrossProd_XQ_YQ",
                            outgroup = "Step7", overwrite = TRUE)
    # Step 8 :
    # z <- svd( tQXQY )
    res <- bdSVD_hdf5(file = filename,
                      group = "Step7", dataset = "CrossProd_XQ_YQ",
                      bcenter = FALSE, bscale = FALSE, k = 16, q = 2, 
                      threads = 3, overwrite = TRUE)
    res <- sapply( matrices, bdgetDim_hdf5, filename = filename )


    writeCCAComponents_hdf5( filename, res[2,X], res[2,Y])

    if( keepInteResults == FALSE){
        sapply(paste0 ("Step",1:7), function (x) {
            invisible(bdRemove_hdf5_element( filename, element = x))
            print(paste0 (x, "Removed"))
        })
    }
    
}