# scratch when developing, testing


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











