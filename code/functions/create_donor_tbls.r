###############################################################################
#
# create_donor_tbls()
#
# Create planting_donor_assoc table and donor_sites point layer given
# the donor_sites sheet from the Matrix snapshot as an argument and a table 
# of donor site codes read in from csv in this function.
#
# June 2026
#
###############################################################################

library(tidyverse)

create_donor_codes <- function(donor_sites) {
 
  # read table of donor site codes and prep for relating to donor site tbl
  # from matrix snapshot
  donor_site_codes <- read.csv("source_data/donor_site_codes.csv",
                               stringsAsFactors=FALSE)
    
 
  
  
   
}