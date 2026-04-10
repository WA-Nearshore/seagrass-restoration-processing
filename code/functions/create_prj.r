###############################################################################
#
#  create_prj()
#
#  This function takes the planting_gps_pt table and extracts the project
#  information into a separate table related by new project codes.
#
#  The script returns a list containing two data frames: 
#    1. the project table
#    2. updated planting_gps_pts (names: p_gps_pts_filt_prj)
#
#  April 2026
#
###############################################################################

source("code/config_prj_codes.r")


# function to process data in summarize function below
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
  
  

# main function in this file, create_prj()
create_prj <- function(p_gps_pts_cln) {
  
  # edit records with NA in project name, funding_source, contractor fields
  p_gps_pts_cln2 <- p_gps_pts_cln %>%
    mutate(project_name = if_else(is.na(project_name) & is.na(funding_source),
                                  "unaffiliated", project_name),
           project_name = if_else(is.na(project_name) & (funding_source == "DNR"),
                                  "DNR", project_name),
           funding_source = if_else(is.na(funding_source), "unspecified",
                                    funding_source),
           contractor = if_else(is.na(contractor), "9999", contractor)
           )
 
   
  ###############################################
  # join project codes
  ###############################################
  
  # check on project names in input data have codes from config file
  unknown_prj <- p_gps_pts_cln2 %>% 
      anti_join(prj_codes,  by = join_by(project_name == prj_names_in))
  # write out the number of planting_gps_pt records not matched with project
  if (dim(unknown_prj)[1] > 0) {
    print(sprintf("%d cases of planting_gps_pt records not matched with project",
                  dim(unknown_prj)[1]))
  }
  # join project config onto planting_gps_pts
  p_gps_pts_jn <- p_gps_pts_cln2 %>%
    left_join(prj_codes, by = join_by(project_name == prj_names_in))
  
 
   
  ###############################################
  # create sub-project table 
  ###############################################
 
  # select columns related to project
  sel_prj <- p_gps_pts_jn %>%
    select(prj_codes, prj_names_out, funding_source, funding_source_program,
           sponsor_contract_number, sponsor_contract_dnr_number,
           contractor, contract_dnr_number, citation)
  # add sub-project code that distinguishes different sponsors/contractors
  sel_prj_add <- sel_prj %>%
    mutate(subproj_code = str_c(prj_codes,funding_source,contractor, sep="__"))
  sum_subprj_code <- sel_prj_add %>%
    group_by(subproj_code) %>%
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
  
# return (1) p_gps_pts with project vars removed and subproject code present
# (2) the subproject table
  
  return(sum_sumprj_code)
}
