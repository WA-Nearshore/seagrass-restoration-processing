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
source("code/config_Matrix.r")


sheets <- get_sheets(xlpath, matrix_sheets)

