






  ##########################################################################
  # check if plantings with no coordinates were at known planting locations
  ##########################################################################
  # combine all spatial plantingIDs (known locations)
  spatialIDs <- data.frame(plantingID = c(pt_spatial_PT_StPl$plantingID,
                  ln_plantings$plantingID,
                  py_plantings$plantingID,
                  gr_spatial_PT_StPl$plantingID))
  # join planting_location_codes from plantings_table
  plantings_jn_tbl <- plantings_table %>% select(plantingID, planting_location_code)
  spatialIDs_jn <- spatialIDs %>% left_join(plantings_jn_tbl, by="plantingID")
  # get list of unique planting_location_codes for known locations
  known_plt_loc_codes <- unique(spatialIDs_jn$planting_location_code)
  
  # combine all plantingIDs for plantings without GPS coords 
  no_coord_plantingIDs <- data.frame(
     plantingID = c(pt_nonspatial_planting_recs$plantingID,
                    grid_nonspatial_planting_recs$plantingID),
     planting_location_code = c(pt_nonspatial_planting_recs$planting_location_code_summ,
                                grid_nonspatial_planting_recs$planting_location_code_summ)
  )
  # add variable to indicate whether no-coord planting is at known plt loc code
  no_coord_plantingIDs <- no_coord_plantingIDs %>%
    mutate(known_plc = planting_location_code %in% known_plt_loc_codes)
                              
  
  # need to isolate no-coord plantings at pcl with known location
  # construct planting_locations point layer
  # duplicate point for plc and add to plantings spatial layer
  
  
  # create centroids spatial layer
  
  