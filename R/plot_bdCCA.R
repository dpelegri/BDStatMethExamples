#' Plot Canonical Correlation Analysis
#' 
#' Plot Canonical Correlation Analysis with blocks results 
#' 
#' @export
#' 
#' @param filename string file name where dataset to normalize is stored.
#' @param metadata  dataset with metadata file name where dataset to normalize is stored.
#' @param pheno string column name with the pheno to be used in the plot
#' @param column_id string (optional), metadata column name to be used to merge 
#' data (rownames in xcoef and ycoef). If null, a merge of the datasets is 
#' performed assuming that the data is sorted.
#' @param plot_filename string (optional), filename to store the plot
#' @examples
#'    print ("Example in vignette")
#'    
#' @importFrom magrittr %>%
plot_bdCCA <- function( hdf5_filename, metadata, pheno, 
                        column_id = NULL, plot_filename = NULL  )
{

    # Check if file exists    
    if(!file.exists(hdf5_filename)){
        message("ERROR - File does not exists")
        return()
    }

    # Check if pheno exists
    if(!pheno %in% colnames(metadata)){
        message("ERROR - Pheno variable can't be found in the metadata")
        return()
    }
    
    # Check if column_id exists
    if( !is.null(column_id) && !column_id %in% colnames(metadata)){
        message("ERROR - column_id variable can't be found in the metadata")
        return()
    }
    
    # Open file and get data, all data is stored under SVD group
    h5f = H5Fopen(hdf5_filename)
        # cor <- as.data.frame(h5f$Results$cor)
        # colnames(cor) <- (h5f$Results$.xcoef_dimnames$`1`)[1:dim(cor)[1],1]
        # rownames(cor) <- (h5f$Results$.xcoef_dimnames$`1`)[1:dim(cor)[1],1]
        # 
        xscores <- as.data.frame(h5f$Results$xscores)
        colnames(xscores) <- sprintf("CCAX_%s",seq(1:dim(xscores)[2]))
        yscores <- as.data.frame(h5f$Results$yscores)
        colnames(yscores) <- sprintf("CCAY_%s",seq(1:dim(xscores)[2]))
    h5closeAll()
    
    if(is.null(column_id))
        full_data <- cbind(metadata, xscores, yscores)
    else
        full_data <- merge(xscores, metadata, by.x = 0, by.y = column_id)

    common_theme <- theme(
        axis.text = element_text(size = 28, face="bold"),
        axis.title = element_text(size = 28, face="bold"),
        legend.background = element_blank(),
        legend.key = element_blank(),
        legend.position = "bottom",
        legend.text = element_text( size = 24),
        panel.background = element_rect(fill = "white", colour = "black"),
        strip.background = element_blank(),
        plot.background = element_blank(),
        panel.grid = element_blank(),
        legend.title = element_blank()
    )
    
    
    ccax <- c("CCAX_1", "CCAX_2", "CCAX_3")
    ccay <- c("CCAY_1", "CCAY_2", "CCAY_3")
    full_data[,pheno] <- as.factor(full_data[,pheno])
    
    p1 <- full_data %>%
        ggplot( aes_string( x =  ccax[1], y = ccay[1] , color = pheno )) +
        geom_point(  size = 1.8 ) +
        stat_ellipse( linewidth = 2) +
        common_theme +
        guides(colour = guide_legend(override.aes = list(size = 16)))
    
    p2 <- full_data %>%
        ggplot( aes_string( x =  ccax[2], y = ccay[2] , color = pheno )) +
        geom_point(  size = 1.8 ) +
        stat_ellipse( linewidth = 2) +
        common_theme +
        guides(colour = guide_legend(override.aes = list(size = 16)))
    
    p3 <- full_data %>%
        ggplot( aes_string( x =  ccax[3], y = ccay[3] , color = pheno )) +
        geom_point(  size = 1.8 ) +
        stat_ellipse( linewidth = 2) +
        common_theme +
        guides(colour = guide_legend(override.aes = list(size = 16)))
    
    
    if(!is.null(plot_filename)) {
        fname <- plot_filename
        png(filename = fname, width = 1815, height = 900, units = "px")
            grid.arrange( p1, p2, p3, nrow = 1 )
        dev.off()
    } 
    
    return( grid.arrange( p1, p2, p3, nrow = 1 ))
    
}