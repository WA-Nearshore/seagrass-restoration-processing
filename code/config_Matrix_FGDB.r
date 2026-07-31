###############################################################################
#
# Configuration file for R code to extract seagrass restoration data from
# the Excel Matrix spreadsheet snapshot, and write processed data to a
# file geodatabase.
#
# April 2026
#
###############################################################################


# path to source Excel file - e.g. a snapshot of the Matrix spreadsheet
xlpath <- 'source_data/Eelgrass_Restoration_Matrix_snapshot_20260623.xlsx'

# Excel sheets to import and process; must match Matrix spreadsheet
sheet_names <- c("Planting", "lookup table", "Donor Sites", "Monitoring")

# New names for the tables imported from the Matrix, same order as sheet_names.
# These names are hard coded within code files so any changes here trigger other
# required edits in code.
new_sheet_names <- c("planting_gps_pts", "plantings_matrix", "donor_sites",
                     "monitoring")
# Numbers of header rows at top of sheet to skip on import
skip_lines <- c(2,0,1,2)

# path to Esri file geodatabase where spatial data is written
pathFGDB <- '2026_update_Pro_project/2026_update_pro_project.gdb'

# set system environmental variables to avoid GDAL polygon organization when
# reading the baselayer (land polygons). This avoids warning for complex poly.
Sys.setenv(OGR_ORGANIZE_POLYGONS = "SKIP")