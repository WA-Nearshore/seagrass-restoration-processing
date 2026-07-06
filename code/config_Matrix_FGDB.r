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
xlpath <- 'source_data/Eelgrass_Restoration_Matrix_snapshot_20260623.xlsx'

# Excel sheets to import and process 
sheet_names <- c("Planting", "lookup table", "Donor Sites", "Monitoring")
new_sheet_names <- c("planting_gps_pts", "plantings_matrix", "donor_sites",
                     "monitoring")
skip_lines <- c(2,0,1,2)

# path to Esri file geodatabase where spatial data is written
pathFGDB <- '2026_update_Pro_project/2026_update_pro_project.gdb'

