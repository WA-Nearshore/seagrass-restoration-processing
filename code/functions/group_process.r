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
group_process <- function(indata) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    print(sprintf("Error: a group is all NA: %d  %d",n0,n1))
    return(NA)
  }
  else if (n1 == 1) {
   return(indata_cln[1])
  } else if (n1 > 1) {
   return("multiple") 
  }
}