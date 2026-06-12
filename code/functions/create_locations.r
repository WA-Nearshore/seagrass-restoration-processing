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
library(sf)
source("code/functions/group_process.r")


create_locations <- function(p_gps_pts, pathFGDB) {
 
  #########################################################################  
  # Isolate GPS records where the planting location is associated with 
  # multiple sets of GPS coords.
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
  # planting location counts (June 2026): good=118, missing=13, multiple_pts=42
  coord_summary <- coord_counts %>% group_by(gps_category) %>%
    summarize(count = n())
  # select columns to make table to join to p_gps_pts  
  loc_code_jn_table <- coord_counts %>% select(planting_location_code, 
                                               loc_gps_rec_count, gps_category) 
  p_gps_pts_jn <- p_gps_pts %>% left_join(loc_code_jn_table,
                                          by = "planting_location_code")
  
  # isolate gps point records for planting locations with multiple sets of coords
  p_gps_pts_jn_cln_mult <- p_gps_pts_jn %>% filter(gps_category == "multiple_pts")

   
   
  ##########################################################################
  # Process planting locations by gps coord category
  #  'missing' is saved to csv; 'multiple_pts' is reduced to centroids and
  #  combined with 'good' to form initial planting_locations table. 
  ##########################################################################

  # for plantings with no coords, write planting location codes to csv file
  planting_loc_missing_coords <- coord_counts %>% filter(gps_category=="missing") 
  write.csv(planting_loc_missing_coords, 
            file="output_tables/planting_loc_no_coords.csv")
  
  # get centroids for planting locations with multiple sets of coords
  p_gps_pts_mult_cln <- p_gps_pts_jn_cln_mult %>% drop_na(latitude, longitude)
  p_gps_pts_mult_sf_geo <- st_as_sf(p_gps_pts_mult_cln,
                                    coords = c("longitude", "latitude"),
                                    crs=4326)
  p_gps_pts_mult_sf_StPl <- st_transform(p_gps_pts_mult_sf_geo, crs=2927)
  plant_loc_mult_centroids <- p_gps_pts_mult_sf_StPl %>% 
    group_by(planting_location_code) %>%
    summarize(geometry = st_union(geometry)) %>%
    st_centroid()
  
  # combine "good"  planting locations with multiple_pt centroids
  coord_counts_good <- coord_counts %>% 
    filter(gps_category == "good") %>%
    select(planting_location_code, latsumm, lonsumm)
  plant_loc_good_sf_geo <- st_as_sf(coord_counts_good,
                                    coords = c("lonsumm","latsumm"),
                                    crs=4326)
  plant_loc_good_sf_StPl <- st_transform(plant_loc_good_sf_geo, crs=2927)
  planting_location_start <- bind_rows(plant_loc_mult_centroids,
                                       plant_loc_good_sf_StPl)
  
   
  ##########################################################################
  #  Construct attributes for planting_locations from p_gps_pts and add to
  #  planting locations.
  ##########################################################################
  plt_loc_attr <- p_gps_pts %>% group_by(planting_location_code) %>%
    summarize(
       restoration_area = group_process_char(site_location),
       historical_presence_source = group_process_char(historical_presence_source),
       water_body = group_process_char(water_body),
       svmp_region = group_process_char(svmp_region),
       elevation_m_MLLW = group_process_numeric(elevation_m_MLLW)
    )
  planting_locations <- planting_location_start %>%
    left_join(plt_loc_attr, by="planting_location_code")
  
  
  
  # write planting_locations point spatial layer to fgdb
  st_write(planting_locations, dsn=pathFGDB, layer="planting_locations",
           driver="OpenFileGDB", delete_layer=TRUE)
  
  # return list with planting_locations table and platnings with missing coords
  returnObj <- list(planting_locations, planting_loc_missing_coords)
  return(returnObj) 
   
}