#ifndef BDSTATMETHEXAMPLES_CCA_HPP
#define BDSTATMETHEXAMPLES_CCA_HPP

#include <Rcpp.h>
#include "BigDataStatMeth.hpp"


using namespace Rcpp;
using namespace BigDataStatMeth;


// Functions
void getQRbyBlocks_rcpp(hdf5Dataset *dsA, int mblocks, bool bcenter, bool bscale, 
                bool byrows, bool overwrite, Nullable<int> threads = R_NilValue );
                        
void writeCCAComponents_hdf5_rcpp (hdf5Dataset* dsX, hdf5Dataset* dsY);
                        
    

    
    
    void getQRbyBlocks_rcpp( hdf5Dataset *dsA, int mblocks, bool bcenter, bool bscale, 
                             bool byrows, bool overwrite, Rcpp::Nullable<int> threads )
    {
        
        hdf5Dataset* dstmp = nullptr;
        
        try {
            
            std::string strInPath, strOutPath;
            
            bool btransp_dataset = false,
                btransp_bdataset = false,
                bfullMatrix = false;
            
            bool bycols = !byrows;
            
            std::string strdataset = dsA->getDatasetName();
            RcppNormalizeHdf5( dsA, bcenter, bscale, byrows);
            
            dstmp = new hdf5Dataset(dsA->getFileName(), "NORMALIZED/" + dsA->getGroupName(), strdataset, false);
            dstmp->openDataset();
            
            strOutPath = "Step1/" + strdataset + "rows";
            RcppSplit_matrix_hdf5_internal ( dstmp, strOutPath, strdataset, bycols,
                                             mblocks, -1, dstmp->nrows(), dstmp->ncols() );
            delete dstmp; dstmp = nullptr;    
            
            
            StringVector blocks = dsA->getDatasetNames(strOutPath, "", "");
            strInPath = strOutPath;
            strOutPath = "Step2/" + strdataset + "rows";
            RcppApplyFunctionHdf5( dsA->getFileName(), strInPath, blocks, strOutPath, "QR",
                                   R_NilValue, R_NilValue, wrap(overwrite), wrap(btransp_dataset),
                                   wrap(btransp_bdataset), wrap(bfullMatrix),wrap(byrows), threads);
            
            
            StringVector blocks_qr = dsA->getDatasetNames(strOutPath, strdataset, ".R");
            strInPath = strOutPath;
            strOutPath = "Step3/merged";
            RcppBind_datasets_hdf5( dsA->getFileName(), strInPath, blocks_qr,
                                    strOutPath, strdataset + "Rt", "bindRows", false, wrap(overwrite) );
            
            strInPath = strOutPath;
            strOutPath = "Step3/Final_QR";
            RcppApplyFunctionHdf5( dsA->getFileName(), strInPath, strdataset + "Rt", strOutPath, "QR",
                                   R_NilValue, R_NilValue, wrap(overwrite), wrap(btransp_dataset),
                                   wrap(btransp_bdataset), wrap(bfullMatrix),wrap(byrows), threads);
            
            strInPath = strOutPath;
            strOutPath = "Step4/splitted";
            dstmp = new hdf5Dataset(dsA->getFileName(), strInPath, strdataset + "Rt.Q", false);
            dstmp->openDataset();
            
            RcppSplit_matrix_hdf5_internal ( dstmp, strOutPath, strdataset + "Rt.Q", bycols,
                                             mblocks, -1, dstmp->nrows(), dstmp->ncols() );
            delete dstmp; dstmp = nullptr; 
            
            
            strInPath = "Step2/" + strdataset + "rows";
            strOutPath = "Step5";
            CharacterVector b_group = "Step4/splitted";
            
            blocks_qr = dsA->getDatasetNames(strInPath, strdataset, ".Q");
            StringVector b_blocks = dsA->getDatasetNames( "Step4/splitted", strdataset + "Rt.Q", "");
            
            RcppApplyFunctionHdf5( dsA->getFileName(), strInPath, blocks_qr, strOutPath, "blockmult",
                                   b_group, b_blocks, wrap(overwrite), wrap(btransp_dataset),
                                   wrap(btransp_bdataset), wrap(bfullMatrix),wrap(byrows), threads);
            
            strInPath = strOutPath; 
            strOutPath = "Step6";
            blocks = dsA->getDatasetNames( strInPath, strdataset + ".", "");
            RcppBind_datasets_hdf5( dsA->getFileName(), strInPath, blocks,
                                    strOutPath, strdataset + "Q", "bindRows", false, wrap(overwrite) );
            
            
        } catch(std::exception& ex) {
            checkClose_file(dsA, dstmp);
            Rcout<< "c++ exception getQRbyBlocks_rcpp: "<< ex.what() << "\n";
            return void();
        }
        
        return void();
        
    }
    
    
    
    
    
    void writeCCAComponents_hdf5_rcpp (hdf5Dataset* dsX, hdf5Dataset* dsY) 
    {
        
        try {
            
            
            
            
        } catch(std::exception& ex) {
            checkClose_file(dsX, dsY);
            Rcout<< "c++ exception writeCCAComponents_hdf5_rcpp: "<< ex.what() << "\n";
            return void();
        }
        
        
        return void();
        
    }
    
    
    
    
    
    
    
    // writeCCAComponents_hdf5 <- function(filename, ncolsX, ncolsY)
    // {
    //     if(!file.exists(filename)){
    //         message("ERROR - File does not exists")
    //         return()
    //     }
    //
    // # Read data from file
    //     h5f = H5Fopen(filename)
    //         XQ <- h5f$Step6$XQ[1:ncolsX, 1:ncolsX]
    //     YQ <- h5f$Step6$YQ[1:ncolsY, 1:ncolsY]
    //     XR <- h5f$Step3$Final_QR$XRt.R
    //     YR <- h5f$Step3$Final_QR$YRt.R
    //     d <- h5f$SVD$CrossProd_XQ_x_YQ$d
    //     u <- h5f$SVD$CrossProd_XQ_x_YQ$u
    //     v <- h5f$SVD$CrossProd_XQ_x_YQ$v
    //     xcenter <- h5f$NORMALIZED$data$mean.X
    //     ycenter <- h5f$NORMALIZED$data$mean.Y
    //     x.names <- h5f$data$.X_dimnames$`2`
    //     y.names <- h5f$data$.Y_dimnames$`2`
    //     h5closeAll()
    //
    // # Get qr compact (more or less)
    //         XR[lower.tri(XR, diag = F)] <- 0
    //         XQ[upper.tri(XQ, diag = T)] <- 0
    //         XQR <- XR + XQ
    //
    //         YR[lower.tri(YR, diag = F)] <- 0
    //         YQ[upper.tri(YQ, diag = T)] <- 0
    //         YQR <- YR + YQ
    //
    //         xcoef <- bdSolve(XQR, u)
    //             ycoef <- bdSolve(YQR, v)
    //
    //             rownames(xcoef) <- as.matrix(x.names)
    //             rownames(ycoef) <- as.matrix(y.names)
    //
    // # Store results to HDF5 data file under Results group/folder
    // #     cor, xcoef, ycoef, xcenter, ycenter, xscores, yscores
    // #     corr.X.xscores, corr.Y.xscores, corr.X.yscores, corr.Y.yscores
    //             bdCreate_hdf5_matrix(filename, object = xcoef,
    //                                  group = "Results",  dataset = "xcoef", overwriteDataset = TRUE)
    //                 bdCreate_hdf5_matrix(filename = filename, object = ycoef,
    //                                      group = "Results",  dataset = "ycoef", overwriteDataset = TRUE)
    //
    //                 bdCreate_hdf5_matrix(filename , object = as.matrix(diag(d)),
    //                                      group = "Results", dataset = "cor", overwriteDataset = TRUE)
    //
    //                 bdCreate_hdf5_matrix(filename, object = xcenter,
    //                                      group = "Results", dataset = "xcenter", overwriteDataset = TRUE)
    //                 bdCreate_hdf5_matrix(filename, object = ycenter,
    //                                      group = "Results", dataset = "ycenter", overwriteDataset = TRUE)
    //
    // # devtools::reload(pkgload::inst("BigDataStatMeth"))
    //                 bdblockmult_hdf5( filename = filename, group = "data", A = "X", B = "xcoef",
    //                                   groupB = "Results", outgroup = "Results",
    //                                   outdataset = "xscores", overwrite = TRUE)
    //                     bdblockmult_hdf5(filename, group = "data", A = "Y", B = "ycoef",
    //                                      groupB = "Results", outgroup = "Results",
    //                                      outdataset = "yscores")
    //
    // }
    
    
    

                        
#endif // BDSTATMETHEXAMPLES_CCA_HPP