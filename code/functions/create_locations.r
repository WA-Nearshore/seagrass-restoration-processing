###############################################################################
#
#  create_locations()
#
#  
#
###############################################################################

library(tidyverse)
source("code/functions/group_process.r")


create_locations <- function(p_gps_pts) {
  
  # summarize GPS point table by planting_location_code to get counts
  coord_counts <- p_gps_pts %>% group_by(planting_location_code) %>%
    summarize(loc_gps_rec_count = n(),
              latsumm = as.numeric(group_process_numeric(as.numeric(latitude))),
              lonsumm = as.numeric(group_process_numeric(as.numeric(longitude))))
  # add category variable for GPS coord status of planting locations
  coord_counts <- coord_counts %>%
    mutate(gps_category = if_else(is.na(latsumm),"missing",
                                 if_else(latsumm==222.0,"multiple_pts","good")))
  coord_summary <- coord_counts %>% group_by(gps_category) %>%
    summarize(count = n())
  
  # In processing the May28 version of the matrix snapshot, the coord_summary
  # above gave the following counts of planting_location_codes:
  #  good = 118;  missing = 13;  multiple_pts = 42
  #
  # As the summary of p_gps_pts based on plantingID gave 23 plantings without
  # GPS coords, this suggests 10 of these 23 can be located by planting_location_code.
  
  # To explore the spatial pattern of plantings in cases of planting_location_codes
  # with multiple coords, a data frame is made into an sf object and written to
  # file geodatabase for browning in an ArcGIS map.
 
  loc_code_jn_table <- coord_counts %>% select(planting_location_code, 
                                               loc_gps_rec_count, gps_category) 
  p_gps_pts_jn <- p_gps_pts %>% left_join(loc_code_jn_table,
                                          by = "planting_location_code")
  p_gps_pts_jn_cln <- p_gps_pts_jn %>% drop_na("latitude")
  
  p_gps_pts_jn_cln_sf_geo <- st_as_sf(p_gps_pts_jn_cln, 
                                      coords = c("longitude", "latitude"), 
                                      crs=4326)
  p_gps_pts_jn_cln_sf_StPl <- st_transform(p_gps_pts_jn_cln_sf_geo,
                                          crs=2927)
  
  st_write(p_gps_pts_jn_cln_sf_StPl, 
           dsn="2026_update_Pro_project/2026_update_Pro_project.gdb",
           layer="p_gps_pts_jn_StPl", driver="OpenFileGDB")
    
  
  
}