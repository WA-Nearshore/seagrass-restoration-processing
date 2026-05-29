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
source("code/functions/notes_process.r")


create_plantings <- function(p_gps_pts) {

  # create planting key; somewhat complex so passed to function
  listReturnObj<- create_planting_key(p_gps_pts) 
  p_gps_pts_key <- listReturnObj[[1]]
  plantings_skeleton <- listReturnObj[[2]]
  
  # create plantings table 
  # Distill planting attributes from p_gps_pts_key and combine with skeleton
  planting_attr_reduced <- p_gps_pts_key %>%
    group_by(plantingID) %>%
    summarize(
        planting_geometry = group_process_char(planting_geometry),
        activity_type = group_process_char(activity_type),
        planting_date = group_process_date(as_date(planting_date)),
        planting_location_code = group_process_char(planting_location_code_summ),
        planting_method = group_process_char(planting_method_summ),
        parallel_length_m = group_process_numeric(as.numeric(parallel_length_m)),
        perpendicular_length_m = group_process_numeric(as.numeric(perpendicular_length_m)),
        plot_area_m2 = group_process_numeric(as.numeric(plot_area_m2)),
        planted_area_m2 = group_process_numeric(as.numeric(planted_area_m2)),
        effective_area_planted_m2 = 
          as.numeric(group_process_numeric(as.numeric(effective_area_planted_m2))),
        number_planting_units = 
          as.numeric(group_process_numeric(as.numeric(number_planting_units))),
        number_shoots = as.numeric(group_process_numeric(as.numeric(number_shoots))),
        plot_shoot_density_m2 = 
          as.numeric(group_process_numeric(as.numeric(plot_shoot_density_m2))),
        planted_area_shoot_density_m2 = 
          as.numeric(group_process_numeric(as.numeric(planted_area_shoot_density_m2))),
        donor_site_code = group_process_char(donor_site_code_summ),
        subproj_code = group_process_char(subproj_code),
        notes = notes_process(notes)
    )

  # join planting_attr_reduced on to plantings_skeleton
  plantings_v0 <- plantings_skeleton %>%
    left_join(planting_attr_reduced, by="plantingID")
 
  
  # order variables and select only needed variables
  plantings <- plantings_v0 %>%
    select(plantingID, planting_location_code, planting_date, planting_method,
           donor_site_code, subproj_code, activity_type, planting_geometry, 
           parallel_length_m, perpendicular_length_m, 
           plot_area_m2, planted_area_m2, effective_area_planted_m2,
           number_planting_units, number_shoots,
           plot_shoot_density_m2, planted_area_shoot_density_m2, notes)
 
  # create return list with two objects
  returnObj <- list(p_gps_pts_key, plantings)
  return(returnObj)
}
  