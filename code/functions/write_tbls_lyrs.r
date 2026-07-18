###############################################################################
#
#  write_tbls_lyrs()
#
#  Writes out the following objects passed to the function as arguments:
#   1. relational database tables are written to Esri file geodatabase
#   2. relational database spatial layers written to same file geodatabase
#   3. diagnositc tables, e.g. planting locations with no GPS coords, are
#      written to csv files.
# 
#  The file geodatabase used is specified in <HOME>/code/config_Matrix_FGDB.r 
#  and that target file geodatabase must already exist.
#  The csv files are written to the pre-existing folder <HOME>/output_tables 
#  using hard coded file names.
#
#  July 2026
#
###############################################################################

library(tidyverse)
library(sf)


write_tbls_lyrs <- function(sub_projects, plantings, 
                    planting_locations, planting_loc_missing_coords, 
                    rehab_plantingIDs,
                    pt_plantings_rehab, ln_plantings_rehab, py_plantings_rehab,
                    grid_plantings_rehab, planting_centroids_rehab,
                    restoration_areas,
                    donor_site_usage, donor_sites, donor_collection_pts,
                    monitor_tbl, mon_tbl_noMatch, plantings_noMonData) {

# write plantings table to fgdb
st_write(plantings, dsn=pathFGDB, layer="plantings", 
         driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)

# write sub-projects table to fgdb
st_write(sub_projects, dsn=pathFGDB, layer="sub_projects", 
         driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  
# write rehab_plantingIDs to csv
write.csv(rehab_plantingIDs, file="output_tables/rehab_plantings.csv")

# write monitoring table to fgdb and diagnostic tables to csv
st_write(monitor_tbl, dsn=pathFGDB, layer="monitoring",
         drive="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
write.csv(mon_tbl_noMatch, file="output_tables/mon_tbl_noMatch.csv")
write.csv(plantings_noMonData, file="output_tables/plantings_noMonData.csv")

# from create_lys
  # write plantings (pt, ln & py) spatial features to file geodatabase
  st_write(pt_plantings_rehab, dsn=pathFGDB, layer="pt_plantings", 
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  st_write(ln_plantings_rehab, dsn=pathFGDB, layer="ln_plantings", 
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  st_write(py_plantings_rehab, dsn=pathFGDB, layer="py_plantings", 
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  st_write(grid_plantings_rehab, dsn=pathFGDB, layer="grid_plantings",
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  st_write(planting_centroids_rehab, dsn=pathFGDB, layer="planting_centroids",
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  
# from create_locations
  write.csv(planting_loc_missing_coords, 
            file="output_tables/planting_loc_no_coords.csv")
  
# from create_restoration_areas
 st_write(restoration_areas, dsn=pathFGDB, layer="restoration_areas",
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
 st_write(planting_locations, dsn=pathFGDB, layer="planting_locations",
          driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
  
# from create_donor_tbls
 # donor_collection_pts, donor_site_pt_layer, donor_site_usage (table??) 
 st_write(donor_site_usage, dsn=pathFGDB, layer="donor_site_usage", 
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
 st_write(donor_sites, dsn=pathFGDB, layer="donor_sites", 
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
 st_write(donor_collection_pts, dsn=pathFGDB, layer="donor_collection_pts", 
           driver="OpenFileGDB", delete_layer=TRUE, quiet=TRUE)
 
 return(1)
} 
 
  