###############################################################################
#  get_sheets()
#
#  This function retrieves the two sheets from the user-specified Excel
#  spreadsheet that are related to seagrass restoration plantings.
#
#  The intent is that this function will be needed during the transition from
#  the Excel Matrix to a new data structure and flow.
#
#  April 2026
#
###############################################################################

library(readxl)


get_sheets <- function(source_xl, sheet_names, skip_lines) {
 
  matrix_sheets <- mapply(function(x,y,z) {read_excel(x, sheet=y, skip=z)},
                          source_xl, sheet_names, skip_lines)
  return(matrix_sheets) 
}
