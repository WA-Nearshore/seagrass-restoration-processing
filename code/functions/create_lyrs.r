#########1#########2#########3#########4#########5#########6#########7#########8
#
# create_lyrs()
#
# Function to create ArcGIS feature classes in a geodatabase for point, line
# and polygon plantings, as well as a centroids layer that includes all
# plantings, all based on the planting GPS points (p_gps_pts) data frame
# passed as an argument.
#
# May 2026
#
###############################################################################

library(sf)
source("code/functions/group_process.r")


create_lyrs <- function(p_gps_pts, pathFGDB) {
 
  ########################################################################## 
  # separate gps records by geometry, and separate records with GPS coords
  # and those without.
  ########################################################################## 
  pt_recs <- p_gps_pts %>% filter(planting_geometry == "point")
  ln_recs <- p_gps_pts %>% filter(planting_geometry == "line")
  py_recs <- p_gps_pts %>% filter(planting_geometry == "polygon")
  grid_recs <- p_gps_pts %>% filter(planting_geometry == "grid")
  
  # get planting GPS records with GPS coordinates
  pt_recs_cln <- pt_recs %>% drop_na(latitude, longitude) 
  ln_recs_cln <- ln_recs %>% drop_na(latitude, longitude) 
  py_recs_cln <- py_recs %>% drop_na(latitude, longitude) 
  grid_recs_cln <- grid_recs %>% drop_na(latitude, longitude) 

  # get planting GPS records for no-coordinates plantings
  pt_nonspatial_planting_recs <- pt_recs %>% filter(!(plantingID %in% unique(pt_recs_cln$plantingID)))
  ln_nonspatial_planting_recs <- ln_recs %>% filter(!(plantingID %in% unique(ln_recs_cln$plantingID)))
  py_nonspatial_planting_recs <- py_recs %>% filter(!(plantingID %in% unique(py_recs_cln$plantingID)))
  grid_nonspatial_planting_recs <- grid_recs %>% filter(!(plantingID %in% unique(grid_recs_cln$plantingID)))
  
 
  # identify line plantings that only have one GPS point. Transfer these records 
  # to the point records for spatial representation
  # get count of gps records by planting
  ln_cln_plantings <- ln_recs_cln %>% group_by(plantingID) %>%
    summarize(n_gps_pts = n())
  # get line plantings with only 1 gps point
  ln_cln_plantings_1gpsPt <- ln_cln_plantings %>% filter(n_gps_pts==1) 
  # get good line plantings (>1 point) for conversion to spatial line 
  ln_recs_cln_not1pt <- ln_recs_cln %>% 
    filter(!(plantingID %in% ln_cln_plantings_1gpsPt$plantingID))
  # get gps records for line plantings with only 1 gps point
  ln_recs_cln_1pt <- ln_recs_cln %>%
    filter(plantingID %in% ln_cln_plantings_1gpsPt$plantingID)
  # append gps recs for 1-point line plantings to the point plantings
  pt_recs_cln_add <- rbind(pt_recs_cln, ln_recs_cln_1pt)
 
   
  # identify polygon plantings with insufficient number of GPS points (min. 4)
  # and address these cases
  # get count of gps records by planting
  py_cln_plantings <- py_recs_cln %>% group_by(plantingID) %>%
    summarize(n_gps_pts = n())
  # A. if only 2 GPS points, transfer these records to the line records.
  py_cln_plantings_2pt <- py_cln_plantings %>% filter(n_gps_pts==2)
  py_recs_cln_2pts <- py_recs_cln %>%
    filter(plantingID %in% py_cln_plantings_2pt$plantingID)
  py_recs_cln_not2pts <- py_recs_cln %>%
    filter(!(plantingID %in% py_cln_plantings_2pt$plantingID))
  ln_recs_cln_not1pt_addpy2pt <- rbind(ln_recs_cln_not1pt, py_recs_cln_2pts)
  # B. if only 3 GPS points, duplicate the 1st GPS record and rbind to make 4 recs
  py_cln_plantings_3pt <- py_cln_plantings %>% filter(n_gps_pts==3)
  py_recs_cln_3pts <- py_recs_cln_not2pts %>% 
    filter(plantingID %in% py_cln_plantings_3pt$plantingID)
  py_recs_cln_3pts_addrecs <- py_recs_cln_3pts %>%
    group_by(plantingID) %>%
    slice_head(n = 1)
  py_recs_cln_4pts <- rbind(py_recs_cln_not2pts, py_recs_cln_3pts_addrecs)
  
  
### CONFIRM A & B WORKED CORRECTLY - CHANGE NAMES BELOW
  
  
  
  ########################################################################## 
  # Convert data frames with lat/lon columns into spatial sf objects
  # First convert to point features and project to State Plane.
  # Second assemble points into line and polygon features.
  # EPSG 2927 = State Plant WA South NAD83 HARN US Survey feet
  # EPSG 4326 = Unprojected (geographic) with WGS84 datum
  ########################################################################## 
  pt_spatial_PT_geo <- st_as_sf(pt_recs_cln_add, coords = c("longitude","latitude"), crs=4326)
  pt_spatial_PT_StPl <- st_transform(pt_spatial_PT_geo, crs=2927) 
  
  ln_spatial_PT_geo <- st_as_sf(ln_recs_cln_not1pt_addpy2pt, coords = c("longitude","latitude"), crs=4326)
  ln_spatial_PT_StPl <- st_transform(ln_spatial_PT_geo, crs=2927)
  
  py_spatial_PT_geo <- st_as_sf(py_recs_good4poly, coords = c("longitude","latitude"), crs=4326)
  py_spatial_PT_StPl <- st_transform(py_spatial_PT_geo, crs=2927)
  
  gr_spatial_PT_geo <- st_as_sf(grid_recs_cln, coords = c("longitude", "latitude"), crs=4326)
  gr_spatial_PT_StPl <- st_transform(gr_spatial_PT_geo, crs=2927)
  
   
  # construct lines
  ln_plantings <- ln_spatial_PT_StPl %>% group_by(plantingID) %>%
    summarize(do_union = FALSE) %>%
    st_cast("LINESTRING")
  
  # construct polygons
  py_plantings <- py_spatial_PT_StPl %>%
    ###################
  
  # write pt and ln planting spatial features to file geodatabase
  st_write(pt_spatial_PT_StPl, dsn=pathFGDB, layer="pt_plantings", driver="OpenFileGDB")
  st_write(ln_plantings, dsn="2026_update_Pro_project/2026_update_Pro_project.gdb",
           layer="ln_plantings_2pt", driver="OpenFileGDB")
  st_write(py_spatial_PT_StPl, dsn=pathFGDB, layer="py_plantings_PT",
           driver="OpenFileGDB")
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  #########  following blocks used with console only for Sankey diagram data 
   
  # reduce good GPS point records to plantings
  pt_plantings_cln <- pt_recs_cln %>% group_by(plantingID) %>%
    summarize(count_pt_plantings=n(), type=group_process(activity_type))
  ln_plantings_cln <- ln_recs_cln %>% group_by(plantingID) %>%
    summarize(count_ln_plantings=n(), type=group_process(activity_type))
  py_plantings_cln <- py_recs_cln %>% group_by(plantingID) %>%
    summarize(count_py_plantings=n(), type=group_process(activity_type))
  grid_plantings_cln <- grid_recs_cln %>% group_by(plantingID) %>%
    summarize(count_grid_plantings=n(), type=group_process(activity_type))
  
  # reduce non-spatial GPS records to plantings
  pt_nonsp_plantings <- pt_nonspatial_planting_recs %>% group_by(plantingID) %>%
    summarize(count_pt_nonsp_plt=n(), type=group_process(activity_type))
  ln_nonsp_plantings <- ln_nonspatial_planting_recs %>% group_by(plantingID) %>%
    summarize(count_ln_nonsp_plt=n(), type=group_process(activity_type))
  py_nonsp_plantings <- py_nonspatial_planting_recs %>% group_by(plantingID) %>%
    summarize(count_py_nonsp_plt=n(), type=group_process(activity_type))
  gr_nonsp_plantings <- grid_nonspatial_planting_recs %>% group_by(plantingID) %>%
    summarize(count_gr_nonsp_plt=n(), type=group_process(activity_type))
 
  # summarize plantings with GPS coords to get test/large_scale breakdown 
  pt_plantings_cln_summ <- pt_plantings_cln %>% group_by(type) %>% 
    summarize(plantings_count = n())
  ln_plantings_cln_summ <- ln_plantings_cln %>% group_by(type) %>%
    summarize(plantings_count = n())
  py_plantings_cln_summ <- py_plantings_cln %>% group_by(type) %>%
    summarize(plantings_count = n())
  grid_plantings_cln_summ <- grid_plantings_cln %>% group_by(type) %>% 
    summarize(plantings_count = n())
  
  # summarize no coords plantings to get test/large breakdown
  pt_nonsp_plt_summ <- pt_nonsp_plantings %>% group_by(type) %>%
    summarize(plantings_count = n())
  ln_nonsp_plt_summ <- ln_nonsp_plantings %>% group_by(type) %>%
    summarize(plantings_count = n())
  py_nonsp_plt_summ <- py_nonsp_plantings %>% group_by(type) %>%
    summarize(plantings_count = n())
  gr_nonsp_plt_summ <- gr_nonsp_plantings %>% group_by(type) %>%
    summarize(plantings_count = n())
   
  
  
  
  
  
  
  
}