###############################################################################
#
# create_lyrs()
#
# Create separate spatial layers for point, line and polygon plantings from the
# planting_gps_pts table.
#
# Returns a list with elements:
#  1. pt_plantings  point plantings spatial layer
#  2. ln_plantings  line plantings spatial layer
#  3. py_plantings  polygon plantings spatial layer
#  4. planting_centroids  point layer encompassing all plantings
#  5. planting_attributes  table of planting attributes extracted from p_gps_pts
#
# April 2026
#
###############################################################################

library(tidyverse)
source("code/functions/create_planting_key.r")

create_lyrs <- function(p_gps_pts) {

  # create planting key; somewhat complex so passed to function
  p_gps_pts_pltkey <- create_planting_key(p_gps_pts) 
  
  
  # separate records by geometry type
  pt_recs <- p_gps_pts %>% filter(planting_geometry == "point")
  ln_recs <- p_gps_pts %>% filter(planting_geometry == "line")
  py_recs <- p_gps_pts %>% filter(planting_geometry == "polygon")
  
  # filter for NA planting geometry and write site names to console
  # these records not included in above geometries, essentially dropped
  na_recs <- p_gps_pts %>% filter(is.na(planting_geometry))
  cat("\n")
  print(sprintf("%d records from planting_GPS_pts dropped due to NA planting geometry.",
                dim(na_recs)[1]))
  print(na_recs$site_name)
  cat("\n")
  
  # Convert data frames with lat/lon columns into spatial sf objects
  # Filter out plantings with records missing lat/lon
  # First convert to point features
  # Second assemble points into line and polygon features
  
  
  
  #  
  
  
  
  
}


 