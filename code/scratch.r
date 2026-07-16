# scratch when developing, testing

# isolate BESE plantings & monitoring to review
bese_plantings <- plantings %>%
  filter(str_detect(planting_name, "BESE"))
grid_plantings <- plantings %>%
  filter(str_detect(planting_name, "method"))

bese_monitor <- mon_tbl_1 %>% filter(str_detect(site_name, "BESE"))
grid_monitor <- mon_tbl_1 %>% filter(str_detect(site_name, "methods"))

bese_monitor_summ <- bese_monitor %>% group_by(site_name) %>%
  summarize(count = n())
grid_monitor_summ <- grid_monitor %>% group_by(site_name) %>%
  summarize(count=n())

bese_plantings_jn <- bese_plantings %>%
  left_join(bese_monitor_summ, by=c("planting_name" = "site_name")) %>%
  select(planting_name, planting_date, donor_site_code, count)

grid_plantings_jn <- grid_plantings %>% 
  left_join(grid_monitor_summ, by=c("planting_name" = "site_name")) %>%
  select(planting_name, planting_date, donor_site_code, count)


# to view BESE p_gps_pt records
p_gps_bese <- p_gps_pts1 %>% filter(str_detect(site_name, "BESE"))

# to view 'method' monitoring records
mon_methods <- mon_tbl_1 %>% filter(str_detect(site_name, "methods"))



# to inspect site_names for plantings with multiple names (multiple gps pts)
p_gps_pts_planting_jn_sel <- p_gps_pts1 %>%
  left_join(plantings, by="plantingID") %>%
  select(site_name, plantingID, planting_name)

p_gps_pts_planting_jn_sel_filt <- p_gps_pts_planting_jn_sel %>%
  filter(planting_name == "multiple")


# get how many plantings have multiple site names
sum(plantings$planting_name == "multiple")





a <- is.na(mon_tbl_planting_qa$planted_area_m2.x)
b <- is.na(mon_tbl_planting_qa$planted_area_m2.y)


c <- is.numeric(mon_tbl_planting_qa$planted_area_m2.x)
d <- is.numeric(mon_tbl_planting_qa$planted_area_m2.y)


e <- near(mon_tbl_planting_qa$planted_area_m2.x, 
          mon_tbl_planting_qa$planted_area_m2.y)

test <- mon_tbl_planting_qa  %>%
  drop_na(planted_area_m2.x, planted_area_m2.y) %>%
  filter(!(is.numeric(planted_area_m2.x)),
         !(is.numeric(planted_area_m2.y)))





# check if unique donor site names from p_gps_pts are matched by donor site
# names in the donor_sites table from the matrix
p_gps_pts_donor_sites <- data.frame(donor_site_name = unique(p_gps_pts1$donor_site_name))
not_matched <- p_gps_pts_donor_sites %>%
  anti_join(donor_sites, by = join_by(donor_site_name==site_name))


# for map review, make sf object of all donor sites with gps coords from 
# donor sites matrix table
donor_pts_cln_StPl <- donor_sites %>%
  drop_na(lat, long) %>%
  st_as_sf(coords = c("long", "lat"), crs=4326) %>%
  st_transform(crs=2927)

st_write(donor_pts_cln_StPl, dsn=pathFGDB, layer="donor_sites_sheet", 
           driver="OpenFileGDB", delete_layer=TRUE)


# isolate all Anderson donor cases to understand 'Anderson'
anderson_p_gps_pts <- p_gps_pts1 %>%
  filter(donor_site_name == "Anderson Island" |
         donor_site_name == "Anderson Island, Windy Bluff" |
         donor_site_name == "Sandy Point" |
         donor_site_name == "Thompson Cove")
anderson_p_gps_pts_sel <- anderson_p_gps_pts %>%
  select(site_name, activity_type, planting_date,
         donor_site_name, subproj_code)



# isolate gps_pts donor site list and donor_sites sheet site list
gps_pts_donor_sites <- data.frame(
  donor_site_names = unique(p_gps_pts1$donor_site_name)
)
donor_site_sheet_sites <- data.frame(
  donor_site_names = unique(donor_sites$site_name)
)
write.csv(gps_pts_donor_sites, file="output_tables/gps_pts_donor_sites.csv")
write.csv(donor_site_sheet_sites, file="output_tables/donor_site_sheet_sites.csv")



# count cases of gps records with donor site Anderson Island
p_gps_pts_AND <- p_gps_pts1 %>%
  filter(donor_site_name == "Anderson Island")


# count mixed donor site cases
n_both_cases <- sum(planting_summ$donor_site_code_summ2 == "Mix")
n_fieldMixCases <- sum(planting_summ$donor_site_name_summ == "Mixed")
n_fieldListCases <- n_both_cases - n_fieldMixCases

donor_usage_expansion <- n_fieldMixCases * 4 + n_fieldListCases * 2











