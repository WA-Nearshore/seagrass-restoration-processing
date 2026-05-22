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
              planting_date = group_process(as_date(planting_date)),
              planting_location_code = group_process(planting_location_code_summ),
              planting_method = group_process(planting_method_summ),
              parallel_length_m = group_process(as.numeric(parallel_length_m)),
              perpendicular_length_m = group_process(as.numeric(perpendicular_length_m)),
              plot_area_m2 = group_process(as.numeric(plot_area_m2)),
              planted_area_m2 = group_process(as.numeric(planted_area_m2)),
              effecive_area_planted_m2 = group_process(as.numeric(effective_area_planted_m2)),
              number_planting_units = group_process(as.numeric(number_planting_units)),
              number_shoots = group_process(as.numeric(number_shoots)),
              plot_shoot_density_m2 = group_process(as.numeric(plot_shoot_density_m2)),
              planted_area_shoot_density_m2 = group_process(as.numeric(planted_area_density_m2)),
              donor_site_code = group_process(donor_site_code_summ),
              subproject_code = group_process(subproject_code)
    )
              
    
}
  
  
  
  
  
  #  
  
  
  
  
}


 