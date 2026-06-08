###############################################################################
#
#  qa_create_sankey()
#
#  Check for expected relationships between tables and get summary counts and
#  use them to create a Sankey diagram showing different groupings of data
#  entities and attributes.
#
#  June 2026
#
###############################################################################

library(tidyverse)
library(networkD3)
source("code/functions/group_process.r")

qa_create_sankey <- function (p_gps_pts1, sub_projects, plantings_table,
                              pt_plantings, ln_plantings, py_plantings,
                              grid_plantings, planting_centroids,
                              planting_locations) {
  
   
  ######################## Level 1
  L1.1 <- "planting GPS records"
  n_p_gps_pts <- dim(p_gps_pts1)[1]
  
   
  ######################## Level 2
  L2.1 <- "point planting GPS records"
  L2.2 <- "line planting GPS records"
  L2.3 <- "polygon planting GPS records"
  L2.4 <- "grid planting GPS records"
  
  # separate gps records by geometry, and presence of GPS coords 
  pt_recs <- p_gps_pts1 %>% filter(planting_geometry == "point")
  ln_recs <- p_gps_pts1 %>% filter(planting_geometry == "line")
  py_recs <- p_gps_pts1 %>% filter(planting_geometry == "polygon")
  grid_recs <- p_gps_pts1 %>% filter(planting_geometry == "grid")
  
  L2_source_vect <- rep(L1.1, times=4)
  L2_target_vect <- c(L2.1, L2.2, L2.3, L2.4)
  L2_value_vect <- c(dim(pt_recs)[1], dim(ln_recs)[1], dim(py_recs)[1], dim(grid_recs)[1])
  
  sankey_table <- data.frame(Source=L2_source_vect, Target=L2_target_vect, 
                             Value=L2_value_vect)
 
 
  ######################## Level 3
  L3.1 <- "point plantings"
  L3.2 <- "line plantings"
  L3.3 <- "polygon plantings"
  L3.4 <- "grid plantings"
 
  plantings_table_by_geom <- plantings_table %>% group_by(planting_geometry) %>%
    summarize(n_planting_geom = n())
  
  L3_target_vect <- c(L3.1, L3.2, L3.3, L3.4)
  L3_value1 <-  plantings_table_by_geom %>% filter(planting_geometry == "point") %>%
    pull(n_planting_geom)
  L3_value2 <-  plantings_table_by_geom %>% filter(planting_geometry == "line") %>%
    pull(n_planting_geom)
  L3_value3 <-  plantings_table_by_geom %>% filter(planting_geometry == "polygon") %>%
    pull(n_planting_geom)
  L3_value4 <-  plantings_table_by_geom %>% filter(planting_geometry == "grid") %>%
    pull(n_planting_geom)
  
  L3_value_vect <- c(L3_value1, L3_value2, L3_value3, L3_value4)
                    
  sankey_recs <- data.frame(Source=L2_target_vect, Target=L3_target_vect,
                            Value=L3_value_vect)
  sankey_table <- bind_rows(sankey_table, sankey_recs) 
  
 
  ######################## Level 4
  L4.1 <- "point plantings with coords"
  L4.2 <- "point plantings - no coords"
  L4.3 <- "line plantings 1pt"
  L4.4 <- "line plantings 2pt"
  L4.5 <- "polygon plantings 2pt"
  L4.6 <- "polygon plantings 3pt"
  L4.7 <- "polygon plantings 4pt"
  L4.8 <- "grid plantings with coords"
  L4.9 <- "grid plantings - no coords"
  
  L4_source_vect <- c(rep(L3.1, times=2), rep(L3.2, times=2),
                      rep(L3.3, times=3), rep(L3.4, times=2)) 
  
   
  # Get planting attributes: count gps pts, coord presence 
  gps_summary_to_plt <- p_gps_pts1 %>% group_by(plantingID) %>%
    summarize(count_gps_pts=n(), latsumm=group_process_numeric(latitude),
              lonsumm=group_process_numeric(longitude),
              planting_geometry=group_process_char(planting_geometry)) %>%
    mutate(coord_presence = if_else(is.na(latsumm),"missing","good"))
  
  plt_summary <- gps_summary_to_plt %>% group_by(planting_geometry, 
                                               count_gps_pts, coord_presence) %>%
                                        summarize(count_plantings = n())
  
  L4_target_vect <- c(L4.1, L4.2, L4.3, L4.4, L4.5, L4.6, L4.7, L4.8, L4.9)
  L4_value1 <- plt_summary %>% filter(planting_geometry == "point", 
                             coord_presence == "good") %>% pull(count_plantings)
  L4_value2 <- plt_summary %>% filter(planting_geometry == "point",
                          coord_presence == "missing") %>% pull(count_plantings)  
  L4_value3 <- plt_summary %>% filter(planting_geometry == "line",
                          count_gps_pts == 1) %>% pull(count_plantings)  
  L4_value4 <- plt_summary %>% filter(planting_geometry == "line",
                          count_gps_pts == 2) %>% pull(count_plantings)  
  L4_value5 <- plt_summary %>% filter(planting_geometry == "polygon",
                          count_gps_pts == 2) %>% pull(count_plantings)  
  L4_value6 <- plt_summary %>% filter(planting_geometry == "polygon",
                          count_gps_pts == 3) %>% pull(count_plantings)  
  L4_value7 <- plt_summary %>% filter(planting_geometry == "polygon",
                          count_gps_pts == 4) %>% pull(count_plantings)  
  L4_value8 <- plt_summary %>% filter(planting_geometry == "grid",
                          coord_presence == "good") %>% pull(count_plantings)  
  L4_value9 <- plt_summary %>% filter(planting_geometry == "grid",
                          coord_presence == "missing") %>% pull(count_plantings)  
  
  L4_value_vect <- c(L4_value1, L4_value2, L4_value3, L4_value4, L4_value5,
                     L4_value6, L4_value7, L4_value8, L4_value9)  
  sankey_recs <- data.frame(Source=L4_source_vect, Target=L4_target_vect,
                            Value=L4_value_vect)
  sankey_table <- bind_rows(sankey_table, sankey_recs) 
  
  
    
}

