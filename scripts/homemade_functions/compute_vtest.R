compute_vtest <- function(df, k, hclust_obj){
  
  clusters <- cutree(hclust_obj, k=k)
  df <- as.data.frame(df)
  df$clusters <- as.factor(clusters[match(rownames(df), names(clusters))])
  
  vtest_results <- catdes(df,
                          num.var = which(colnames(df) == "clusters"),
                          proba = 1) #keeping all variables
  
  results <- lapply(1:k, function(k) {
    
    res_list <- list()
    
    # numeric variables
    if (!is.null(vtest_results$quanti[[k]])) {
      res_list$quanti <- vtest_results$quanti[[k]] %>%
        as.data.frame() %>%
        rownames_to_column("variable") %>%
        mutate(
          k_number = k,
          type = "numeric"
        ) %>%
        dplyr::select(variable, k_number, type, v.test, p.value)
    }
    
    # categorical variables
    if (!is.null(vtest_results$category[[k]])) {
      res_list$category <- vtest_results$category[[k]] %>%
        as.data.frame() %>%
        rownames_to_column("variable") %>%
        mutate(
          k_number = k,
          type = "categorical"
        ) %>%
        dplyr::select(variable, k_number, type, v.test, p.value)
    }
    
    bind_rows(res_list) %>%
      mutate(
        adj_pval_BH = p.adjust(p.value, method = "BH")
      )
    
  }) %>%
    bind_rows()
  
  
  return(results)
}


