homemade_clusterboot_function <- function(data, k, apply_PCA = F, nPC = NULL){
  
  # df_scores should already be scaled and log-transformed
  # if apply_PCA == T, then nPC needs to be set and the hclust with be performed on the PCs
  # if apply_PCA == F (default), then hclust is done on the df_scores
  
  if (apply_PCA){
    if (is.null(nPC)){
      stop('if apply PCA is true, then nPC needs to be specified')
    }
    else{
      results_PCA <- prcomp(data, scale = F, center = F)
      result <- hclust(dist(results_PCA$x[, 1:nPC], method = 'euclidean'), method = 'ward.D2')
    }
  } else {
    result <- hclust(dist(data, method = 'euclidean'), method = 'ward.D2')
  }
  
  partition <- cutree(result, k=k)
  
  clusterlist <- lapply(1:k, function(x){partition == x})
  
  return(list(result = result, nc = k, clusterlist = clusterlist,
              partition  = partition, clustermethod = 'homemade_hclust_function'))
  
}