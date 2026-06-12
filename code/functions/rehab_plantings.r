###############################################################################
# rehab_plantings()
#
# For plantings with no coords, but at planting locations with coords, construct
# records for these plantings to bind to the spatial planting layer with the
# appropriate geometry.
#
# This function may need to be revised as new planting data are added.
# This initial version (June 2026) requires "grid" and "point" planting 
# geometries and only these in the "rehab" plantings.
#
# Rehab plantings do not have GPS coordinates and so are not in the initial 
# spatial layers created.  But these plantings are at a planting location
# whose locatoin is known.  This function assembles the info needed and
# appends spatial features to the appropriate spatial layers for these rehab
# plantings.
#
# June 2026
# 
###############################################################################

library(tidyverse)
library(sf)


rehab_plantings <- function(rehab_plantingIDs, pt_plantings, ln_plantings,
                                   py_plantings, grid_plantings,
                                   planting_centroids, planting_locations) {
  
  # select planting_locations records with planting_location_code matching 
  # rehab_plantings, and select columns needed for join table
  plt_loc_sel_rehab <- planting_locations %>% 
    filter(planting_location_code %in% rehab_plantingIDs$planting_location_code) %>%
    select(planting_location_code, geometry)
  
  # join table to the rehab plantings; planting_location_code no longer needed
  rehab_plantIDs_jn_geom <- rehab_plantingIDs %>% 
    left_join(plt_loc_sel_rehab, by="planting_location_code") %>%
    select(-planting_location_code)
 
  # check that data is within limited scope of this function (planting geometry) 
  vect_of_geoms <- unique(rehab_plantIDs_jn_geom$planting_geometry)
  if ((length(vect_of_geoms)!=2) | !("grid" %in% vect_of_geoms) |
      !("point" %in% vect_of_geoms)) {
      print("ERROR - unexpected rehab geometries")
  }
  # split records by geometry; then drop planting_geometry column; make sf object
  rehab_point_recs <- rehab_plantIDs_jn_geom %>% 
    filter(planting_geometry == "point") %>% 
    select(-planting_geometry) %>%
    st_as_sf()
  rehab_grid_recs <- rehab_plantIDs_jn_geom %>%
    filter(planting_geometry == "grid") %>% 
    select(-planting_geometry) %>%
    st_as_sf()
   
  # bind (append) to existing planting spatial layers
  pt_plantings <- bind_rows(pt_plantings, rehab_point_recs)
  grid_plantings <- bind_rows(grid_plantings, rehab_grid_recs)
  planting_centroids <- bind_rows(planting_centroids, rehab_point_recs,
                                  rehab_grid_recs)
  
  # return all
  returnObj <- list(pt_plantings, ln_plantings, py_plantings, grid_plantings,
                    planting_centroids)
  return(returnObj)
  
}