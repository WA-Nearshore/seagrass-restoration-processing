###############################################################################
#
# Configuration file for R seagrass restoration tools.
#
# August 2026
#
###############################################################################



################################################################
# General or shared config parameters across tools
################################################################

# Path to Esri file geodatabase where spatial data is written.
# This is relative path relative to R working directory.
pathFGDB <- '2026_update_Pro_project/2026_update_pro_project.gdb'



#################################################################
#  Config parameters used to import data from Matrix spreadsheet 
#################################################################

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

# set system environmental variables to avoid GDAL polygon organization when
# reading the baselayer (land polygons). This avoids warning for complex poly.
Sys.setenv(OGR_ORGANIZE_POLYGONS = "SKIP")