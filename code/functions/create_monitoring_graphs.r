###############################################################################
#
#  create_monitoring_graphs()
#
#  Create site graphs with monitoring data tracking seagrass restoration
#  plantings.
#
#  Graphs are created as png files in folder <Project-Folder>/monitoring_graphs
#  which must be created prior to execution.
#
#  July 20, 2025
#
###############################################################################

library(dplyr)
library(ggplot2)
library(grid)

create_monitoring_graphs <- function(monitoring, plantings) {
  
  cat("Creating monitoring graphs...\n") 
  
  ###########################################################################
  # prepare separate data for graphs - shoot count & presence/absence graphs
  ###########################################################################
  mon_sel <- monitoring %>% select(plantingID, veg_presence, shoot_count,
                                   days_since_planted)
  
  # Get unique list of plantingIDs for monitored plantings - used to filter
  # plantings to those monitored and also used as basis of planting loop
  mon_plantingID <- unique(monitoring$plantingID)
  
  # isolate planting data for monitored plantings to serve as time 0 data point
  plantingsMon <- plantings %>% filter(plantingID %in% mon_plantingID)
  
  # format planting records to match mon_sel
  plantingsMon_recs <- data.frame(
         plantingID = plantingsMon$plantingID,
         veg_presence = rep("present", times = dim(plantingsMon)[1]),
         shoot_count = plantingsMon$number_shoots,
         days_since_planted = rep(0, times = dim(plantingsMon)[1]))
  
  # combine monitoring records with day-0 plantings recs 
  graphing_recs <- rbind(mon_sel, plantingsMon_recs)
  
  # separate categorical (presence/absence)(qual) and numerical data (quan)
  quan_df <- graphing_recs %>% filter(!(is.na(shoot_count)))
  qual_df <- graphing_recs %>% 
    filter(!(is.na(veg_presence)), !(veg_presence == "unknown")) %>%
    mutate(yval = 1, veg_presence_fct = factor(veg_presence,
                                               levels = c("present","absent")))
  

    
  #######################################################################
  # loop through plantings and make graphs
  #######################################################################
  cat("Entering loop through plantings to graph...\n")  
  for (iplanting in mon_plantingID[1]) {
    
     cat(sprintf("Creating graph for planting %s\n", iplanting)) 
    
     idata <- quan_df %>% filter(plantingID == iplanting)
     jdata <- qual_df %>% filter(plantingID == iplanting)
  
     maxyrs <- ceiling(max(max(idata$days_since_planted), 
                           max(jdata$days_since_planted))/365)
  
     # set x axis breaks and labels and limits
     ibreaks <- seq(from=0, to=maxyrs*365, by=365)
     ixlim <- c(0,maxyrs*365)
     ilabels <- c("0yr", "1yr")
     if (maxyrs > 1) {
        for (iyr in seq(from=2, to=maxyrs, by=1)) {
           ilabels <- append(ilabels, str_c(iyr,"yr", sep=""))
        } 
     }
      
     # quantitative graph - shoot count 
     # get y axis limits
     iylim <- c(0, ceiling(max(idata$shoot_count)))
     p1 <- ggplot(data=idata, mapping=aes(x=days_since_planted, y=shoot_count)) +
           geom_point(shape=21, size=4, fill="springgreen3", color="black") +
           theme_bw() +
           theme(
              axis.title.y = element_text(size = 14,
                                          margin = margin(t=0,b=0,l=0,r=10,unit="pt")),
              axis.title.x = element_blank(),
              axis.text = element_text(size=12),
              panel.grid.major.x = element_line(color="gray80"),
              panel.border = element_rect(color="gray20", linewidth=0.8)
           ) +
           scale_y_continuous(name="shoot count", limits=iylim) +
           scale_x_continuous(breaks=ibreaks, labels=ilabels, limits=ixlim)
    
     # qualitative graph - presence/absence    
     p2 <- ggplot(data=jdata, mapping=aes(x=days_since_planted, y=yval, 
                                          fill=veg_presence)) +
           geom_point(shape=22, size=4) +
           theme_bw() +
           theme(
              axis.title.y = element_blank(),
              axis.text.y = element_blank(),
              axis.text.x = element_text(size=12),
              axis.title.x = element_blank(),
              axis.ticks.y = element_blank(),
              axis.line.x = element_line(),
              panel.grid.major.y = element_blank(),
              panel.grid.minor.y = element_blank(),
              panel.border = element_blank(),
              legend.position = "none"
           ) +
           scale_x_continuous(breaks=ibreaks, labels=ilabels, limits=ixlim) +
           scale_fill_manual(values = c("springgreen3","gray75")) +
           scale_color_manual(values = c("springgreen4", "gray40"))
        
  
     # open png device, arrange graphs, close device
     fname = str_c("monitoring_graphs/", iplanting,".png", sep="")
     png(filename=fname, height=450, width=600, units="px")
       
     grob1 <- ggplotGrob(p1)
     grob2 <- ggplotGrob(p2)
     grob <- rbind(grob1, grob2, size="first")
     grob$widths <- unit.pmax(grob1$widths, grob2$widths)
     grid.newpage()
     grid.draw(grob)
     
     dev.off()
     
  }  #  close for loop through plantings
  
  cat("Monitoring graphs created.\n")
   
  return(1)
}


