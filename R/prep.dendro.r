prep.dendro <- function(ctdIN){
    binned_file_dist <- dist(t(ctdIN$specificity_quantiles)) # euclidean distances between the rows
    binned_file_dist_hclust <- hclust(binned_file_dist)
    ddata <- ggdendro::dendro_data(binned_file_dist_hclust, type="rectangle")
    ordered_cells <- as.character(ddata$labels$label)
    a1 <- ggplot(segment(ddata)) + geom_segment(aes(x=x, y=y, xend=xend, yend=yend)) + coord_flip() +  theme_dendro()
    a1 <- a1 + scale_x_continuous(expand = c(0, 1.3))
    b1 <- ggplot(segment(ddata)) + geom_segment(aes(x=x, y=y, xend=xend, yend=yend)) + theme_dendro()
    b1 <- b1 + scale_x_continuous(expand = c(0, 1.3))
    ctdIN$plotting = list()
    ctdIN$plotting$ggdendro_vertical = a1
    ctdIN$plotting$ggdendro_horizontal = b1
    ctdIN$plotting$cell_ordering = ordered_cells
    return(ctdIN)
}



