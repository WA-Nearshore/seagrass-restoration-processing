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
#    4. publish the
#
#
#  April 2026
#
###############################################################################

library(tidyverse)
source("code/functions/get_sheets.r")
source("code/functions/create_prj.r")
source("code/functions/clean_planting_gps_pts.r")
source("code/functions/create_lyrs.r")
source("code/config_Matrix.r")

# Import Seagrass Restoration data from Matrix Excel spreadsheet
# Results in data frames in workspace for each sheet listed in config_Matrix.r
matrix_sheets <- get_sheets(xlpath, sheet_names, skip_lines)
for (isheet in seq(1,length(matrix_sheets))) {
  assign(new_sheet_names[isheet], matrix_sheets[[isheet]])
}

# Initial clean of planting_gps_pts (filters to table rows; remove dup col)
p_gps_pts_cln <- clean_planting_gps_pts(planting_gps_pts)

# Create projects table by extracting from planting_gps_pts and using keys
prj_out_list <- create_prj(p_gps_pts_cln)
sub_projects <- prj_out_list[[1]]
p_gps_pts <- prj_out_list[[2]]

# Convert planting gps point records into spatial layers for each geometry.
# Function takes p_gps_pts and returns pt,ln,py layers and planting attributes
make_geom_list <- create_lyrs(p_gps_pts)

# Create planting_centroids layer

# Create Online layers with same schema (with graph URLs)

# Update Online layers






rm(isheet,get_sheets,matrix_sheets,new_sheet_names,skip_lines,sheet_names)
rm(xlpath)
rm(planting_gps_pts)
rm(clean_planting_gps_pts, create_prj, distill_vals)
rm(make_geom_list)
rm(create_lyrs)
rm(p_gps_pts_cln, prj_out_list, prj_codes)

