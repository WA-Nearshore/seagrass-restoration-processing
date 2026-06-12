###############################################################################
#
# create_restoration_areas()
#
# Creates polygon sf object with restoration areas.
#
# June 2026
#
###############################################################################

library(tidyverse)
library(sf)

create_restoration_areas <- function(planting_locations, p_gps_pts1) {
  
 # get list of restoration areas from planting_locations
 restoration_area_names <- unique(planting_locations$restoration_area)
  
 # make gps pts into sf object; group pts by restoration area
 p_gps_pts1_sel <- p_gps_pts1 %>% 
    select(site_location, latitude, longitude) %>%
    drop_na(latitude) %>%
    st_as_sf(coords=c("longitude","latitude"), crs=4326)
 
 # make convex hull around pts for each restoration area
 
  
  
  
  
}

