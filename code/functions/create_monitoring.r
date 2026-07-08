###############################################################################
#
#  create_monitoring.r
#
#  Takes the Monitoring sheet from the Matrix spreadsheet, links records to
#  plantings, and adds a planting key in creating a monitoring table.
#
#  July 2026
#
###############################################################################

library(tidyverse)


create_monitoring <- function(monitoring, plantings, p_gps_pts1) {
 
  # clean up monitoring data- remove if is.na(site_name)
  mon_tbl_cln <- monitoring %>% filter(!(is.na(site_location)))
  
  # anti_join to p_gps_pts
  mon_tbl_noMatch <- mon_tbl_cln %>%
    anti_join(p_gps_pts1, by = "site_name") 
  
  p_gps_pts_jn_tbl <- p_gps_pts1 %>% select(site_name, plantingID) 
  mon_tbl_jn <- mon_tbl_cln %>%
    left_join(p_gps_pts_jn_tbl, by = "site_name", multiple="first")
  
  
   
 return(1)
}




