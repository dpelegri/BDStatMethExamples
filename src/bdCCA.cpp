// #include<Rcpp.h>
// #include "BigDataStatMeth.hpp"
#include "bdCCA.h"


// using namespace Rcpp;
// using namespace BigDataStatMeth;



//' CCA in hdf5 data files
//'
//' Compute Canonical Correlation Analyses (CCA) in data stored in hdf5 data files, 
//' this function is a dummy versions using only c++ functions from common c++ API's 
//' and BigDataStatMeth library
//' 
//' @param filename, Character array, indicating the name of the file with data to 
//' perform computations
//' @param datasetX, Character array, indicating the input datasets to be used 
//' as X matrix
//' @param datasetY, Character array, indicating the input datasets to be used 
//' as Y vector
//' @param bcenter logical. If TRUE (default), the data is centered by 
//' subtracting the column means (ignoring NAs) of `x` from their corresponding 
//' columns. If FALSE, no centering is performed.
//' @param bscale. If TRUE, the data is scaled by dividing the (centered) 
//' columns of `x` by their standard deviations if `bcenter` is TRUE, or by the 
//' root mean square otherwise. If FALSE, no scaling is performed.
//' @param mblocks number of equally sized blocks into which each input matrix 
//' is partitioned for sequential processing.
//' @param byrows logical if TRUE, centering is done by subtracting the rows 
//' means, util when working with hdf5 datasets stored 
//' in Row Major format.
//' @param overwrite, boolean if true, previous results in same location inside 
//' hdf5 will be overwritten.
//' @param threads optional parameter. Integer with numbers of threads to be used
//' @export
// [[Rcpp::export]]
void bdCCA_hdf5_rcpp(std::string filename, std::string datasetX,
             std::string datasetY, bool bcenter, bool bscale, int mblocks,
             bool overwrite, Rcpp::Nullable<int> threads = R_NilValue ) 
{

    hdf5Dataset* dsX = nullptr;
    hdf5Dataset* dsY = nullptr;
    hdf5Dataset* dsXQ = nullptr;
    hdf5Dataset* dsYQ = nullptr;
    hdf5Dataset* dsC = nullptr;

    try{
        
        // int mblocks = 4;
        int ncolsX, ncolsY;

        dsX = new hdf5Dataset(filename, datasetX, false); dsX->openDataset(); 
        getQRbyBlocks_rcpp(dsX, mblocks, bcenter, bscale, false, overwrite, threads );
        
        dsY = new hdf5Dataset(filename, datasetY, false); dsY->openDataset(); 
        getQRbyBlocks_rcpp(dsY, mblocks, bcenter, bscale, false, overwrite, threads );

                
        dsXQ = new hdf5Dataset(filename, "Step6", "XQ", false); dsXQ->openDataset(); 
        dsYQ = new hdf5Dataset(filename, "Step6", "YQ", false); dsYQ->openDataset(); 
        dsC = new hdf5Dataset(filename, "Step7", "CrossProd_XQ_YQ", overwrite);
        
        int optimBlock = getMaxBlockSize( dsXQ->nrows(), dsXQ->ncols(), dsYQ->nrows(), dsYQ->ncols(), 2, R_NilValue);
        dsC = BigDataStatMeth::crossprod(dsXQ, dsYQ, dsC, optimBlock, optimBlock/2, true, true, threads);
        
        delete dsXQ; dsXQ = nullptr;
        delete dsYQ; dsYQ = nullptr;
        
        ncolsX = dsX->ncols_r();
        ncolsY = dsY->ncols_r();
        
        RcppbdSVD_hdf5( dsC->getFileName(), dsC->getGroupName(), dsC->getDatasetName(),  
                        16, 2, 0, false, false, 0, overwrite, false, R_NilValue, R_NilValue);
        
        delete dsC; dsC = nullptr;
        delete dsX; dsX = nullptr;
        delete dsY; dsY = nullptr;
        
        writeCCAComponents_hdf5_rcpp ( filename, ncolsX, ncolsY);
        
        //     res <- sapply( matrices, bdgetDim_hdf5, filename = filename )


    } catch(std::exception& ex) {
        checkClose_file(dsX, dsY, dsXQ, dsYQ, dsC);
        Rcerr<< "\n c++ exception bdCCA_hdf5_rcpp: "<< ex.what() << "\n";
        return void();
    }

    return void();

}

// bdCCA_hdf5 <- function(filename, X, Y, m = 10,
//                        bcenter = TRUE, bscale = FALSE, bycols = FALSE,
//                        overwriteResults = FALSE, keepInteResults = FALSE)
// {
//
//     matrices <- c(X, Y)
//     sapply( matrices,
//             getQRbyBlocks,
//             file = filename,
//             mblocks = m,
//             center = bcenter,
//             scale = bscale,
//             bcols = bycols,
//             overwrt = overwriteResults )
//
//     Step 7
//     res <- bdCrossprod_hdf5(filename = filename,
//                             group = "Step6", A = "XQ",
//                             groupB = "Step6", B = "YQ",
//                             outgroup = "Step7")
//     Step 8 :
//     res <- bdSVD_hdf5(file = filename,
//                       group = "Step7", dataset = "CrossProd_XQ_x_YQ",
//                       bcenter = FALSE, bscale = FALSE, k = 16, q = 2, threads = 3)
//     res <- sapply( matrices, bdgetDim_hdf5, filename = filename )
//
//     writeCCAComponents_hdf5( filename, res[2,X], res[2,Y])
//
//     if( keepInteResults == FALSE){
//         sapply(paste0 ("Step",1:7), function (x) {
//             invisible(bdRemove_hdf5_element( filename, element = x))
//             print(paste0 (x, "Removed"))
//         })
//     }
//
// }


