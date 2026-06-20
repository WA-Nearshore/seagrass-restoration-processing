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
#    3. extract projects attributes and create a subprojects table
#    4. extract planting attributes and create a plantings table
#    5.
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
source("code/config_Matrix_FGDB.r")

# Import Seagrass Restoration data from Matrix Excel spreadsheet
# Results in data frames in workspace for each sheet listed in config_Matrix.r
matrix_sheets <- get_sheets(xlpath, sheet_names, skip_lines)
for (isheet in seq(1,length(matrix_sheets))) {
  assign(new_sheet_names[isheet], matrix_sheets[[isheet]])
}

# Initial clean of planting_gps_pts 
# filters to table rows; remove dup col, remove location=NA records (blank records)
p_gps_pts_cln <- clean_planting_gps_pts(planting_gps_pts)

# Create projects table by extracting from planting_gps_pts and adding keys
prj_out_list <- create_prj(p_gps_pts_cln)
sub_projects <- prj_out_list[[1]]
p_gps_pts0 <- prj_out_list[[2]]

# Create plantings table; add plantingID key to p_gps_pts 
plantings_out_list<- create_plantings(p_gps_pts0)
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

# Create planting_locations table
planting_loc_returnObj <- create_locations(p_gps_pts1, pathFGDB)
planting_locations <- planting_loc_returnObj[[1]]
planting_loc_missing_coords <- planting_loc_returnObj[[2]]

# Create Sankey diagram summarizing structure in the data; also identify
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
  pt_plantings2 <- rehab_returnObj[[1]] 
  ln_plantings2 <- rehab_returnObj[[2]] 
  py_plantings2 <- rehab_returnObj[[3]] 
  grid_plantings2 <- rehab_returnObj[[4]] 
  planting_centroids2 <- rehab_returnObj[[5]] 
}

# Create restoration areas layer and add shared key restoration_area_code to
# planting_locations and write both to fgdb
restoration_returnObj <- create_restoration_areas(planting_locations, p_gps_pts1,
                                                  pathFGDB)
restoration_areas <- restoration_returnObj[[1]]
planting_locations <- restoration_returnObj[[2]]


# Create donor site tables


# Create Online layers with same schema (with graph URLs)

# Update Online layers






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
