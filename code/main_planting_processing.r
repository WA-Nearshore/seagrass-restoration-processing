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
source("code/functions/get_sheets.r")
source("code/functions/create_prj.r")
source("code/functions/clean_planting_gps_pts.r")
source("code/functions/create_plantings.r")
source("code/functions/create_locations.r")
source("code/functions/create_lyrs.r")
source("code/functions/create_sankey.r")
source("code/functions/rehab_plantings.r")
source("code/functions/create_restoration_areas.r")
source("code/functions/create_donor_tbls.r")
source("code/functions/create_monitoring.r")
source("code/config_Matrix_FGDB.r")



###############################################################################
# get external data inputs
###############################################################################

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

# Initial clean of planting_gps_pts 
# filters to table rows; remove dup col, remove location=NA records (blank records)
p_gps_pts_cln <- clean_planting_gps_pts(planting_gps_pts)

# Create projects table by extracting from planting_gps_pts and adding keys
prj_out_list <- create_prj(p_gps_pts_cln)
sub_projects <- prj_out_list[[1]]
p_gps_pts0 <- prj_out_list[[2]]

# Create plantings table (nonspatial); add plantingID key to p_gps_pts 
plantings_out_list<- create_plantings(p_gps_pts0, name_lookup)
p_gps_pts1 <- plantings_out_list[[1]]
plantings <- plantings_out_list[[2]]

# Create planting spatial layers (pt,ln,poly,grid,centroids) & write to fgdb.
# Returned list items are all sf spatial objects.
lyrsObj <- create_lyrs(p_gps_pts1, plantings, pathFGDB)
pt_plantings <- lyrsObj[[1]]
ln_plantings <- lyrsObj[[2]]
py_plantings <- lyrsObj[[3]]
grid_plantings <- lyrsObj[[4]]
planting_centroids <- lyrsObj[[5]]

# Create planting_locations point sf object and separate table of locations
# missing coordinates.
planting_loc_returnObj <- create_locations(p_gps_pts1, pathFGDB)
planting_locations <- planting_loc_returnObj[[1]]
planting_loc_missing_coords <- planting_loc_returnObj[[2]]

# Create Sankey diagram summarizing structure in the data. This inventorying
# is necessary to identify
# plantingIDs associated with cases w/no planting coords, but planting is
# associated with a planting_location_code with known coordinates. Using this
# info these cases can be 'rehabilitated' and added to spatial layers.
sankey_returnObj <- create_sankey(p_gps_pts1, plantings, planting_locations)
p_sankey <- sankey_returnObj[[1]]
rehab_plantingIDs <- sankey_returnObj[[2]]


# Add the rehab plantingIDs to the appropriate spatial layers. Initial June
# 2026 dev only handles point and grid rehab records.
if (dim(rehab_plantingIDs)[1] > 0) {
  rehab_returnObj <- rehab_plantings(rehab_plantingIDs, pt_plantings, ln_plantings,
                                    py_plantings, grid_plantings,
                                    planting_centroids, planting_locations)
  pt_plantings_rehab <- rehab_returnObj[[1]] 
  ln_plantings_rehab <- rehab_returnObj[[2]] 
  py_plantings_rehab <- rehab_returnObj[[3]] 
  grid_plantings_rehab <- rehab_returnObj[[4]] 
  planting_centroids_rehab <- rehab_returnObj[[5]] 
}

# Create restoration areas layer and add shared key restoration_area_code to
# planting_locations. Both are sf objects.
# This function reads external data - the WA state baselayer from fgdb.
restoration_returnObj <- create_restoration_areas(planting_locations, p_gps_pts1,
                                                  baselayer) 
restoration_areas <- restoration_returnObj[[1]]
planting_locations <- restoration_returnObj[[2]]


# Create donor site tables; uses donor site codes read earlier from csv
donorObj <- create_donor_tbls(p_gps_pts1, donor_sites, donor_site_codes)
donor_site_usage <- donorObj[[1]]
donor_sites <- donorObj[[2]]
donor_collection_pts <- donorObj[[3]]


# Create monitoring data table. Also returns monitoring records with no matching
# planting.
monitorObj <- create_monitoring(monitoring, plantings, p_gps_pts1)
monitor_tbl <- monitorObj[[1]]
mon_tbl_noMatch <- monitorObj[[2]]
plantings_noMonData <- monitorObj[[3]]



###############################################################################
#  Write relational database tables and layers to fgdb.
#  Write diagnostic tables (e.g. cases with no matching) to csv file.
#  Functions returns 0 on error; 1 if successful.
###############################################################################
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



# Create Online layers with same schema (with graph URLs)



# Update Online layers






rm(isheet,get_sheets,matrix_sheets,new_sheet_names,skip_lines,sheet_names)
rm(xlpath)
# rm(planting_gps_pts)
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

