#########1#########2#########3#########4#########5#########6#########7#########8
#
#  Main program to import tables from the Matrix spreadsheet
#  containing data from the seagrass restoration program. The imported data
#  is transformed into the seagrass restoration relational database format 
#  contained in an ArcGIS file geodatabase.
#
#  The three tables to be imported:  
#     planting_gps_pts  (from 'Planting' Excel sheet)
#     donor_sites  (from 'Donor Sites' Excel sheet)
#     monitoring  (from 'Monitoring' Excel sheet)
#
#  Elements of this program:
#    1. read sources tables from Matrix Excel spreadsheet.
#    2. process data to generate seagrass restoration relational database tables
#       including spatial feature classes and non-spatial tables contained in
#       an ArcGIS file geodatabase (configured in 
#         <Project-Folder>/code/config_Matrix_FGDB.r)
#    3. create a Sankey diagram visualizing data structure and identify 'rehab'
#       cases where planting has no GPS coords, but other plantings at same
#       location do have coords.
#
#  Required inputs:
#    1. Seagrass restoration 'Matrix' Excel spreadsheet (file location specified
#       in <Project-Folder>/code/config_Matrix_FGDB.r). 
#    2. donor_site_codes.csv:  Associates short codes with donor site names. 
#       Must be located in <Project-Folder>/source_data
#    3. gps_name_to_planting_name_tbl.csv:  a lookup table for gps-point_names
#       to planting names for plantings with multiple gps points each with
#       unique gps-point-names. Must be located in 
#       <Project-Folder>/source_data.
#
#  Outputs:
#    1. 9 spatial feature classes and 4 non-spatial tables written to file
#       geodatabase (this is the seagrass restoration relational database)
#    2. 6 diagnostic tables are written as csv files to
#       <Project-Folder>/output_tables
#       These tables record cases such as no matching rows across tables or 
#       missing coordinates.
#
#  July 2026
#
###############################################################################

library(tidyverse)
source("code/config_Matrix_FGDB.r")
source("code/functions/read_inputs.r")
source("code/functions/create_database.r")
source("code/functions/write_tbls_lyrs.r")



###############################################################################
# Get external data inputs with funtion read_inputs()
###############################################################################
print("Reading...")

safeRead <- safely(read_inputs)
readObj <- safeRead(xlpath, sheet_names, skip_lines, new_sheet_names, pathFGDB)
if (is.null(readObj$error)) {    # successful
  list2env(readObj$result, envir = .GlobalEnv)
  print("Reading successful.")
} else {    # failed
  print(sprintf("ERROR:  %s", readObj$error))
} 
 


###############################################################################
# Create relational database tables and spatial layers using function
# create_database(). The data arguments passed to function create_database() 
# hard codes names set in config_Matric_FGDB.r (e.g. planting_gps_pts).
###############################################################################
print("Creating tables and layers...")

safeCreateDB <- safely(create_database)
createDB_Obj <- safeCreateDB(planting_gps_pts, name_lookup, donor_site_codes,
                             donor_sites, baselayer, pathFGDB)
if (is.null(createDB_Obj$error)) {   # successful
  list2end(createDB_Obj$result, envir = .GlobalEnv)
  print("Create DB successful.")
} else {   # failed
  print(sprintf("ERROR:  %s", createDB_Obj$error)) 
}


###############################################################################
#  Write relational database tables and layers to fgdb.
#  Write diagnostic tables (e.g. cases with no matching) to csv file.
#  Write function returns 0 on error; 1 if successful.
###############################################################################
print("Writing...")

safeWrite <- safely(write_tbls_lyrs)
writeObj <- safeWrite(sub_projects, plantings, planting_locations,
                      planting_loc_missing_coords, rehab_plantingIDs,
                      pt_plantings_rehab, ln_plantings_rehab, py_plantings_rehab,
                      grid_plantings_rehab, planting_centroids_rehab,
                      restoration_areas,
                      donor_site_usage, donor_sites, donor_collection_pts,
                      monitor_tbl, mon_tbl_noMatch, plantings_noMonData)
if (is.null(writeObj$error)) {    # successful
  print("Writing successful.") 
} else {     # failed
  print(sprintf("ERROR: %s", writeObj$error)) 
}


cat("\nCompleted.\n")


rm(isheet,get_sheets,matrix_sheets,new_sheet_names,skip_lines,sheet_names)
rm(xlpath)
rm(planting_gps_pts)
rm(clean_planting_gps_pts, create_prj, distill_vals)
rm(p_gps_pts_cln, prj_out_list, prj_codes)
rm(plantings_out_list, create_planting_key, create_plantings)
rm(notes_process)
rm(create_lyrs, group_process_char, group_process_date, group_process_numeric)
rm(lyrsObj)
rm(p_gps_pts0, pathFGDB)
rm(create_locations, create_sankey)
rm(plantings_matrix)
rm(create_restoration_areas)
rm(sankey_returnObj, rehab_returnObj)
rm(create_donor_tbls, create_monitoring)
rm(donorObj, group_process_planting_name)
rm(monitorObj, name_lookup_in, name_lookup, restoration_returnObj)
rm(donor_site_codes, donor_sites, monitoring)
rm(planting_loc_returnObj)
rm(grid_plantings, ln_plantings, planting_centroids, pt_plantings)
rm(py_plantings, rehab_plantingIDs)

