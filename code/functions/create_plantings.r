###############################################################################
#
# create_plantings()
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
source("code/functions/group_process.r")


create_plantings <- function(p_gps_pts) {

  # create planting key; somewhat complex so passed to function
  listReturnObj<- create_planting_key(p_gps_pts) 
  p_gps_pts_key <- listReturnObj[[1]]
  plantings_skeleton <- listReturnObj[[2]]
  
  # create plantings table 
  # Distill planting attributes from p_gps_pts_key and combine with skeleton
  planting_attr_reduced <- p_gps_pts_key %>%
    group_by(plantingID) %>%
    summarize(planting_geometry = group_process(planting_geometry),
              activity_type = group_process(activity_type),
              
    
}
  
  
  
  
  
  #  
  
  
  
  
}


 