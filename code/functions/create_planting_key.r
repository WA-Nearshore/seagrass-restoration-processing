###############################################################################
#
#  create_planting_key()
#
#  function to create planting keys within a version of the planting GPS points
#  table passed as an argument.
#
#  
#  April 2026
#
###############################################################################

library(tidyverse)


group_process <- function(indata,group_no) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    print(sprintf("Error: group %d is all NA: %d  %d",group_no[1],n0,n1))
  }
  else if (n1 == 1) {
   return(indata_cln[1])
  } else if (n1 > 1) {
   return("multiple") 
  }
}



create_planting_key <- function(p_gps_pts) {
  
  # step through records using activity_filter to assign initial group number
  p_gps_pts1 <- p_gps_pts %>% mutate(group_no = -1)
 
  planting_num <- 0 
  for (i in seq(1:dim(p_gps_pts1)[1])) {
    if (p_gps_pts1[i,"activity_filter"] != "--") {
      planting_num <- planting_num + 1
      p_gps_pts1[i,"group_no"] <- planting_num 
    } else {
      p_gps_pts1[i,"group_no"] <- planting_num
    }
  }
  
  # summarize on group number
  group_summary <- p_gps_pts1 %>%
    group_by(group_no) %>%
    summarize(loc_code = group_process(planting_location_code, group_no),
              method = group_process(planting_method),
              donorsites = group_process(donor_site_nam))
  
  
}





