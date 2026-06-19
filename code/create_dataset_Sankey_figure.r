# make Sankey diagram showing relationships between categories in
# seagrass restoration dataset

library(tidyverse)
library(networkD3)

df <- read.csv("figures/planting_Sankey_data_v2.csv",stringsAsFactors=FALSE)


# From these flows we need to create a node data frame: it lists every entity 
# involved in the flow
links <- df 
nodes <- data.frame(
  name=c(as.character(links$Source), 
         as.character(links$Target)) %>% unique()
)
# With networkD3, connection must be provided using id, not using real name 
# like in the links dataframe.. So we need to reformat it.
links$IDsource <- match(links$Source, nodes$name)-1 
links$IDtarget <- match(links$Target, nodes$name)-1

# Make the Network
p2 <- sankeyNetwork(Links = links, Nodes = nodes,
                   Source = "IDsource", Target = "IDtarget",
                   Value = "Value", NodeID = "name", 
                   fontSize=8,
                   sinksRight=FALSE)