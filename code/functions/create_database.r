###############################################################################
#
# create_database()
#
# Creates the seagrass restoration database tables and spatial layers given
# the sheets from the Matrix spreadsheet and other input and config data.
#
# July 2026
#
###############################################################################

library(tidyverse)
source("code/functions/clean_planting_gps_pts.r")
source("code/functions/create_donor_tbls.r")
source("code/functions/create_locations.r")
source("code/functions/create_lyrs.r")
source("code/functions/create_monitoring.r")
source("code/functions/create_monitoring_graphs.r")
source("code/functions/create_plantings.r")
source("code/functions/create_prj.r")
source("code/functions/create_restoration_areas.r")
source("code/functions/create_sankey.r")
source("code/functions/rehab_plantings.r")


create_database <- function(planting_gps_pts, name_lookup, donor_site_codes,
                            donor_sites, baselayer, pathFGDB) {


  # Initial clean of planting_gps_pts 
  # filters to table rows; remove dup col, remove location=NA records (blank records)
  p_gps_pts_cln <- clean_planting_gps_pts(planting_gps_pts)

  # Create projects table by extracting from planting_gps_pts and adding keys
  prj_out_list <- create_prj(p_gps_pts_cln)
  sub_projects <- prj_out_list[[1]]
  p_gps_pts0 <- prj_out_list[[2]]

  # Create plantings table (nonspatial); add plantingID key to p_gps_pts 
  plantings_out_list<- create_plantings(p_gps_pts0, name_lookup, donor_site_codes)
  p_gps_pts1 <- plantings_out_list[[1]]
  plantings <- plantings_out_list[[2]]

  # Create planting spatial layers (pt,ln,poly,grid,centroids) & write to fgdb.
  # Returned list items are all sf spatial objects.
  lyrsObj <- create_lyrs(p_gps_pts1, plantings)
  pt_plantings <- lyrsObj[[1]]
  ln_plantings <- lyrsObj[[2]]
  py_plantings <- lyrsObj[[3]]
  grid_plantings <- lyrsObj[[4]]
  planting_centroids <- lyrsObj[[5]]

  # Create planting_locations point sf object and separate table of locations
  # missing coordinates.
  planting_loc_returnObj <- create_locations(p_gps_pts1, pathFGDB)
  planting_locations <- planting_loc_returnObj[[1]]
  planting_loc_missing_coords <- planting_loc_returnObj[[2]]

  # Create Sankey diagram summarizing structure in the data. This inventorying
  # is necessary to identify
  # plantingIDs associated with cases w/no planting coords, but planting is
  # associated with a planting_location_code with known coordinates. Using this
  # info these cases can be 'rehabilitated' and added to spatial layers.
  sankey_returnObj <- create_sankey(p_gps_pts1, plantings, planting_locations)
  p_sankey <- sankey_returnObj[[1]]
  rehab_plantingIDs <- sankey_returnObj[[2]]


  # Add the rehab plantingIDs to the appropriate spatial layers. Initial June
  # 2026 dev only handles point and grid rehab records.
  if (dim(rehab_plantingIDs)[1] > 0) {
    rehab_returnObj <- rehab_plantings(rehab_plantingIDs, pt_plantings, ln_plantings,
                                      py_plantings, grid_plantings,
                                      planting_centroids, planting_locations)
    pt_plantings_rehab <- rehab_returnObj[[1]] 
    ln_plantings_rehab <- rehab_returnObj[[2]] 
    py_plantings_rehab <- rehab_returnObj[[3]] 
    grid_plantings_rehab <- rehab_returnObj[[4]] 
    planting_centroids_rehab <- rehab_returnObj[[5]] 
  }

  # Create restoration areas layer and add shared key restoration_area_code to
  # planting_locations. Both are sf objects.
  # This function reads external data - the WA state baselayer from fgdb.
  restoration_returnObj <- create_restoration_areas(planting_locations, p_gps_pts1,
                                                  baselayer) 
  restoration_areas <- restoration_returnObj[[1]]
  planting_locations <- restoration_returnObj[[2]]

  # Create donor site tables; uses donor site codes read earlier from csv
  donorObj <- create_donor_tbls(p_gps_pts1, donor_sites, donor_site_codes)
  donor_site_usage <- donorObj[[1]]
  donor_sites <- donorObj[[2]]
  donor_collection_pts <- donorObj[[3]]

  # Create monitoring data table. Also returns monitoring records with no matching
  # planting.
  monitorObj <- create_monitoring(monitoring, plantings, p_gps_pts1)
  monitor_tbl <- monitorObj[[1]]
  mon_tbl_noMatch <- monitorObj[[2]]
  plantings_noMonData <- monitorObj[[3]]

 
  ########## pack return object and return
  returnObj <- list(plantings = plantings,
                    planting_locations = planting_locations,
                    pt_plantings = pt_plantings_rehab,
                    ln_plantings = ln_plantings_rehab,
                    py_plantings = py_plantings_rehab,
                    grid_plantings = grid_plantings_rehab,
                    planting_centroids = planting_centroids_rehab,
                    restoration_areas = restoration_areas,
                    donor_site_usage = donor_site_usage,
                    donor_sites = donor_sites,
                    donor_collection_pts = donor_collection_pts,
                    monitoring = monitor_tbl,
                    sub_projects = sub_projecs,
                    p_sankey = p_sankey,
                    planting_loc_missing_coords = planting_loc_missing_coords,
                    mon_tbl_noMatch = mon_tbl_noMatch,
                    plantings_noMonData = plantings_noMonData)
  return(returnObj)
}



