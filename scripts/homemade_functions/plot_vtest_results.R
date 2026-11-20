plot_vtest_results <- function(vtest_results){
  
  vtest_results_formatted <- vtest_results %>%
    left_join(tasklist_names, join_by('variable' == 'ID')) %>%
    mutate(k_number = as.factor(k_number),
           variable = ifelse(grepl('task', variable), paste0(variable, ': ', DESCRIPTION), variable),
           variable = reorder_within(variable, v.test, k_number))
  
  plot <- ggplot(vtest_results_formatted, aes(x = variable, 
                                              y = v.test, 
                                              fill = as.factor(k_number))) + 
    geom_col(width = 0.7) +
    coord_flip() +
    scale_x_reordered() +
    labs(x = NULL, 
         y = "v.test", 
         title = "Task score over/under-representation per cluster",
         fill  = 'Cluster') +
    theme_minimal(base_size = 12) +
    theme(legend.position  = "bottom",
          strip.text       = element_text(face = "bold", size = 12),
          panel.grid.major.y = element_blank(),
          axis.text.y = element_text(size = 8))+
    geom_hline(yintercept = 0, color = "grey20", linewidth = 0.4) +
    facet_wrap(~ k_number, scales = "free_y", ncol = 1)
  
  return(plot)
}
