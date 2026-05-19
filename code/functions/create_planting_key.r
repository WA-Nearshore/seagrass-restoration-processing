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

# define function to use in summarization - reduces vector to single value
group_process <- function(indata,group_no) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    print(sprintf("Error: group %d is all NA: %d  %d",group_no[1],n0,n1))
    return(NA)
  }
  else if (n1 == 1) {
   return(indata_cln[1])
  } else if (n1 > 1) {
   return("multiple") 
  }
}



create_planting_key <- function(p_gps_pts) {
 
  ############################################################################ 
  # Add grouping variable to associate records by planting. 
  ############################################################################ 
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
  
 
  ############################################################################ 
  # Create donor site variable to use in plantingID 
  ############################################################################ 
  
  # first read donor_site_codes from file and join onto p_gps_pts. The result
  # is messy with NA occurrences where multipoint geometries have NA for donor site.
  donor_site_codes <- read.csv("source_data/donor_site_codes.csv",
                               stringsAsFactors=FALSE)
  p_gps_pts_jn <- p_gps_pts1 %>%
    left_join(donor_site_codes, by="donor_site_name")
  
  
  # Address mixed donor site cases where donor_site_name == "Mixed" or has 
  # multiple donor_sites using 1 of 3 separators
  p_gps_pts2 <- p_gps_pts_jn %>%
    mutate(donor_site_code = ifelse(donor_site_name == "Mixed" |
                               str_detect(donor_site_name,"/") |
                               str_detect(donor_site_name,",") |
                               str_detect(donor_site_name," and "),
                               "Mix", donor_site_code))
 
  # summarize on group_no to produce list of plantings - reduce donor_site_code
  plantings <- p_gps_pts2 %>%
    mutate(date_char = as.character(planting_date)) %>%
    group_by(group_no) %>%
    summarize(planting_location_code_summ = group_process(planting_location_code),
              date_char_summ = group_process(date_char),
              donor_site_code_summ = group_process(donor_site_code),
              planting_method_summ = group_process(planting_method))
  # create plantingID key here in planting table, get key counts
  plantings_key <- plantings %>%
    mutate(plantingID = str_c(planting_location_code_summ,
                              date_char_summ,
                              planting_method_summ,
                              donor_site_code_summ,
                              sep="__")) %>%
    group_by(plantingID) %>%
    mutate(plantingIDcount = n())
            
  # join planting donor_site_code back onto p_gps_pts
  p_gps_pts2 <- p_gps_pts2 %>%
    left_join(plantings, by="group_no")
  
   
  ############################################################################ 
  # Make plantingID - key for plantings 
  #
  #  NEED TO ADDRESS MULTI PLANTINGIDCOUNT CASES - REPLICATES. TWO SETS
  #
  ############################################################################ 
  p_gps_pts_key <- p_gps_pts2 %>% 
    mutate(plantingID = str_c(planting_location_code,
                              as.character(planting_date),
                              planting_method_summ,
                              donor_site_code_summ,
                              sep="_"))
  
  # check for multiple
  
}





