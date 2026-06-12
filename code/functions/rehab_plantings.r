###############################################################################
# rehab_plantings()
#
# For plantings with no coords, but at planting locations with coords, construct
# records for these plantings to bind to the spatial planting layer with the
# appropriate geometry.
#
# June 2026
# 
###############################################################################

library(tidyverse)
library(sf)


rehab_plantings <- function(rehab_plantingIDs, pt_plantings, ln_plantings,
                                   py_plantings, grid_plantings,
                                   planting_centroids, planting_locations) {
  
  # select planting_locations records with plc matching rehab_plantings
  
  # select geometry column from planting_locations
  
  # construct recrods in spatial feature format with plantingIDs, separate for
  # each geometry type
  
  # bind
  
  # return all
  
  
  
  
  
}