###############################################################################
#
# create_donor_tbls()
#
# Create planting_donor_usage table and donor_sites point layer given
# the donor_sites sheet from the Matrix snapshot as an argument and a table 
# of donor site codes read in from csv in this function.
#
# June 2026
#
###############################################################################

library(tidyverse)

create_donor_tbls <- function(p_gps_pts1, donor_sites) {
 
  # read table of donor site codes and prep for relating to donor site tbl
  # from matrix snapshot
  donor_site_codes <- read.csv("source_data/donor_site_codes.csv",
                               stringsAsFactors=FALSE)

  # summarize GPS points down to plantings
  p_gps_pts1_sel <- p_gps_pts1 %>%
    select(planting_location_code, planting_date, donor_site_name, alt_donor_site_name,
           donor_site_code_summ, plantingID)
  planting_summ <- p_gps_pts1_sel %>%
    group_by(plantingID) %>%
    summarize(planting_location_code = group_process_char(planting_location_code),
              planting_date = group_process_date(planting_date),
              donor_site_name_summ = group_process_char(donor_site_name),
              donor_site_code_summ2 = group_process_char(donor_site_code_summ))
  
  # isolate simple 1-to-1 planting-donor cases and start usage table
  simple_donor_cases <- planting_summ %>%
    filter(donor_site_code_summ2 != "Mix") %>%
    select(plantingID, donor_site_code_summ2) %>%
    rename(donor_site_code = donor_site_code_summ2)
  
  # isolate 2 classes of Mix cases - coded as 'Mixed' in field and combined
  # list of donor site names, e.g. Thompson Cove, Dupont Wharf.
  mix_donor_cases <- planting_summ %>%
    filter(donor_site_code_summ2 == "Mix")
  field_mix_cases <- mix_donor_cases %>% filter(donor_site_name_summ == "Mixed")
  field_list_cases <- mix_donor_cases %>% filter(donor_site_name_summ != "Mixed")
  
  # process field mix cases to initial donor usage records
  for (irec in 1:nrow(field_mix_cases)) {
    shared_donor_recs <- planting_summ %>%
      filter(planting_date == field_mix_cases$planting_date[irec],
             planting_location_code == field_mix_cases$planting_location_code[irec])
    donor_list <- shared_donor_recs %>%
      filter(donor_site_name_summ != "Mixed") %>%
      pull(donor_site_code_summ2)
    
    
    
    
    
    
    
  }
  
      

  
  
   
  return(1) 
}