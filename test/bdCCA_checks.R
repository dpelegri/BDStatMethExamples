library(rhdf5)
# library(BigDataStatMeth)
library(BDStatMethExamples)


# devtools::reload(pkgload::inst("BigDataStatMeth"))
# devtools::reload(pkgload::inst("BDStatMethExamples"))

# setwd("~/PhD/TREBALLANT/BDStatMethExamples")
setwd("/Users/mailos/PhD/dummy/Analyses/TCGA_CCA/")



setwd("/Users/mailos/PhD/dummy/Analyses/TCGA_CCA")

filecommon <- paste0("https://raw.githubusercontent.com/isglobal-brge/",
                     "Supplementary-Material/master/Pelegri-Siso_2021/",
                     "application_examples/CCA/data/")

Xfile <- paste0(filecommon, "RNA_data_small.zip")
Yfile <- paste0(filecommon, "Methyl_data_small.zip")

m <- 4



# ====================================
# Rcpp Execution
# ====================================

hdf5_filename_rcpp <- "cca_tcga_small_rcpp.hdf5"


bdImportData_hdf5( inFile = Xfile,
                   destFile = hdf5_filename_rcpp,
                   destGroup = "data", destDataset = "X",
                   header = TRUE, rownames = FALSE,
                   overwrite = TRUE, sep = ",", overwriteFile = TRUE)

bdImportData_hdf5( inFile = Yfile,
                   destFile = hdf5_filename_rcpp,
                   destGroup = "data", destDataset = "Y",
                   header = TRUE, rownames = FALSE,
                   overwrite = TRUE, sep = ",", overwriteFile = FALSE)

bdCCA_hdf5_rcpp( hdf5_filename_rcpp, "data/X", "data/Y", bcenter = TRUE, 
                 bscale = FALSE, mblocks = 4, overwrite = TRUE )




# ====================================
# R Execution
# ====================================

hdf5_filename_R <- "cca_tcga_small_R.hdf5"

bdImportData_hdf5( inFile = Xfile,
                   destFile = hdf5_filename_R,
                   destGroup = "data", destDataset = "X",
                   header = TRUE, rownames = FALSE,
                   overwrite = TRUE, sep = ",", overwriteFile = TRUE)

bdImportData_hdf5( inFile = Yfile,
                   destFile = hdf5_filename_R,
                   destGroup = "data", destDataset = "Y",
                   header = TRUE, rownames = FALSE,
                   overwrite = TRUE, sep = ",", overwriteFile = FALSE)


# devtools::reload(pkgload::inst("BDStatMethExamples"))
# Execute data directly from HDF5 data file
bdCCA_hdf5( hdf5_filename_R, "data/X", "data/Y", bcenter = TRUE, m = 4,
            bscale = FALSE, overwrite = TRUE, keepInteResults = TRUE )






# ====================================
# Plot data
# ====================================

# Download metadata
urlfile <- paste0("https://raw.githubusercontent.com/isglobal-brge/",
                  "Supplementary-Material/master/Pelegri-Siso_2021/",
                  "application_examples/CCA/data/metadata.csv")
metadata <- read.csv(urlfile)

plot_bdCCA( hdf5_filename_rcpp, metadata, "cancer", plot_filename = "TCGA_CCA_rcpp.png" )
plot_bdCCA( hdf5_filename_R, metadata, "cancer", plot_filename = "TCGA_CCA_R.png" )



# ====================================
# Benchmark R - Rcpp functions
# ====================================

bench <- microbenchmark::microbenchmark( 
    R = bdCCA_hdf5( hdf5_filename_R, "data/X", "data/Y", bcenter = TRUE,
                    bscale = FALSE, overwrite = TRUE, keepInteResults = TRUE ),
    Rcpp = bdCCA_hdf5_rcpp( hdf5_filename_rcpp, "data/X", "data/Y", bcenter = TRUE, 
                            bscale = FALSE, overwrite = TRUE ),
    times = 5, unit = "milliseconds" )

bench

if (requireNamespace("ggplot2")) {
    ggplot2::autoplot(bench)
}
