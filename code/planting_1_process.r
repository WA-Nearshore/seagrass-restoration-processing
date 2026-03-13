#########1#########2#########3#########4#########5#########6#########7#########8
#
# Process Seagrass Restoration Planting Table
#
# This script takes an edited version of the Planting table from the Excel 
# spreadsheet "Eelgrass Restoration Matrix_2019MMDD_jg.xlsx" and processes to 
# a form ready for reading in ArcGIS to make points from xy coordinates. The 
# worksheet from the Excel speadsheet must be exported as a csv file to serve 
# as input to this script. In this script the input data is separated by 
# planting type - point, line, polygon.
# The output includes 3 csv files of planting GPS points - one for each
# data type.
#
# The script also outputs a csv file of plantings - i.e., one record per
# planting whether point, line or polygon. This will be used as a
# join table to the spatial polygon and line layers built from the GPS points.
#
# This script also outputs a csv file of all planting GPS points.  This is
# essentially the input table with minor edits (remove 2nd header row,
# delete rows with missing lat/lon coords and related rows). This is used
# in constructing the restoration area polygons.
#
# The working directory must be set (e.g., with setwd()) to the parent
# directory of the "source_data_processing" directory.
#
# Input:  source_data_processing/planting_v0.csv (Excel worksheet export)
#
# Output: source_data_processing/planting_pt.csv
#         source_data_processing/planting_ln.csv
#         source_data_processing/planting_poly.csv
#         source_data_processing/plantings_table.csv
#         source_data_processing/planting_pts_all.csv
#
# October 2019
#
###############################################################################

library(tidyverse)
library(stringr)
library(lubridate)


plantingV0 <- read.csv("source_data/planting_v0_2019_demo.csv", 
                       stringsAsFactors=FALSE)

#filter out 2nd header row (row 2) based on SITE.NAME, and filter out
# "drop" records (missing lat/lon)
plantingV1 <- plantingV0 %>% filter(str_length(SITE.NAME)>0,
                                    retain_drop=="retain")

# rename columns
names(plantingV1) <- c("restoration_area", "planting_name", "planting_location_code",
                       "planting_relationships", "year",
                       "historical_presence",
                       "data_type_orig", "water_body", "SVMP_region", "project_name",
                       "funding_source", "funding_source_program", "funding_source_contract_no",
                       "funding_source_DNR_contract_no", "contractor",
                       "contractor_DNR_contract_no","citation", "activity_type", "activity_filter",
                       "date", "latitude", "longitude", "data_type", "retain_drop",
                       "datum", "elevation", "planting_meth_drop", "planting_method",
                       "parallel_side", 
                       "perpendicular_side", "plot_area_chr", "planted_area_chr",
                       "effective_area_planted_chr",
                       "planting_unit_count", "shoot_count_chr", "plot_shoot_density",
                       "planted_area_shoot_density", "effective_shoot_density",
                       "donor_site_name", "notes")

# convert key attributes to numeric format (read in as character)
plantingV2 <- plantingV1 %>% mutate(shoot_count = as.numeric(shoot_count_chr),
                                    plot_area = as.numeric(plot_area_chr),
                                    planted_area = as.numeric(planted_area_chr),
                                    effective_area_planted = as.numeric(effective_area_planted_chr)) %>%
                             select(-shoot_count_chr, -plot_area_chr, -planted_area_chr,
                                    -effective_area_planted_chr, -planting_meth_drop)


# create planting_date field as a date data type, delete chr date field
# use date to concatenate with planting_location_code to make planting_code
# delete unneeded columns
plantingV3 <- plantingV2 %>% mutate(planting_date = ymd(date),
                            planting_code = sprintf("%s_%4d%02d%02d_%s",planting_location_code,
                                                    year(planting_date),
                                                    month(planting_date),day(planting_date),
                                                    planting_method)) %>%
                             select(-data_type_orig, -date, -retain_drop)


# extract table of plantings (e.g. reduces four records of polygon corner
# GPS points to one record)
plantings <- plantingV3 %>% filter(activity_filter != "--") %>%
                            select(-latitude, -longitude)


# split into 3 objects based on data type
planting_pt <- plantingV3 %>% filter(data_type=="point")
planting_ln <- plantingV3 %>% filter(data_type=="line")
planting_poly <- plantingV3 %>% filter(data_type=="polygon")


# create an area join table with planting frequency by method
area_join_table <- plantings %>% group_by(restoration_area, planting_method) %>%
                                 summarize(total_shoot_count = sum(shoot_count)) %>%
                                 spread(key=planting_method, value=total_shoot_count,
                                        fill=0.0)
                                 


# write out all the output tables created in this script
write.csv(plantings, file="source_data_processing/plantings_table.csv",
          row.names=FALSE)
write.csv(planting_pt, file="source_data_processing/planting_pt.csv",
          row.names=FALSE)
write.csv(planting_ln, file="source_data_processing/planting_ln.csv",
          row.names=FALSE)
write.csv(planting_poly, file="source_data_processing/planting_poly.csv",
          row.names=FALSE)

write.csv(plantingV2, file="source_data_processing/planting_pts_all.csv",
          row.names=FALSE)
write.csv(area_join_table, file="source_data_processing/area_method_join_table.csv",
          row.names=FALSE)


# some clean up
rm("plantingV0", "plantingV1", "plantingV2")
rm("plantingV3", "planting_ln", "planting_poly", "planting_pt")

cat(sprintf("\nDone.\n\n"))