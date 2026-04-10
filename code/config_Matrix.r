###############################################################################
#
# Configuration file for R code to extract seagrass restoraiton data from
# the Excel Matrix spreadsheet for processing and ultimately updating the
# feature layers on ArcGIS Online.
#
# April 2026
#
###############################################################################


# path to source Excel file - e.g. a snapshot of the Matrix spreadsheet
xlpath <- 'source_data/Eelgrass_Restoration_Matrix_snapshot_20260407.xlsx'

# Excel sheets to import and process 
sheet_names <- c("Planting GPS Points", "Plantings", "Donor Sites")
new_sheet_names <- c("planting_gps_pts", "plantings", "donor_sites")
skip_lines <- c(2,0,1)