###############################################################################
#
# create_restoration_areas()
#
# Creates polygon sf object with restoration areas.
# The file geodatabase that the argument pathFGDB points to must have a
# polygon layer of land areas names 'baselayer'.
#
###############################################################################

library(tidyverse)
library(sf)

create_restoration_areas <- function(planting_locations, p_gps_pts1, pathFGDB) {
  
 # get list of restoration areas from planting_locations
 restoration_area_names <- unique(planting_locations$restoration_area)
  
 # make gps pts into sf object and project from WGS84 lat/lon to State Plane.
 p_gps_pts_sf <- p_gps_pts1 %>% 
    select(site_location, latitude, longitude) %>%
    drop_na(latitude) %>%
    st_as_sf(coords=c("longitude","latitude"), crs=4326) %>%
    st_transform(crs=2927)
 
 # read in 'baselayer' from FGDB with land polygons
 baselayer <- st_read(dsn = pathFGDB, layer = "baselayer")
 
 # make convex hulls around grouped points  
 initial_hulls <- p_gps_pts_sf %>%
   group_by(restoration_area) %>%
   summarize(geometry = st_combine(geometry)) %>%
   st_convex_hull()
   
 land_obstacles <- st_union(baselayer)
 
 final_hulls <- st_difference(initial_hulls, land_obstacles)
 
 # write out to project file geodatabase
 st_write(final_nulls, dsn=pathFGDB, layer="restoration_areas",
           driver="OpenFileGDB", delete_layer=TRUE)
  
}

