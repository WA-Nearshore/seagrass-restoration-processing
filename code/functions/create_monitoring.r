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
  # planting
  mon_tbl_noMatch <- mon_tbl_cln %>%
    anti_join(p_gps_pts1, by = "site_name") 

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
 
  # recalculate days_since_planting, using trusted planting_date
  planting_tbl_date <- plantings %>% select(plantingID, planting_date)
  mon_tbl_1 <- mon_tbl_jn_sel %>% 
    left_join(planting_tbl_date, by="plantingID") %>%
    mutate(days_since_planted = as.numeric(difftime(monitoring_date, planting_date,
                                                    units = "days"))) %>%
    select(-planting_date)
  
  # get plantings with no monitoring data 
  plantings_noMonData <- plantings %>%
    anti_join(mon_tbl_jn, by = "plantingID")
  
  # make return list with (a) new monitoring table, (b) monitoring records with
  # no matching planting, (c) plantings records with no monitoring data
  mon_returnObj <- list(mon_tbl_1, mon_tbl_noMatch, plantings_noMonData)
   
  return(mon_returnObj)
}




