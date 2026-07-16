###############################################################################
#
#  qa_checks()
#
#  function to check database integrity across the related tables created from
#  the seagrass resotration matrix input data.
#
#  
#  July 2026
#
###############################################################################

library(tidyverse)



  #######################################################################
  # get breakdown of present/absent and measured 
  #######################################################################
  veg_pres_freq <- mon_tbl_1 %>%
    group_by(veg_presence) %>%
    summarize(count = n())
  veg_pres_meas_freq <- mon_tbl_1 %>%
    filter(veg_presence == "present") %>%
    mutate(meas = case_when(
     is.na(shoot_count) ~ "presence_only",
     is.numeric(shoot_count) ~ "present_measurements"
   )) %>%
   group_by(meas) %>%
   summarize(count = n())
   
  
   
  
 ##### summarize BESE/grid monitoring
  
  
 
  #######################################################################
  # verify monitoring attributes shared with plantings table 
  ######################################################################
  
  # Use plantingID just added to monitoring table to join with plantings to
  # verify shared columns
  mon_tbl_planting_qa <- mon_tbl_jn %>%
    left_join(plantings, by="plantingID")
 
   # add 4 match status variables for: planting date, area, num_shoots, method
   mon_tbl_planting_qa <- mon_tbl_planting_qa %>%
    mutate(plt_date_match = ifelse(planting_date.x == planting_date.y,
                                   "match", "no_match"),
           plt_area_match = case_when(
             is.na(planted_area_m2.x) | is.na(planted_area_m2.y) ~ "missing_data",
             str_detect(planted_area_m2.x,"[^0-9.]") | str_detect(planted_area_m2.y, "[^0-9.]") ~ "non-numeric", 
             !(near(as.numeric(planted_area_m2.x), as.numeric(planted_area_m2.y))) ~ "no_match",
             near(as.numeric(planted_area_m2.x), as.numeric(planted_area_m2.y)) ~ "match",
             .default = "unknown"
           ),
           num_shoots_match = case_when(
             is.na(number_shoots.x) | is.na(number_shoots.y) ~ "missing_data",
             str_detect(number_shoots.x,"[^0-9.]") | str_detect(number_shoots.y, "[^0-9.]") ~ "non-numeric", 
             as.numeric(number_shoots.x) != as.numeric(number_shoots.y) ~ "no_match",
             as.numeric(number_shoots.x) == as.numeric(number_shoots.y) ~ "match"
           ),
           plt_method_match = case_when(
             is.na(planting_method.x) | is.na(planting_method.y) ~ "missing_data",
             planting_method.x != planting_method.y ~ "no_match",
             planting_method.x == planting_method.y ~ "match"
           )
    ) %>% 
    select(site_name, planting_date.x, planted_area_m2.x, number_shoots.x, planting_method.x,
                      planting_date.y, planted_area_m2.y, number_shoots.y, planting_method.y,
           plt_date_match, plt_area_match, num_shoots_match, plt_method_match)
  
  planting_date_Match_cnt <- sum(mon_tbl_planting_qa$plt_date_match == "match")
  planting_area_Match_cnt <- sum(mon_tbl_planting_qa$plt_area_match == "match")
  plt_num_shoots_Match_cnt <- sum(mon_tbl_planting_qa$num_shoots_match == "match")
  plt_method_Match_cnt <- sum(mon_tbl_planting_qa$plt_method_match == "match")
    
  ### values above examined from console; discrepancies seen between values for 
  ### shared variables in the monitoring and p_gps_pts (matrix:  Planting)
  ### table.  Monitoring values ignored and not kept in the final monitoring
  ### table.
  
  
  






