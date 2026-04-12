###############################################################################
#
# create_lyrs()
#
# Create separate spatial layers for point, line and polygon plantings from the
# planting_gps_pts table.
#
# Returns a list with elements:
#  1. pt_plantings  point plantings spatial layer
#  2. ln_plantings  line plantings spatial layer
#  3. py_plantings  polygon plantings spatial layer
#  4. planting_centoids  point layer encompassing all plantings
#  5. planting_attributes  table of planting attributes extracted from p_gps_pts
#
# April 2026
#
###############################################################################

library(tidyverse)

# 