########1#########2#########3#########4#########5#########6#########7#########8
#
# Process Seagrass Restoration Monitoring Table
#
# This script takes an edited version of the Monitoring table from the Excel 
# spreadsheet "Eelgrass Restoration Matrix_2019MMDD_jg.xlsx" and reduces to 
# a table of plantings that have monitoring data available.  When this is
# joined with the coordinates from the planting table, the result is the 
# basis for display as a monitoring layer.
#
# This script also produces two graphs as part of data exploration.
#
# The worksheet from the Excel speadsheet must be exported as a csv file
# to serve as input to this script. 
#
# The working directory must be set (e.g., with setwd()) to the parent
# directory of the "source_data_processing" directory.
#
# Inputs:  source_data_processing/monitoring_v0.csv (Excel worksheet export)
#          source_data_processing/monitoring_cat_lookup.csv (results categories)
#
# Output: source_data_processing/monitoring_processed.csv
#         graphs/monitoring_event_elapsed_time.png
#         graphs/freq_plantings_by_num_events.png
#         graphs/monitoring_pt_dist.png
#
# November 2019
#
###############################################################################

library(tidyverse)
library(stringr)
library(lubridate)


# components of URLs to monitoring graphs
urlprefix <- "https://fortress.wa.gov/dnr/adminsa/gisdata/datadownload/nearshorephotos/restoration/"
urlsuffix <- ".png"

cat("processing...\n")

monitoringV0 <- read.csv("source_data_processing/monitoring_v0.csv", stringsAsFactors=FALSE)

# rename columns
names(monitoringV0) <- c("restoration_area","site_label", "planting_code",
                         "data_type", "record_type", "planting_date_chr",
                         "planted_area", "shoots_planted_count",
                         "monitoring_entity", "monitoring_date_chr",
                         "status_qual", "planting_method",
                         "status_shoot_count", "status_area",
                         "status_shoot_density", "status_elapsed_time",
                         "status_survival", "notes")


# filter for values of record_type equal to "planting". This removes
# the second heading row, the spacer rows between blocks of data records,
# and the extraneous rows from GPS points for line and polygon
# plantings.
monitoringV1 <- monitoringV0 %>% filter(record_type=="planting") %>%
                     mutate(planting_date = ymd(planting_date_chr),
                            monitoring_date = ymd(monitoring_date_chr)) %>%
                     select(-planting_date_chr, -monitoring_date_chr)

# get elapsed time in days between planting and monitoring
monitoringV2 <- monitoringV1 %>% mutate(days_elapsed=monitoring_date - planting_date)

# for data exploration...
# create string that can be summarized to categories of monitoring data (for pie chart)
monitoring_d <- monitoringV2 %>% 
                mutate(statCat = ifelse(str_length(status_qual)==0 | 
                                        status_qual=="unknown","missing",
                                        status_qual)) %>%
                mutate(countCat = ifelse(str_length(status_shoot_count)==0,
                                         "missing", sign(as.numeric(status_shoot_count)))) %>%
                mutate(areaCat = ifelse(str_length(status_area)==0, "missing",
                                        "areaVal"))

monitoring_d1 <- monitoring_d %>% mutate(monCat = sprintf("%s_%s_%s",
                                                          statCat,countCat,areaCat))



########1#########2#########3#########4#########5#########6#########7#########8
# GRAPH - elapsed time
# how are monitoring events spaced in time after planting?
###############################################################################
cat("elapsed time graph....\n")
p1 <- ggplot(data=monitoring_d1, 
             mapping=aes(x=days_elapsed, y=5)) +
      geom_jitter(stroke=0, size=1, height=2) +
      theme_bw() +
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank()
      ) +
      scale_x_continuous(breaks = c(0, 365, 730, 1095, 1460, 1825, 2190, 2555),
                         labels = c("0yr", "1yr", "2yr", "3yr", "4yr", "5yr", "6yr", "7yr")) +
      scale_y_continuous(limits=c(0,10))
ggsave(p1, filename="graphs/monitoring_event_elapsed_time.png", width=6, height=2,
       unit="in", dpi=300)


########1#########2#########3#########4#########5#########6#########7#########8
# GRAPH - historgram of plantings by record length
# how many times are plantings monitored?
###############################################################################
cat("histogram of plantings by record length....\n")

# make a histogram of freq. of plantings by record length (# monitoring events)
ungroup(monitoring_d1)
planting_monitoring_counts <- monitoring_d1 %>% 
                              group_by(planting_code) %>%
                              summarize(count = n())
p <- ggplot(data=planting_monitoring_counts, mapping=aes(x=count)) +
     geom_bar(color="seagreen4", fill="seagreen4") +
     theme_bw() +
     theme(
       axis.title = element_text(size=14),
       axis.title.x = element_text(margin=margin(t=20,b=0,l=0,r=0)),
       axis.title.y = element_text(margin=margin(t=0,b=0,l=0,r=20)),
       axis.text = element_text(size=10)
     ) +
     scale_x_continuous(name="Number of Monitoring Events", breaks=c(1,2,3,4,5,6,7,8,9,10),
                      labels=c("1","2","3","4","5","6","7","8","9","10")) +
     scale_y_continuous(name="Frequency of Plantings")
ggsave(p, filename="graphs/freq_plantings_by_num_events.png", width=6, height=4,
       unit="in", dpi=300)


cat("export tables...\n")

########1#########2#########3#########4#########5#########6#########7#########8
# EXPORT TABLE - make and export table for planting-specific monitoring graphs
# Make table of all monitoring events with planting and results attributes.
# First join results categories filter out "missing" and "conflict" cases.
# Write to file for further processing (web graphs)
###############################################################################
mon_cat_lu <- read.csv("source_data_processing/monitoring_cat_lookup.csv", 
                       header=TRUE,
                       stringsAsFactors=FALSE)
monitoring_d1a <- monitoring_d1 %>% left_join(mon_cat_lu, by="monCat") %>%
                       filter(cat2 != "missing" & cat2 != "conflict")
cat("export csv file...\n")
write.csv(monitoring_d1a, file="source_data_processing/monitoring_processed.csv",
          row.names=FALSE)


########1#########2#########3#########4#########5#########6#########7#########8
# EXPORT TABLE - make and export table of plantings with attribute indicating
# if there is associated monitoring data. Also add attribute indicating if
# most recent monitoring indicates survival or no survival.
# This will be basis for spatial layer that gives access to monitoring data
# through popup graphs.
###############################################################################
cat("export plantings monitored csv file...\n")
# read plantings table
plantings <- read.csv("source_data_processing/plantings_table.csv",
                      stringsAsFactors=FALSE)
monitored_plantings <- monitoring_d1a %>% 
                       group_by(planting_code) %>%
                       arrange(monitoring_date) %>%
                       summarize(count = n(), 
                                 status = last(statCat)) %>%
                       mutate(graphURL = str_c(urlprefix,planting_code,urlsuffix, sep=""))
                       
plantings_monitored <- plantings %>%
                       select(planting_code) %>%
                       left_join(monitored_plantings, by="planting_code") %>%
                       mutate(monitored = !(is.na(count))) %>%
                       select(-count)

write.csv(plantings_monitored, 
          file="source_data_processing/plantings_monitored_table.csv",
          row.names=FALSE)


########1#########2#########3#########4#########5#########6#########7#########8
# QA - check for planting shoot count in monitoring table not matching value
# in planting table
###############################################################################
monitoring_qa <- monitoring_d1a %>% left_join(plantings, by="planting_code") %>%
                      select(planting_code, planting_location_code, 
                             shoots_planted_count, shoot_count) %>%
                      mutate(qa_shoot_count = ifelse(shoots_planted_count==shoot_count,
                                                       "agree", "conflict")) %>%
                      group_by(qa_shoot_count) %>%
                      summarize(count=n())




########1#########2#########3#########4#########5#########6#########7#########8
# GRAPH - grid of all monitoring events by planting
###############################################################################
cat("graph monitoring events by planting...\n")

p2 <- ggplot(data=monitoring_d1a, mapping=aes(x=days_elapsed, y=planting_code, 
                                             color=cat2)) +
      geom_point() +
      theme_bw() +
      theme(
        axis.text.y = element_text(size=5),
        panel.grid.major.x = element_line(color="gray43"),
        panel.grid.minor.x = element_line(color="gray77")
      ) +
      scale_colour_manual(values=c("gray80","red","black","chartreuse2","chartreuse4"),
                          name="category") +
      scale_y_discrete(name="planting code") +
      scale_x_continuous(name="time since planting",
                         breaks=c(0,365,730,1095,1460,1825,2190,2555),
                         labels=c("0yr","1yr","2yr","3yr","4yr","5yr","6yr","7yr"),
                         minor_breaks=c(90,181,273,455,546,638,820,911,1003,1185,1276,1368,
                                        1550,1641,1733,1915,2006,2098))
ggsave(p2, filename="graphs/monitoring_pt_dist.png", width=8.5, height=14.5, unit="in", dpi=400)



                                        
# clean up
cat("cleaning up...\n")
rm("mon_cat_lu", "monitoring_d", "monitoringV0", "monitoringV1",
   "planting_monitoring_counts")

cat("done.\n")


