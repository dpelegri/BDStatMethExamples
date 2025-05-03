###################################################
library(BigDataStatMeth)
# library(rhdf5)
# library(tidyr)
# library(data.table)

# devtools::reload(pkgload::inst("BigDataStatMeth"))

setwd("/Users/mailos/PhD/dummy/Analyses/TCGA_CCA")

filecommon <- paste0("https://raw.githubusercontent.com/isglobal-brge/",
                     "Supplementary-Material/master/Pelegri-Siso_2021/",
                     "application_examples/CCA/data/")

Xfile <- paste0(filecommon, "RNA_data_small.zip")
Yfile <- paste0(filecommon, "Methyl_data_small.zip")


bdImportData_hdf5( inFile = Xfile,
                   destFile = "cca_tcga_small_rcpp.hdf5",
                   destGroup = "data", destDataset = "X",
                   header = TRUE, rownames = FALSE,
                   overwrite = TRUE, sep = ",", overwriteFile = TRUE)

bdImportData_hdf5( inFile = Yfile,
                   destFile = "cca_tcga_small_rcpp.hdf5",
                   destGroup = "data", destDataset = "Y",
                   header = TRUE, rownames = FALSE,
                   overwrite = TRUE, sep = ",", overwriteFile = FALSE)
