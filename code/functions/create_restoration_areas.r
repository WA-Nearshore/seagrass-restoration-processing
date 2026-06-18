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
 
 # buffer dimension for point buffers that are grouped for convex hull areas
 # dimensions follow EPSG 2927 so are in US Survey feet
 buffer_dimension <- 1500
   
 # get list of restoration areas from planting_locations
 restoration_area_names <- unique(planting_locations$restoration_area)
  
 # make gps pts into sf object and project from WGS84 lat/lon to State Plane.
 p_gps_pts_sf <- p_gps_pts1 %>% 
    select(site_location, latitude, longitude) %>%
    drop_na(latitude) %>%
    st_as_sf(coords=c("longitude","latitude"), crs=4326) %>%
    st_transform(crs=2927)
 
 # read in 'baselayer' from FGDB with land polygons; project to StPl Wash S
 baselayer <- st_read(dsn = pathFGDB, layer = "baselayer") %>%
   st_transform(crs=2927)
 
 # make convex hulls around grouped point buffers 
 buffered_pts <- st_buffer(p_gps_pts_sf, dist=buffer_dimension)
 initial_hulls <- buffered_pts %>%
   rename("restoration_area" = "site_location") %>%
   group_by(restoration_area) %>%
   summarize(geometry = st_combine(geometry)) %>%
   st_convex_hull()
   
 land_obstacles <- st_union(baselayer)
 
 ### Initial hulls successfuly written to fgdb and viewed on map.
 ### dim(final_hulls) = [0,2] so here is the problem.
 final_hulls <- st_difference(initial_hulls, land_obstacles)

 # temp debug 
 st_write(p_gps_pts_sf, dsn=pathFGDB, layer="p_gps_pts_sf_test",
           driver="OpenFileGDB", delete_layer=TRUE)
 st_write(initial_hulls, dsn=pathFGDB, layer="initial_hulls",
           driver="OpenFileGDB", delete_layer=TRUE)
 
 
 # write out to project file geodatabase
 st_write(initial_hulls, dsn=pathFGDB, layer="init_restoration_areas",
           driver="OpenFileGDB", delete_layer=TRUE)
 # previsou write executed w/out error but not seen within fgdb from Pro.
  
}

