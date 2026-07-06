###############################################################################
#
#  create_monitoring.r
#
#  Takes the Monitoring sheet from the Matrix spreadsheet, links records to
#  plantings, and adds a planting key in creating a monitoring table.
#
#  Julyu 2026
#
###############################################################################

library(tidyverse)


create_monitoring <- function(monitoring_tbl, plantings, p_gps_pts1) {
 
  # clean up - remove if is.na(site_name)
  mon_tbl_cln <- monitoring_tbl %>% filter(!(is.na(site_name)))
  
  # anti_join to p_gps_pts
  mon_tbl_noMatch <- mon_tbl_cln %>%
    anti_join(p_gps_pts1, by = "site_name") 
  
   
  
  
  
   
 return(1)
}




