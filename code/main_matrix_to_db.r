#########1#########2#########3#########4#########5#########6#########7#########8
#
#  Main program to import tables from the Matrix spreadsheet
#  containing data from the seagrass restoration program. The imported data
#  is transformed into the seagrass restoration relational database structure 
#  contained within an ArcGIS file geodatabase.
#
#  The three tables to be imported from the Matrix spreadsheet:  
#     planting_gps_pts  (from 'Planting' Excel sheet)
#     donor_sites  (from 'Donor Sites' Excel sheet)
#     monitoring  (from 'Monitoring' Excel sheet)
#
#  Elements of this program:
#    1. Read sources tables from Matrix Excel spreadsheet.
#    2. Process data to generate:
#       - seagrass restoration relational database tables including spatial 
#         feature classes and non-spatial tables contained in an ArcGIS file 
#         geodatabase (fgdb details in <Project-Folder>/code/config_Matrix_FGDB.r)
#       - a Sankey diagram visualizing data structure and identify 'rehab'
#         cases where planting has no GPS coords, but other plantings at same
#        location do have coords.
#    3. Write outputs to fgdb and to <Projet-Folder>/output_tables
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
#  August 2026
#
###############################################################################

library(tidyverse, quietly=TRUE)
source("code/config_Matrix_FGDB.r")
source("code/functions/read_inputs.r")
source("code/functions/create_database.r")
source("code/functions/write_tbls_lyrs.r")



###############################################################################
# Get external data inputs with function read_inputs() - arguments from config
###############################################################################
print("Reading...")

safeRead <- safely(read_inputs)
readObj <- safeRead(xlpath, sheet_names, skip_lines, new_sheet_names, pathFGDB)
if (is.null(readObj$error)) {    # successful - return items to Global env.
  list2env(readObj$result, envir = .GlobalEnv)
  print("Reading successful.")
} else {    # failed
  cat(sprintf("ERROR:  %s", readObj$error$message))
} 
 

###############################################################################
# Create relational database tables and spatial layers using function
# create_database(). The data arguments passed to function create_database() 
# hard codes names set in config_Matrix_FGDB.r (e.g. planting_gps_pts), so these
# argument names must be kept in sync with config_Matrix_FGDB.r.
###############################################################################
print("Creating tables and layers...")

safeCreateDB <- safely(create_database)
createDB_Obj <- safeCreateDB(planting_gps_pts, name_lookup, donor_site_codes,
                             donor_sites, baselayer, pathFGDB)
if (is.null(createDB_Obj$error)) {   # successful
  list2env(createDB_Obj$result, envir = .GlobalEnv)
  print("Create DB successful.")
} else {   # failed
  cat(sprintf("ERROR:  %s", createDB_Obj$error$message)) 
}


###############################################################################
#  Write relational database tables and layers to fgdb specified in 
#  config_Matrix_FGDB.r. Also write diagnostic tables (e.g. cases with no 
#  matching) to csv file. Write function returns 0 on error; 1 if successful.
###############################################################################
print("Writing...")

safeWrite <- safely(write_tbls_lyrs)
writeObj <- safeWrite(sub_projects, plantings, planting_locations,
                      planting_loc_missing_coords, rehab_plantingIDs,
                      pt_plantings, ln_plantings, py_plantings,
                      grid_plantings, planting_centroids,
                      restoration_areas,
                      donor_site_usage, donor_sites, donor_collection_pts,
                      monitoring, mon_tbl_noMatch, plantings_noMonData)
if (is.null(writeObj$error)) {    # successful
  print("Writing successful.") 
} else {     # failed
  cat(sprintf("ERROR: %s", writeObj$error$message)) 
}


cat("\nCompleted.\n")


rm(get_sheets,new_sheet_names,skip_lines,sheet_names)
rm(xlpath)
rm(planting_gps_pts)
rm(clean_planting_gps_pts, create_prj, distill_vals)
rm(prj_codes)
rm(create_planting_key, create_plantings)
rm(notes_process)
rm(create_lyrs, group_process_char, group_process_date, group_process_numeric)
rm(pathFGDB)
rm(create_locations, create_sankey)
rm(plantings_matrix)
rm(create_restoration_areas)
rm(create_donor_tbls, create_monitoring)
rm(group_process_planting_name)
rm(name_lookup)
rm(donor_site_codes)
rm(grid_plantings, ln_plantings, planting_centroids, pt_plantings)
rm(py_plantings, rehab_plantingIDs)
rm(create_database, createDB_Obj, mon_tbl_noMatch)
rm(planting_loc_missing_coords, plantings_noMonData)
rm(read_inputs, readObj, rehab_plantings, run_tools_cli)
rm(safeCreateDB, safeRead, safeWrite)
rm(write_tbls_lyrs, writeObj)

