#########1#########2#########3#########4#########5#########6#########7#########8
#
# Script to import a table of plantings.
# This table is imported to the restoration
# geodatabase and joined to the planting spatial layer (plantint_pt_all).
#
# This script also adds a field with URLs to the monitoring data graphs.
#
# Inputs:  source_data_processing/plantings_monitored_table.csv
# Outputs: joins to planting spatial layers
#
# November 2019
#
################################################################################

import arcpy

arcpy.env.overwriteOutput = True

# set workspace
# home = "K:/projects/Eelgrass_Restoration/Restoration_Storymap/2019_06/"
home = "C:/Users/pete/OneDrive/Work-current/Restoration_Storymap/2019_06/"
arcpy.env.workspace = home + "GIS_storymap_prep2/GIS_storymap_prep2.gdb"

# set paths to csv and feature class inputs
in_csv_file = home + "source_data_processing/plantings_monitored_table.csv"
out_table_name = "plantings_monitored"
planting_pt_fc = "plantings_pt"
planting_ln_fc = "plantings_ln"
planting_poly_fc = "plantings_poly"
planting_pt_all_fc = "planting_pt_all"

# import csv file - plantings with flag indicating whether monitored
print("importing csv...\n")
arcpy.TableToTable_conversion(in_rows=in_csv_file,
                              out_path=arcpy.env.workspace,
                              out_name=out_table_name)

# join table to planting feature classes
print("making joins...\n")
arcpy.JoinField_management(in_data=planting_pt_fc,
                           in_field="planting_code",
                           join_table=out_table_name,
                           join_field="planting_code")
arcpy.JoinField_management(in_data=planting_ln_fc,
                           in_field="planting_code",
                           join_table=out_table_name,
                           join_field="planting_code")
arcpy.JoinField_management(in_data=planting_poly_fc,
                           in_field="planting_code",
                           join_table=out_table_name,
                           join_field="planting_code")
arcpy.JoinField_management(in_data=planting_pt_all_fc,
                           in_field="planting_code",
                           join_table=out_table_name,
                           join_field="planting_code")







