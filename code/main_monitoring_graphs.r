###############################################################################
#
#  Main program to create graphs of monitoring data collected to track
#  seagrass restoration plantings.
#
#  Input tables are read in from an ArcGIS file geodatabase.
#  The geodatabase is specified in <Project-home>/code/config_SRTools.r.
#
#  The monitoring graphs are written to png files in this location which must
#  already exist:
#     <Project-home>/monitoring_graphs
#
#  August 2026
#
###############################################################################


library(purrr, quietly=TRUE)
library(sf)
source("code/config_SRTools.r")
source("code/functions/create_monitoring_graphs.r")



cat("Preparing data for monitoring graphs...\n")


##############################################################
# read in monitoring and plantings tables from fgdb
##############################################################
if (!dir.exists(pathFGDB)) {
  cat("ERROR: fgdb does not exist [main_monitoring_graphs]\n") 
  cat(sprintf("fgdb = %s\n", pathFGDB))
} else {
  safe_read <- safely(st_read)
  
  monit_Obj <- safe_read(dsn=pathFGDB, layer="monitoring", quiet=TRUE)
  if (is.null(monit_Obj$error)) {    # successful - extract monitoring df 
    monitoring <- monit_Obj$result 
    cat("Reading monitoring successful.\n")
  } else {    # failed
    cat(sprintf("ERROR:  %s", monit_Obj$error$message))
  } 
  
  plant_Obj <- safe_read(dsn=pathFGDB, layer="plantings", quiet=TRUE)
  if (is.null(plant_Obj$error)) {    # successful - return items to Global env.
    plantings <- plant_Obj$result
    cat("Reading plantings successful.\n")
  } else {    # failed
    cat(sprintf("ERROR:  %s", plant_Obj$error$message))
  }
  
  ############################################################
  # create graphs within current working directory
  ############################################################
  safe_graph <- safely(create_monitoring_graphs) 
  graph_flag <- safe_graph(monitoring, plantings)
  
}






