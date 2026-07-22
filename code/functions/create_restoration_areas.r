###############################################################################
#
# create_restoration_areas()
#
# Creates polygon sf object with restoration areas.
# The file geodatabase that the argument pathFGDB points to must have a
# polygon layer of land areas named 'baselayer'.
#
###############################################################################

library(tidyverse)
library(sf)

create_restoration_areas <- function(planting_locations, p_gps_pts1, baselayer) {
 
 # Buffer dimension for point buffers that are grouped for convex hull areas.
 # Dimensions follow EPSG 2927 so are in US Survey feet.
 buffer_dimension <- 1500
   
 # make gps pts into sf object and project from WGS84 lat/lon to State Plane.
 p_gps_pts_sf <- p_gps_pts1 %>% 
    select(site_location, latitude, longitude) %>%
    drop_na(latitude) %>%
    st_as_sf(coords=c("longitude","latitude"), crs=4326) %>%
    st_transform(crs=2927)
 
 # make convex hulls around grouped point buffers 
 buffered_pts <- st_buffer(p_gps_pts_sf, dist=buffer_dimension)
 initial_hulls <- buffered_pts %>%
   rename("restoration_area" = "site_location") %>%
   group_by(restoration_area) %>%
   summarize(geometry = st_combine(geometry)) %>%
   st_convex_hull()
   
 land_obstacles <- st_union(baselayer)
 
 # Create water-only hulls by substracting land areas. This produces both
 # polygon and multipolygon features. Cast all to multipolygon.
 water_hulls <- suppressWarnings(st_difference(initial_hulls, land_obstacles))
 final_hulls <- st_cast(water_hulls, "MULTIPOLYGON")
 
 # Create restoration_area_code to serve as table key (no spaces), in both
 # planting_locations and in final_hulls.
 planting_locations <- planting_locations %>%
   mutate(restoration_area_code = str_replace_all(restoration_area," ","_")) %>%
   select(-restoration_area)
 restoration_areas <- final_hulls %>%
   mutate(restoration_area_code = str_replace_all(restoration_area," ","_"))

  
 returnObj <- list(restoration_areas, planting_locations)
 return(returnObj) 
}

