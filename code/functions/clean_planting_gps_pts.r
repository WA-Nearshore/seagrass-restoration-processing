###############################################################################
#  clean_planting_gps_pts()
#
#  Performs initial clean of planting_gps_pts table read in from Matrix
#  Excel spreadsheet
#
#  April 2026
#
###############################################################################

clean_planting_gps_pts <- function(planting_gps_pts) {
  
  # remove trailing records not part of table; included in import due to
  # annotation
  p_gps_pts_filt <- planting_gps_pts %>% filter(!is.na(site_location))
  
  # remove second planting_geometry column and rename first one
  p_gps_pts_cln <- p_gps_pts_filt %>% 
    select(-planting_geometry...23) %>%
    rename("planting_geometry" = "planting_geometry...7")
  
  return(p_gps_pts_cln)
  
}