evaluate_nPC <- function(df_scores, k_max, nPC){
  
  cat('running for', nPC, 'PCs', '\n')
  
  results_PCA <- prcomp(df_scores, scale. = FALSE, center = FALSE)
  
  PCs <- results_PCA$x[, 1:nPC]
  
  results <- data.frame(nPC = nPC,
                        k = 2:k_max)
  
  for (k in 2:k_max){
    
    cat('running for k=', k, '\n')
    
    row_i <- which(results$k == k)
    
    results_hcut = hcut(PCs, k=k)
    
    n_per_cluster <- results_hcut$size
    sil_per_cluster <- results_hcut$silinfo$clus.avg.widths
    sil_per_cluster <- format(round(sil_per_cluster, 2), nsmall =2)
    
    results[row_i, 'n_per_cluster'] <- paste(n_per_cluster, collapse = ',')
    results[row_i, 'sil_per_cluster'] <- paste(sil_per_cluster, collapse = ',')
    results[row_i, 'sil_average'] <- format(round(results_hcut$silinfo$avg.width, 2), nsmall = 2)
    
    results_stability <- clusterboot(df_scores,
                                     bootmethod = 'boot',
                                     distances= F,
                                     clustermethod = homemade_hclust_function,
                                     k=k,
                                     apply_PCA = T,
                                     nPC = nPC,
                                     B=100, seed=456)
    
    results[row_i, 'stability'] <- paste(round(results_stability$bootmean, 2), collapse = ',')
    results[row_i, 'stability_average'] <- format(round(mean(results_stability$bootmean), 2), nsmall = 2)
    
  }
  
  return(results)
}

#evaluate_nPC(df_scores_scaled, k_max = 6, nPC = 2)
