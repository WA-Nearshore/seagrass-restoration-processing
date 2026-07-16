


# from create_lys
  # write pt and ln planting spatial features to file geodatabase
  st_write(pt_spatial_PT_StPl_sel, dsn=pathFGDB, layer="pt_plantings", 
           driver="OpenFileGDB", delete_layer=TRUE)
  st_write(ln_plantings, dsn=pathFGDB, layer="ln_plantings", 
           driver="OpenFileGDB", delete_layer=TRUE)
  st_write(py_plantings, dsn=pathFGDB, layer="py_plantings", 
           driver="OpenFileGDB", delete_layer=TRUE)
  st_write(gr_spatial_PT_StPl_sel, dsn=pathFGDB, layer="grid_plantings",
           driver="OpenFileGDB", delete_layer=TRUE)
  st_write(planting_centroids, dsn=pathFGDB, layer="planting_centroids",
           driver="OpenFileGDB", delete_layer=TRUE)
  
  
  
# from create_locations
  write.csv(planting_loc_missing_coords, 
            file="output_tables/planting_loc_no_coords.csv")
  
  # write planting locatoins point layer to fgdb
  st_write(planting_locations, dsn=pathFGDB, layer="planting_locations",
           driver="OpenFileGDB", delete_layer=TRUE)
  
# from create_restoration_areas
 # write out to project file geodatabase
 st_write(restoration_areas, dsn=pathFGDB, layer="restoration_areas",
           driver="OpenFileGDB", delete_layer=TRUE)
 st_write(planting_locations, dsn=pathFGDB, layer="planting_locations",
          driver="OpenFileGDB", delete_layer=TRUE)
  
  
# from create_donor_tbls
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
 

 
 
  