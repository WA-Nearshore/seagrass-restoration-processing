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
  L2.1 <- "pt planting GPS recs"
  L2.2 <- "ln planting GPS recs"
  L2.3 <- "py planting GPS recs"
  L2.4 <- "gr planting GPS recs"
  
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
  L4.1 <- "pt pltings coords"
  L4.2 <- "pt pltings-no coords"
  L4.3 <- "ln plantings 1pt"
  L4.4 <- "ln plantings 2pt"
  L4.5 <- "poly plantings 2pt"
  L4.6 <- "poly plantings 3pt"
  L4.7 <- "poly plantings 4pt"
  L4.8 <- "gr pltings coords"
  L4.9 <- "gr pltings-no coords"
  
  L4_source_vect <- c(rep(L3.1, times=2), rep(L3.2, times=2),
                      rep(L3.3, times=3), rep(L3.4, times=2)) 
  
   
  # Get planting attributes: count godd gps pts, coord presence category
  gps_summary_to_plt <- p_gps_pts1 %>% group_by(plantingID) %>%
    summarize(count_gps_pts=sum(!is.na(latitude)), latsumm=group_process_numeric(latitude),
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
  
  
  ######################## Level 5
  #        1........1.........2
  L5.1 <- "pltings as points"
  L5.2 <- "pltings as lines"
  L5.3 <- "pltings as polys"
  L5.4 <- "pltings as grids"
  L5.5 <- "pltings no coords"
  
  L5_source_vect <- c(L4_target_vect[1], L4_target_vect[3], L4_target_vect[4],
                      L4_target_vect[5], L4_target_vect[6], L4_target_vect[7],
                      L4_target_vect[8], L4_target_vect[2], L4_target_vect[9])
  
  L5_target_vect <- c(L5.1, L5.1, L5.2, L5.2, L5.3, L5.3, L5.4, L5.5, L5.5)
  
  L5_value1 <- L4_value1
  L5_value2 <- L4_value3
  L5_value3 <- L4_value4
  L5_value4 <- L4_value5
  L5_value5 <- L4_value6
  L5_value6 <- L4_value7
  L5_value7 <- L4_value8
  L5_value8 <- L4_value2
  L5_value9 <- L4_value9
  L5_value_vect <- c(L5_value1, L5_value2, L5_value3, L5_value4, L5_value5,
                     L5_value6, L5_value7, L5_value8, L5_value9)
  
  sankey_recs <- data.frame(Source=L5_source_vect, Target=L5_target_vect,
                            Value=L5_value_vect)
  sankey_table <- bind_rows(sankey_table, sankey_recs) 
  
  
  ######################## Level 6
  L6.1 <- "plantings w/coords"
  L6.2 <- "plantings-no coords" 
  
  L6_source_vect <- c(L5.1, L5.2, L5.3, L5.4, L5.5)
  L6_target_vect <- c(rep(L6.1, times=4), L6.2)
  
  
  
  
    
}

