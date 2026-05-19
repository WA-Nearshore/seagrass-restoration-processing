###############################################################################
#
#  create_planting_key()
#
#  Function to create planting keys within a version of the planting GPS points
#  table passed as an argument.
#
#  This function returns a list containing two data frames:
#    1. p_gps_pts3 - updated version of planting GPS points that now has 
#         a) group_no = integer representing the associated planting
#         b) donor_site_code = codes read in from file for donor_sites and all
#            multi-donor cases coded as 'Mix'.
#         c) plantingID = primary key for plantings table that differentiates
#            replicates
#
#    2. plantings1 - an initial skeleton to develop the plantings table. 
#       Contains planting attributes distilled from planting GPS points - 
#       planting location code, donor site code, planting method. 
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
  # Add grouping variable to p_gps_pts to associate records by planting. 
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
  # Create donor_site_code variable to use in plantingID - uses short code for 
  # donor sites and codes all multi-donor-source cases as "Mix".
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

 
   
  ############################################################################ 
  # Make plantingID - primary key for plantings 
  ############################################################################ 
   
  # summarize on group_no to produce list of plantings - reduce donor_site_code
  plantings0 <- p_gps_pts2 %>%
    mutate(date_char = as.character(planting_date)) %>%
    group_by(group_no) %>%
    summarize(planting_location_code_summ = group_process(planting_location_code),
              date_char_summ = group_process(date_char),
              donor_site_code_summ = group_process(donor_site_code),
              planting_method_summ = group_process(planting_method)) %>%
    ungroup()
  # create initial plantingID key here in planting table, get key counts
  plantings0_key <- plantings0 %>%
    mutate(plantingID_init = str_c(planting_location_code_summ,
                              date_char_summ,
                              planting_method_summ,
                              donor_site_code_summ,
                              sep="__")) %>%
    group_by(plantingID_init) %>%
    mutate(plantingIDcount = n())

  # Where count of an initial plantingID is >1, we will call these replicates
  # and add suffix "__r1", "__r2", "__r3" so that this updated version of 
  # planting key is unique and can be primary key.
  # First get list of the initial plantingID's for replicate cases
  rep_IDs <- unique(plantings0_key[plantings0_key$plantingIDcount>1,"plantingID_init"])
  # plantingID is the final primary key for plantings table
  plantings1 <- plantings0_key %>%
      group_by(plantingID_init) %>%
      mutate(
        plantingID = if_else(
          plantingIDcount > 1,
          paste0(plantingID_init, "_r", cumsum(plantingIDcount > 1)),
          plantingID_init 
        )
      ) %>%
      ungroup() %>%
      select(-plantingID_init, -date_char_summ, -plantingIDcount)
  
  
  ############################################################################ 
  # Join planting table fields onto GPS points with group_no as shared key 
  ############################################################################ 
  p_gps_pts3 <- p_gps_pts2 %>%
    left_join(plantings1, by="group_no")
  
  
  # return a list containing (a) updated planting GPS points, (b) start to
  # plantings table with primary key plantingID
  return_obj <- list(p_gps_pts3, plantings1) 
}




