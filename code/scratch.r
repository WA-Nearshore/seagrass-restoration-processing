# scratch


  # separate records by geometry type [ALL VALUES VALID ??]
  pt_recs <- p_gps_pts %>% filter(planting_geometry == "point")
  ln_recs <- p_gps_pts %>% filter(planting_geometry == "line")
  py_recs <- p_gps_pts %>% filter(planting_geometry == "polygon")
  
  # filter for NA planting geometry and write site names to console
  # these records not included in above geometries, essentially dropped
  na_recs <- p_gps_pts %>% filter(is.na(planting_geometry))
  cat("\n")
  print(sprintf("%d records from planting_GPS_pts dropped due to NA planting geometry.",
                dim(na_recs)[1]))
  print(na_recs$site_name)
  cat("\n")
  
  # Convert data frames with lat/lon columns into spatial sf objects
  # Filter out plantings with records missing lat/lon
  # First convert to point features
  # Second assemble points into line and polygon features