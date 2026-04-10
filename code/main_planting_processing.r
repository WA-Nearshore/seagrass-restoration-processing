#########1#########2#########3#########4#########5#########6#########7#########8
#
#  Main program to process the two planting tables for the seagrass restoration
#  program.
#
#  The two tables to be processed:  planting_GPS_points and plantings
#
#  Elements of this program:
#    1. read sources tables from Excel spreadsheet.
#    2. conduct basic QA
#    3.  
#    4. publish the
#
#
#  March 2026
#
###############################################################################

library(tidyverse)
source("code/functions/get_sheets.r")
source("code/functions/create_prj.r")
source("code/functions/clean_planting_gps_pts.r")
source("code/config_Matrix.r")

# import Seagrass Restoration data from Matrix Excel spreadsheet
matrix_sheets <- get_sheets(xlpath, sheet_names, skip_lines)
for (isheet in seq(1,length(matrix_sheets))) {
  assign(new_sheet_names[isheet], matrix_sheets[[isheet]])
}

# initial clean of planting_gps_pts 
p_gps_pts_cln <- clean_planting_gps_pts(planting_gps_pts)


# Create projects table by extracting from planting_gps_pts and using keys
prj_out_list <- create_prj(p_gps_pts_cln)






rm(isheet,get_sheets,matrix_sheets,new_sheet_names,skip_lines,sheet_names)
rm(xlpath)
rm(planting_gps_pts)
