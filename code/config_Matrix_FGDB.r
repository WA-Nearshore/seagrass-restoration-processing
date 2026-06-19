###############################################################################
#
# Configuration file for R code to extract seagrass restoration data from
# the Excel Matrix spreadsheet snapshot, process the data into a more
# normalized set of tables and then right spatial data to file geodatabase.
#
# April 2026
#
###############################################################################


# path to source Excel file - e.g. a snapshot of the Matrix spreadsheet
xlpath <- 'source_data/Eelgrass_Restoration_Matrix_snapshot_20260518.xlsx'

# Excel sheets to import and process 
sheet_names <- c("Planting GPS Points", "Plantings", "Donor Sites")
new_sheet_names <- c("planting_gps_pts", "plantings_matrix", "donor_sites")
skip_lines <- c(2,0,1)

# path to Esri file geodatabase where spatial data is written
pathFGDB <- '2026_update_Pro_project/2026_update_pro_project.gdb'

