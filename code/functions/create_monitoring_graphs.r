###############################################################################
#
#  create_monitoring_graphs()
#
#  Create site graphs with monitoring data following seagrass restoration
#  plantings.
#
#  Graphs are created in folder <HOME>/monitoring_graphs which must be created
#  prior to execution.
#
#  July 20, 2025
#
###############################################################################

library(tidyverse)

create_monitoring_graphs <- function(monitoring, plantings) {
  
  #########################################################################
  # prepare data for graphs - shoot count and presence/absence graphs
  #########################################################################
  mon_sel <- monitoring %>% select(plantingID, veg_presence, shoot_count,
                                   days_since_planted)
  
  # get unique list of plantingIDs for monitored plantings
  mon_plantingID <- unique(monitoring$plantingID)
  
  # isolate planting data for monitored plantings to add time 0 data point
  plantingsMon <- plantings %>% filter(plantingID %in% mon_plantingID)
  
  
  
  
  
  
  
  return(1)
}