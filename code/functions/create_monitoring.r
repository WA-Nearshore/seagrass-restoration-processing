###############################################################################
#
#  create_monitoring.r
#
#  Takes the Monitoring sheet from the Matrix spreadsheet, links records to
#  plantings, and adds a planting key to create a monitoring table.
#
#  The monitoring records that do not match any planting records are written
#  to csv file. The planting records that have no matching monitoring data
#  are also written to csv file.
#
#  July 2026
#
###############################################################################

library(tidyverse)


create_monitoring <- function(monitoring, plantings, p_gps_pts1) {

   
  #######################################################################
  # create working monitoring table
  #######################################################################
  
  # clean up monitoring data- remove if is.na(site_name); blank, spacer lines
  mon_tbl_cln <- monitoring %>% filter(!(is.na(site_location)))
  
  # anti_join to p_gps_pts to get monitoring records not matched with a 
  # planting and write to csv file
  mon_tbl_noMatch <- mon_tbl_cln %>%
    anti_join(p_gps_pts1, by = "site_name") 
  write.csv(mon_tbl_noMatch, file="output_tables/monitoring_recs_noMatch.csv")

  # join plantingID column from p_gps_pts onto monitoring table, drop records
  # with no matches
  p_gps_pts_jn_tbl <- p_gps_pts1 %>% select(site_name, plantingID) 
  mon_tbl_jn <- mon_tbl_cln %>%
    left_join(p_gps_pts_jn_tbl, by = "site_name", multiple="first") %>%
    drop_na(plantingID)
 
  # simplify the monitoring table
  mon_tbl_jn_sel <- mon_tbl_jn %>%
    select(site_location, site_name, plantingID, monitoring_org, monitoring_date,
           veg_presence, shoot_count, veg_area_m2, shoot_density_m2,
           days_since_planted, survival, notes, notes2)
 
 ##### get breakdown of presence and measured
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
  ### table.  Monitoring values ignored.
  
  
  
  
  
  
  
  
  
  # get plantings with no monitoring data and write to csv file
  plantings_noMonData <- plantings %>%
    anti_join(mon_tbl_jn, by = "plantingID")
  write.csv(plantings_noMonData, file="output_tables/planting_recs_NoMonData.csv")
  
  
   
 return(1)
}




