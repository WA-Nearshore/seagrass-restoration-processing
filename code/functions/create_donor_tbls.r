###############################################################################
#
# create_donor_tbls()
#
# Create 3 objects related to donor sites:
#   1. donor_site_usage table
#   2. donor_sites point layer 
#   3. donor_collection_pts point layer
#
# Input data arguments are the donor_sites sheet and the Plantings sheet 
# (p_gps_pts1) from the Matrix snapshot as an argument. Input data includes
# a table of donor site codes read in from csv in this function.
#
# June 2026
#
###############################################################################

library(tidyverse)
library(sf)

create_donor_tbls <- function(p_gps_pts1, donor_sites) {
 
  # read table of donor site codes
  donor_site_codes <- read.csv("source_data/donor_site_codes.csv",
                               stringsAsFactors=FALSE)

  
  ########################################################################
  # create donor usage table
  ########################################################################
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
  
  # isolate simple 1-to-1 planting-donor cases and make records for usage table
  simple_usage_recs <- planting_summ %>%
    filter(donor_site_code_summ2 != "Mix") %>%
    select(plantingID, donor_site_code_summ2) %>%
    rename(donor_site_code = donor_site_code_summ2)
  
  # isolate 2 classes of Mix cases - coded as 'Mixed' in field and coded as a
  # list of donor site names, e.g. "Thompson Cove, Dupont Wharf".
  mix_donor_cases <- planting_summ %>%
    filter(donor_site_code_summ2 == "Mix")
  field_mix_cases <- mix_donor_cases %>% filter(donor_site_name_summ == "Mixed")
  field_list_cases <- mix_donor_cases %>% filter(donor_site_name_summ != "Mixed")
  
  # process field mix cases to make donor usage records
  # First make empty data frame for appending planting_donor_usage records
  field_mix_usage_recs <- simple_usage_recs %>% slice(0)
  for (irec in 1:nrow(field_mix_cases)) {
    shared_donor_planting_recs <- planting_summ %>%
      filter(planting_date == field_mix_cases$planting_date[irec],
             planting_location_code == field_mix_cases$planting_location_code[irec])
    donor_list <- shared_donor_planting_recs %>%
      filter(donor_site_name_summ != "Mixed") %>%
      pull(donor_site_code_summ2)
    irec_usage_tbl_recs <- data.frame(
      plantingID = rep(field_mix_cases$plantingID[irec], times=length(donor_list)),
      donor_site_code = donor_list
    )
    field_mix_usage_recs <- rbind(field_mix_usage_recs, irec_usage_tbl_recs)
  }
  
  # process field list cases to make donor usage records
  field_list_usage_recs <- simple_usage_recs %>% slice(0)  
  for (irec in 1:nrow(field_list_cases)) {
    
    if (str_detect(field_list_cases$donor_site_name_summ[irec], " and ")) {
      # process 'and' delimited list
      donor_name_vect <- str_split_1(field_list_cases$donor_site_name_summ[irec], " and ")
      irec_usage_tbl_recs <- data.frame(
        plantingID = c(rep(field_list_cases$plantingID[irec], times=length(donor_name_vect))),
        donor_site_code = donor_name_vect
      )
      field_list_usage_recs <- rbind(field_list_usage_recs, irec_usage_tbl_recs)
      
    } else if (str_detect(field_list_cases$donor_site_name_summ[irec],"/")) {
      # process slash delimited list 
      donor_name_vect <- str_split_1(field_list_cases$donor_site_name_summ[irec], "/")
      irec_usage_tbl_recs <- data.frame(
        plantingID = c(rep(field_list_cases$plantingID[irec], times=length(donor_name_vect))),
        donor_site_code = donor_name_vect
      )
      field_list_usage_recs <- rbind(field_list_usage_recs, irec_usage_tbl_recs)
      
    } else if (str_detect(field_list_cases$donor_site_name_summ[irec], ",\\s*")) {
      # process comma delimited list 
      donor_name_vect <- str_split_1(field_list_cases$donor_site_name_summ[irec], ", ")
      irec_usage_tbl_recs <- data.frame(
        plantingID = c(rep(field_list_cases$plantingID[irec], times=length(donor_name_vect))),
        donor_site_code = donor_name_vect
      )
      field_list_usage_recs <- rbind(field_list_usage_recs, irec_usage_tbl_recs)
      
    } else {
      print("Error with processing donor field list cases.")
    }
  }  # close for loop through field list cases

  # combine records to make donor usage table
  donor_site_usage <- rbind(simple_usage_recs, field_mix_usage_recs, 
                       field_list_usage_recs)
  
  
  ########################################################################
  # create donor site point feature class
  ########################################################################
  donor_sites_cnt <- donor_sites %>%
    group_by(site_name) %>%
    mutate(donor_site_coord_count = n()) %>%
    ungroup() %>%
    rename(donor_site_name = site_name) %>%
    left_join(donor_site_codes, by="donor_site_name") %>%
    select(-Location, -data_type, -alt_donor_site_name)
  
  # convert to sf object and project to State Plane WA South Harn
  donor_site_pts_geo <- st_as_sf(donor_sites_cnt, coords = c("long","lat"),
                                 crs=4326, remove=FALSE)
  donor_site_pts_StPl <- st_transform(donor_site_pts_geo, crs=2927) 
  
  # isolate donor sites with multiple sets of coords, get centroid
  donor_site_multiPt_centroids <- donor_site_pts_StPl %>% 
          filter(donor_site_coord_count > 1) %>%
          group_by(donor_site_name) %>%
          summarize(geometry = st_union(geometry)) %>%
          st_centroid()
  # process to final set of cols
  donor_site_multiPt_centroids_jn <- donor_site_multiPt_centroids %>%
    left_join(donor_sites_cnt, by="donor_site_name", multiple="first") %>%
    select(-datum, -donor_site_coord_count)
  
  # isolate donor sites with a single set of coords; process to final set of cols 
  donor_site_singlePts <- donor_site_pts_StPl %>%
    filter(donor_site_coord_count ==1) %>%
    select(-datum, -donor_site_coord_count)
 
  
  # combine single and multiple coord cases to make donor site point layer 
  donor_site_pt_layer <- rbind(donor_site_singlePts, 
                               donor_site_multiPt_centroids_jn)
  
  
  ########################################################################
  # create donor_collection_pts point feature class 
  ########################################################################
  donor_collection_pts <- donor_site_pts_StPl %>%
       filter(donor_site_coord_count > 1) %>%
       select(donor_site_code, lat, long, notes)
  
  
  
  
  ########################################################################
  # write sf layers to fgdb 
  ########################################################################
 # donor_collection_pts, donor_site_pt_layer, donor_site_usage (table??) 
 st_write(donor_site_usage, dsn=pathFGDB, layer="donor_site_usage", 
           driver="OpenFileGDB", delete_layer=TRUE)
 st_write(donor_site_pt_layer, dsn=pathFGDB, layer="donor_sites", 
           driver="OpenFileGDB", delete_layer=TRUE)
 st_write(donor_collection_pts, dsn=pathFGDB, layer="donor_collection_pts", 
           driver="OpenFileGDB", delete_layer=TRUE)
  
   
  returnObj <- list(donor_site_usage, donor_site_pt_layer,
                    donor_collection_pts) 
  return(returnObj) 
}


