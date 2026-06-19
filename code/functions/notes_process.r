###############################################################################
#  notes_process()
#
#  Function to be used when summarizing grouped data. When passed a vector
#  of values specifically for the notes variable that has been grouped, the 
#  function concatenates the notes. 
#  
###############################################################################



# define function to use in summarization - reduces vector to single value
notes_process <- function(indata) {
  n0 <- length(indata)
  indata_cln <- na.omit(indata)
  n1 <- length(unique(indata_cln))
  if (n1 == 0) {
    return("None.")
  }
  else if (n1 == 1) {
    return(indata_cln[1])
  } else if (n1 > 1) {
   return(str_flatten(n1, collapse=". "))
  }
}