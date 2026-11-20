plot_top_loading <- function(loading_obj, dim_to_plot, n_task) {
  
  loadings_subset <- loading_obj %>%
    as.data.frame() %>%
    rownames_to_column('task') %>%
    left_join(tasklist_names, join_by('task' == 'ID'))%>%
    mutate(task_name = paste0(task, ': ', DESCRIPTION)) %>%
    pivot_longer(cols = starts_with(c("PC", "Dim")), names_to = 'dim', names_pattern = ".*?(\\d+)", values_to = 'loading') %>%
    filter(dim == dim_to_plot) %>%
    slice_max(abs(loading), n = n_task) %>%
    mutate(task_name = fct_reorder(task_name, loading),
           direction = ifelse(loading < 0, 'neg', 'pos')) 
  
  plot <- ggplot(loadings_subset, aes(x = task_name, y = loading, fill = direction))+
    geom_col()+
    coord_flip()+
    theme_bw()+
    guides(fill = 'none')+
    labs(title = paste0('dim', dim_to_plot))
  
  return(plot)
}

# should work with both PCA and MFS loadings
# plot_top_loading(results_mfa$quanti.var$coord, 4, 10)
# plot_top_loading(PCA_log$rotation, 3, 10)