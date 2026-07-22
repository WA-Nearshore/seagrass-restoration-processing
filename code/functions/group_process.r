###############################################################################
#  group_process()
#
#  Function to be used when summarizing grouped data. When passed a vector
#  of values for a particular variable that has been grouped, the function
#  reduced the vector to a single value that is returned.
#  
#  If there is a single unique, non-NA value in the vector, this value is 
#  returned.  If multiple values, "multiple" is returned.
#
###############################################################################



# define function to use in summarization - reduces vector to single value
group_process_numeric <- function(indata) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    return(as.numeric(NA))
  } else if (n1 ==1) {
    return(as.numeric(indata_cln[1]))
  } else if (n1 > 1) {
    return(222)
  }
}


group_process_char <- function(indata) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    return(as.character(NA))
  } else if (n1 == 1) {
    return(as.character(indata_cln[1])) 
  } else if (n1 > 1) {
    return("multiple")
  }
}

group_process_date <- function(indata) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    return(as.Date(NA))
  } else if (n1 == 1) {
    return(as.Date(indata_cln[1]))    
  } else if (n1 > 1) {
    return(as.Date("2000-01-01"))
  }
}

group_process_planting_name <- function(indata, gps_name_to_planting_name_tbl) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    return(as.character(NA))
  } else if (n1 == 1) {
    return(as.character(indata_cln[1])) 
  } else if (n1 > 1) {
    # join plnating naems onto the gps-pt-names
    gps_pt_names <- data.frame(gps_pt_names = indata)
    gps_pt_names_jn <-  gps_pt_names %>%
      left_join(gps_name_to_planting_name_tbl, by=c("gps_pt_names" = "site_name"))
    if (length(unique(gps_pt_names_jn$planting_name)) > 1) {
      print(" ")
      print("ERROR - gps_pt_name conversion, group process.")
      print(" ")
    }
    return(gps_pt_names_jn$planting_name[1])
  }
}


