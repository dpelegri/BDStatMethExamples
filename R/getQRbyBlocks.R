#' QR by blocks
#' 
#' This function is an application of the BigDataStatMeth functions to generate new methods. This function perform a QR
#' from two matrices stored in hdf5 data file. This function applies matrix partitioning, merge bloks to create a full matrix, apply a function to different blocks...
#' 
#' @param strdataset string, dataset path within the hdf5 data file from which we want to calculate the QR
#' @param file string file name where dataset to normalize is stored
#' @param mblocks number of blocks in which we want to partition the matrix to perform the calculations
#' @param center, boolean, if true, dataset is centered to perform calculus
#' @param bcols boolean if bcols = TRUE matrix it´s splitted by columns if bcols = FALSE, then matrix or dataset is splitted by rows.
#' @param scale, boolean, if true, dataset is centered to perform calculus
#' @param overwrt, boolean, if true, datasets existing inside a file must be overwritten if we are using the same names
#' @return hdf5 data file with CCA results, 
#' @examples
#' 
#'    print ("Example in vignette")
#'    
#' @importFrom data.table %like%
#' 
getQRbyBlocks <- function(strdataset, file, mblocks, center, scale, bcols, overwrt)
{
    
    strgroup <- gsub("/.?$", "", strdataset)
    strdataset <- gsub("^.*/", "", strdataset)
    
    bdNormalize_hdf5(filename = file, group = strgroup, dataset = strdataset,
                     bcenter = center, bscale = scale, overwrite = overwrt)
    
    bdSplit_matrix_hdf5( filename = file,
                         group = paste0("NORMALIZED/",strgroup),
                         dataset = strdataset,
                         outgroup = paste0( "Step1/", strdataset, "rows"),
                         nblocks = m, bycols = bcols,
                         overwrite = overwrt)
    
    blocks <- bdgetDatasetsList_hdf5(file,
                                     paste0( "Step1/", strdataset, "rows"))
    bdapply_Function_hdf5( filename = file,
                           group = paste0( "Step1/", strdataset, "rows"),
                           datasets = blocks,
                           outgroup = paste0( "Step2/", strdataset, "rows"),
                           func = "QR",
                           overwrite = overwrt )
    
    blocks.qr <- bdgetDatasetsList_hdf5(file,
                                        paste0( "Step2/", strdataset, "rows"))
    bdBind_hdf5_datasets(filename = file,
                         group = paste0( "Step2/", strdataset, "rows"),
                         datasets = blocks.qr[which(blocks.qr %like% ".R")],
                         outgroup = "Step3/merged",
                         outdataset = paste0( strdataset, "Rt"),
                         func = "bindRows", overwrite = overwrt )
    bdapply_Function_hdf5( filename = file,
                           group = "Step3/merged",
                           datasets = paste0( strdataset, "Rt"),
                           outgroup = "Step3/Final_QR",
                           func = "QR",
                           overwrite = overwrt )
    
    bdSplit_matrix_hdf5(filename = file,
                        group = "Step3/Final_QR",
                        dataset = paste0( strdataset, "Rt.Q"),
                        outgroup = "Step4/splitted",
                        nblocks = m,
                        bycols = bcols, overwrite = overwrt )
    
    tmp <- bdgetDatasetsList_hdf5(file, "Step4/splitted")
    Rt.Q.divide <- tmp[which(tmp %like% paste0( strdataset, "Rt.Q"))]
    bdapply_Function_hdf5(  filename = file,
                            group = paste0( "Step2/", strdataset, "rows"),
                            datasets = blocks.qr[which(blocks.qr %like% ".Q")],
                            outgroup = "Step5", func = "blockmult",
                            b_group = "Step4/splitted", b_datasets = Rt.Q.divide,
                            overwrite = TRUE )
    
    blocks.Q <- bdgetDatasetsList_hdf5(file, "Step5")
    bdBind_hdf5_datasets(filename = file, group = "Step5",
                         datasets =blocks.Q[which(blocks.Q %like% paste0(strdataset,"."))],
                         outgroup = "Step6", outdataset = paste0(strdataset,"Q"),
                         func = "bindRows", overwrite = overwrt )
    
}