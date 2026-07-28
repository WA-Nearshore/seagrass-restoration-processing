###############################################################################
# read_inputs()
#
# Reads external inputs required by script (main_matrix_to_db.r) that 
# reads and processes seagrass restoration data from the source Excel 
# spreadsheet, the 'matrix'.
#
# July 2026
#
###############################################################################

library(tidyverse)
library(sf)
source("code/functions/get_sheets.r")

read_inputs <- function(xlpath, sheet_names, skip_lines, new_sheet_names, 
                        pathFGDB) {


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

  # pack return list and return
  returnObj <- list(planting_gps_pts = planting_gps_pts,
                    plantings_matrix = plantings_matrix,
                    donor_sites = donor_sites,
                    monitoring = monitoring)
  return(returnObj)
}