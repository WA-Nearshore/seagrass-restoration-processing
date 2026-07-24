#########1#########2#########3#########4#########5#########6#########7#########8
#
#  Main program to process the two planting tables in the Matrix spreadsheet
#  containing data from the seagrass restoration program.
#
#  The two tables to be processed:  planting_GPS_points and plantings
#
#  Elements of this program:
#    1. read sources tables from Matrix Excel spreadsheet.
#    2. conduct basic cleanup and QA
#    3. extract projects attributes, create a subprojects table, add subproject
#       key to p_gps_pts
#    4. extract planting attributes, create a plantings table, add plantingID
#       as key to p_gps_pts
#    5. create 5 spatial layers: point, line, polygon
#       and grid plantings with their respective planting subsets, and a
#       planting centroids layers that includes all plantings.
#    6. create a planting locations point layer
#    7. create a Sankey diagram visualizing data structure and identify 'rehab'
#       cases where planting has no GPS coords, but other plantings at same
#       location do.
#    8. create restoration areas polygon layer and write to fgdb.
#    9. create donor usage table, and donor site and donor collection point
#       point layers and write to fgdb.
#   10. create monitoring data table
#
#
#  Required inputs in <project-folder>/source_data
#  These inputs are read below in this code file.
#    1. Seagrass restoration 'Matrix' Excel spreadsheet (file details configured
#       in code/config_Matrix_FGDB.r). 
#    2. donor_site_codes.csv:  Associates short codes with donor site names.
#    3. gps_name_to_planting_name_tbl.csv:  a lookup table for gps-point_names
#       to planting names for plantings with multiple gps points each with
#       unique gps-point-names.
#
#
#  May 2026
#
###############################################################################

library(tidyverse)
source("code/config_Matrix_FGDB.r")
source("code/functions/create_database.r")
source("code/functions/get_sheets.r")
source("code/functions/write_tbls_lyrs.r")



###############################################################################
# get external data inputs
###############################################################################
print("Reading...")

# Import Seagrass Restoration data from Matrix Excel spreadsheet
# Results in data frames in workspace for each sheet listed in config_Matrix.r
matrix_sheets <- get_sheets(xlpath, sheet_names, skip_lines)
for (isheet in seq(1,length(matrix_sheets))) {
  assign(new_sheet_names[isheet], matrix_sheets[[isheet]])
}

# read table of donor site codes
donor_site_codes <- read.csv("source_data/donor_site_codes.csv",
                               stringsAsFactors=FALSE)

# read lookup table to convert gps-pt-names to planting-names for line and
# polygon plantings with multiple, unique gps-pt-names
name_lookup_in <- read.csv("source_data/gps_name_to_planting_name_tbl.csv",
                           stringsAsFactors=FALSE)
name_lookup <- name_lookup_in %>% select(site_name, planting_name.1) %>%
  rename(planting_name = planting_name.1)

# read in 'baselayer' from FGDB with land polygons; project to StPl Wash S
baselayer <- st_read(dsn = pathFGDB, layer = "baselayer_Clip", quiet = TRUE) %>%
             st_transform(crs=2927)



###############################################################################
#  create relational database tables and spatial layers 
###############################################################################
print("Creating tables and layers...")
returnOBJdb <- create_database(planting_gps_pts, name_lookup, donor_site_codes,
                               donor_sites, baselayer, pathFGDB)
list2env(returnObj, envir = .GlobalEnv)



###############################################################################
#  Write relational database tables and layers to fgdb.
#  Write diagnostic tables (e.g. cases with no matching) to csv file.
#  Write function returns 0 on error; 1 if successful.
###############################################################################
print("Writing...")

if (write_tbls_lyrs(sub_projects, plantings, planting_locations,
                    planting_loc_missing_coords, rehab_plantingIDs,
                    pt_plantings_rehab, ln_plantings_rehab, py_plantings_rehab,
                    grid_plantings_rehab, planting_centroids_rehab,
                    restoration_areas,
                    donor_site_usage, donor_sites, donor_collection_pts,
                    monitor_tbl, mon_tbl_noMatch, plantings_noMonData) == 0) {
   print(" ")
   print("ERROR in writing output tables and layers.")
   print(" ")     
}



###############################################################################
#  create monitoring graphs 
###############################################################################
mon_graphs <- create_monitoring_graphs(monitor_tbl)





rm(isheet,get_sheets,matrix_sheets,new_sheet_names,skip_lines,sheet_names)
rm(xlpath)
rm(planting_gps_pts)
rm(clean_planting_gps_pts, create_prj, distill_vals)
rm(p_gps_pts_cln, prj_out_list, prj_codes)
rm(plantings_out_list, create_planting_key, create_plantings)
rm(notes_process)
rm(create_lyrs, group_process_char, group_process_date, group_process_numeric)
rm(lyrsObj)
rm(p_gps_pts0, pathFGDB)
rm(create_locations, create_sankey)
rm(plantings_matrix)
rm(create_restoration_areas)
rm(sankey_returnObj, rehab_returnObj)
rm(create_donor_tbls, create_monitoring)
rm(donorObj, group_process_planting_name)
rm(monitorObj, name_lookup_in, name_lookup, restoration_returnObj)
rm(donor_site_codes, donor_sites, monitoring)
rm(planting_loc_returnObj)
rm(grid_plantings, ln_plantings, planting_centroids, pt_plantings)
rm(py_plantings, rehab_plantingIDs)

