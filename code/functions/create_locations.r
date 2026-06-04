###############################################################################
#
#  create_locations()
#
#  Based on planting GPS points (p_gps_pts), create planting locations table.
#
#  June 2026
#
###############################################################################

library(tidyverse)
source("code/functions/group_process.r")


create_locations <- function(p_gps_pts) {
 
  #########################################################################  
  # Create table to join onto gps pts with categorization of associated
  # planting locations by count of unique sets of gps points. Goal is to isolate
  # gps points where multiple sets associated with planting location.
  #########################################################################  
  # Summarize GPS point table by planting_location_code to get counts
  coord_counts <- p_gps_pts %>% group_by(planting_location_code) %>%
    summarize(loc_gps_rec_count = n(),
              latsumm = as.numeric(group_process_numeric(as.numeric(latitude))),
              lonsumm = as.numeric(group_process_numeric(as.numeric(longitude))))
  # Add category variable for GPS coord status of planting locations: 
  # missing=no coords; good=1 unique set of coords; multiple_pts=>1 set coords
  coord_counts <- coord_counts %>%
    mutate(gps_category = if_else(is.na(latsumm),"missing",
                                 if_else(latsumm==222.0,"multiple_pts","good")))
  # in June 2026 snapshot data: good=118, missing=13, multiple_pts=42
  coord_summary <- coord_counts %>% group_by(gps_category) %>%
    summarize(count = n())
  # select columns to make table to join to p_gps_pts  
  loc_code_jn_table <- coord_counts %>% select(planting_location_code, 
                                               loc_gps_rec_count, gps_category) 
  p_gps_pts_jn <- p_gps_pts %>% left_join(loc_code_jn_table,
                                          by = "planting_location_code")
  p_gps_pts_jn_cln <- p_gps_pts_jn %>% drop_na("latitude")
  
  p_gps_pts_jn_cln_sf_geo <- st_as_sf(p_gps_pts_jn_cln, 
                                      coords = c("longitude", "latitude"), 
                                      crs=4326)
  # gps point recs w/coords, converted to sf object in State Plane with counts
  # of unique gps recs with same planting_location_code added as an attribute.
  p_gps_pts_jn_cln_sf_StPl <- st_transform(p_gps_pts_jn_cln_sf_geo,
                                          crs=2927)
 
  # Group gps points by  
  
  
  
   
}