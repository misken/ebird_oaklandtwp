require(dplyr)
require(ggplot2)

otbird_top_species <- function(obs_df, bird_year, top = 30, plotfile = NULL){
  
  # Create num species by list df
  numsp_bylist <- obs_df %>%
    group_by(year=year(obsDt), obsDt, subId, lastName) %>%
    count() %>%
    arrange(year, subId)
  
  # Using numsp_bylist, create num lists by date
  numlists_bydt <- numsp_bylist %>%
    group_by(obsDt) %>%
    summarise(
      numlists = n()
    ) %>%
    filter(numlists >= 1) %>%
    arrange(obsDt)
  
  # Usings numlists_bydt, create num lists by year
  numlists_byyear <- numlists_bydt %>%
    group_by(birding_year=year(obsDt)) %>%
    summarise(
      totlists = sum(numlists)
    )
  
  # Now ready to compute species by year
  species_byyear <- obs_df %>%
    group_by(comName, birding_year=year(obsDt)) %>%
    summarize(
      num_lists = n(),
      tot_birds = sum(howMany)
    ) %>%
    arrange(birding_year, desc(tot_birds))
  
  # Join to numlists_byyear so we can compute pct of lists each species
  # appeared in.
  species_byyear <- left_join(species_byyear, numlists_byyear, by = 'birding_year') 
  
  top_obs_byyear <- species_byyear %>%
    filter(birding_year == bird_year) %>%
    mutate(pctlists = num_lists / totlists) %>%
    arrange(desc(tot_birds)) %>%
    head(top)
  
  g <-  ggplot(top_obs_byyear) + 
    geom_bar(aes(x=reorder(comName, tot_birds), 
                 y=tot_birds, fill=pctlists), stat = "identity") +
    #scale_fill_gradientn(colours = diverge_hcl(8)) +
    scale_fill_gradient(low='#05D9F6', high='#5011D1') +
    labs(x="", y="Total number of birds sighted", fill="Pct of lists",
         title = paste0("Top 30 most sighted birds by OT Birders in ", bird_year),
         subtitle = "(number at right of bar is % of lists on which the species appeared)") +
    coord_flip() +
    geom_text(data=top_obs_byyear,
              aes(x=reorder(comName,tot_birds),
                  y=tot_birds,
                  label=format(pctlists, digits = 1),
                  hjust=0
              ), size=3) + ylim(0,550)
  
  if (!is.null(plotfile)) {
    ggsave(g, height = 8, width = 8, filename = plotfile)
  }
  
  g
  
}