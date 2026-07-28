########1#########2#########3#########4#########5#########6#########7#########8
#
# Make graphs of monitoring data for each planting that has monitoring data
#
# This script makes small graphs (200 x 150 pixels) intended for the popups
# in an interactive web map.
#
# Input:  source_data_processing/monitoring_v0.csv (Excel worksheet export)
#
# Output: graphs_web/xxxxx.png   (xxxx = planting code)
#
# November 2019
#
##############################################################################

library(tidyverse)
library(lubridate)
library(stringr)
library(gridExtra)
library(gtable)
library(grid)

# read processed monitoring table & select fields needed here
monDat1 <- read.csv("source_data_processing/monitoring_processed.csv", 
                    stringsAsFactors=FALSE)
monDat2 <- monDat1 %>% select(planting_code, days_elapsed, status_shoot_count,
                              status_qual, cat2)

# get list of unique planting codes
uniquePlantingCodes <- unique(monDat2$planting_code)

# read plantings table
plantings <- read.csv("source_data_processing/plantings_table.csv",
                      stringsAsFactors=FALSE)

# extract plantings that have monitoring data
plantingsMon <- plantings %>% filter(planting_code %in% uniquePlantingCodes)


# QA step - see if all planting codes in monitoring table matched with
# the planting code in a record of the plantings table
uniquePCodesdf <- data.frame(planting_code = uniquePlantingCodes,
                             stringsAsFactors=FALSE)
if (dim(plantingsMon)[1] != length(uniquePlantingCodes)) {
    cat("\nNot all monitoring records matched with planting records.\n")
    cat("Query data frame errorRecs for more detail.\n")
    errorRecs <- uniquePCodesdf %>%
                      anti_join(plantingsMon, by="planting_code")
} else {
    cat("\nMonitoring records matched with planting records.\n")
}


######## construct df for shoot count graphs ########
monDat_quan <- monDat2 %>% filter(cat2=="present_cnt" |
                                  cat2=="absent")  %>%
                           mutate(shoot_count = ifelse(cat2=="absent",
                                                       0,status_shoot_count)) %>%
                           select(-status_shoot_count, -status_qual, -cat2)
plantings_quan <- plantingsMon %>% select(planting_code,shoot_count)  %>%
                                   mutate(days_elapsed=0)
quan_df <- rbind(monDat_quan, plantings_quan)

######## construct df for presence/absence graphs #######
monDat_qual <- monDat2 %>%  
               mutate(yval=1, 
                      presence_absence=factor(ifelse(cat2=="present_cnt", "present", cat2),
                                              c("present", "absent"))) %>%
                            select(-status_shoot_count, -status_qual, -cat2)
plantings_qual <- data.frame(planting_code=monDat_qual$planting_code,
                             days_elapsed=0,
                             yval=1,
                             presence_absence="present")
qual_df <- rbind(monDat_qual, plantings_qual)


############### loop through plantings and make graphs ##################### 
for (iplanting in uniquePlantingCodes) {
   cat(sprintf("%s\n", iplanting))
   idata <- quan_df %>% filter(planting_code == iplanting)
   jdata <- qual_df %>% filter(planting_code == iplanting)

   maxyrs <- ceiling(max(max(idata$days_elapsed), max(jdata$days_elapsed))/365)

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
   p1 <- ggplot(data=idata, mapping=aes(x=days_elapsed, y=shoot_count)) +
         geom_point(size=2, color="darkcyan") +
         theme_bw() +
         theme(
            axis.title.y = element_text(size = 12,
                                        margin = margin(t=0,b=0,l=0,r=10,unit="pt")),
            axis.title.x = element_blank(),
            panel.grid.major.x = element_line(color="gray80"),
            panel.border = element_rect(color="gray20", size=0.8)
         ) +
         scale_y_continuous(name="shoot count", limits=iylim) +
         scale_x_continuous(breaks=ibreaks, labels=ilabels, limits=ixlim)
  
   # qualitative graph - presence/absence    
   p2 <- ggplot(data=jdata, mapping=aes(x=days_elapsed, y=yval, fill=presence_absence)) +
         geom_point(shape=22, size=3) +
         theme_bw() +
         theme(
            axis.title.y = element_blank(),
            axis.text.y = element_blank(),
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
   fname = str_c("graphs/monitoring_graphs/", iplanting,".png", sep="")
   png(filename=fname, height=150, width=200, units="px")
     
#   grid.arrange(p1, p2, heights=c(3,1), nrow=2)  
   
   grob1 <- ggplotGrob(p1)
   grob2 <- ggplotGrob(p2)
   grob <- rbind(grob1, grob2, size="first")
   grob$widths <- unit.pmax(grob1$widths, grob2$widths)
   grid.newpage()
   grid.draw(grob)
   
   dev.off()
   
}  #  close for loop through plantings





# clean up
# rm(monDat1, monDat2, monDat_quan, plantings, plantings_quan, plantingsMon,
#   uniquePCodesdf, uniquePlantingCodes)


