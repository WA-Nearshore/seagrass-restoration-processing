###############################################################################
#
#  create_prj()
#
#  This function takes the planting_gps_pt table and extracts the project
#  attributes into a separate table related by a new sub-project code as key.
#
#  The script returns a list containing two data frames: 
#    1. the sub-project table
#    2. updated planting_gps_pts with project attributes removed 
#
#  April 2026
#
###############################################################################

library(tidyverse)
source("code/config_prj_codes.r")


# function to reduce data in summarize function below
distill_vals <- function(in_values) {
  uniqvals <- unique(in_values)
  uniqvals_clean <- na.omit(uniqvals)
  if (length(uniqvals_clean) == 0) {
    return(NA)
  } else if (length(uniqvals_clean) == 1) {
    return(uniqvals_clean[1])
  } else if (length(uniqvals_clean) > 1) {
    return("multiple_values")
  }
}
  
  

##########################################################################
# main function in this file, create_prj()
##########################################################################
create_prj <- function(p_gps_pts_cln) {
  
  # edit records with NA in project name, funding_source, contractor fields
  p_gps_pts_cln2 <- p_gps_pts_cln %>%
    mutate(project_name = if_else(is.na(project_name) & is.na(funding_source),
                                  "unaffiliated", project_name),
           project_name = if_else(is.na(project_name) & (funding_source == "DNR"),
                                  "DNR", project_name),
           funding_source = if_else(is.na(funding_source), "unspecified",
                                    funding_source),
           contractor = if_else(is.na(contractor), "unspecified", contractor)
           )

   
  ###############################################
  # join project codes & revised proj names
  ###############################################
  
  # check if project names in input data match codes from config file
  unknown_prj <- p_gps_pts_cln2 %>% 
      anti_join(prj_codes,  by = join_by(project_name == prj_names_in))
  # write out the number of planting_gps_pt records not matched with project
  if (dim(unknown_prj)[1] > 0) {
    print(sprintf("%d cases of planting_gps_pt records not matched with project",
                  dim(unknown_prj)[1]))
  }
  # join project config columns onto planting_gps_pts (prj codes & revised names)
  p_gps_pts_jn <- p_gps_pts_cln2 %>%
    left_join(prj_codes, by = join_by(project_name == prj_names_in))
  
   
  ###############################################
  # create sub-project table 
  ###############################################
  
  # add sub-project code to planting gps pt table (p_gps_pts_jn) that distinguishes
  # sponsors/contractors under same project.
  p_gps_pts_jn_code <- p_gps_pts_jn %>%
    mutate(subproj_code = str_c(prj_codes,str_remove_all(funding_source," "),
                                contractor, sep="__"))
  
  # select columns with project attributes 
  prj_col_names <- c("subproj_code","prj_codes","project_name", "prj_names_out",
                     "funding_source",
                     "funding_source_program","sponsor_contract_number",
                     "sponsor_contract_dnr_number","contractor",
                     "contract_dnr_number","citation")
  sel_prj <- p_gps_pts_jn_code %>% select(all_of(prj_col_names))
  
  # Make sub-project table by summarizing on code and attempt to
  # collapse gps-pt records intellegently using distill_vals().
  sub_projects <- sel_prj %>% group_by(subproj_code) %>%
    summarize(n_gps_recs=n(), 
              prj_code = distill_vals(prj_codes), 
              prj_name = distill_vals(prj_names_out),
              funding_source = distill_vals(funding_source), 
              funding_source_program = distill_vals(funding_source_program),
              sponsor_contract_number = distill_vals(sponsor_contract_number), 
              sponsor_contract_dnr_number = distill_vals(sponsor_contract_dnr_number),
              contractor = distill_vals(contractor), 
              contract_dnr_number = distill_vals(contract_dnr_number),
              citation = distill_vals(citation))
 
  # remove project attributes from planting gps points, leaving subproj_code
  # as a foreign key to relate to :the subprojects table
  prj_col_names2 <- str_subset(prj_col_names,"subproj_code", negate=TRUE)
  p_gps_pts_revised <- p_gps_pts_jn_code %>% select(-all_of(prj_col_names2))
   
  # create return object - a list containing two tables
  return_obj <- list(sub_projects, p_gps_pts_revised)
  
  return(return_obj)
}


