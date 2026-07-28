#########1#########2#########3#########4#########5#########6#########7#########8
#
# Script to import all seagrass restoration planting GPS points into ArcGIS
# to produce a restoration "area" layer that contains polygons that represent each
# area. This script also summarizes the point data to generate area
# total shoot count.
#
# This script also creates a join table of shoot count by planting method.
# This table has planting method as columns and area as rows.
#
# Inputs:  source_data_processing/planting_pts_all.csv
#          source_data_processing/area_method_join_table.csv
#
# Outputs: GIS_storymap_prep2/GIS_storymap_prep2.gdb/areas
#
# October 2019
#
################################################################################

import arcpy

arcpy.env.overwriteOutput = True

# set workspace
home = "K:/projects/Eelgrass_Restoration/Restoration_Storymap/2019_06/"
# home = "C:/Users/pete/OneDrive/Work-current/Restoration_Storymap/2019_06/"
homegdb = home + "GIS_storymap_prep2/GIS_storymap_prep2.gdb"
arcpy.env.workspace = homegdb

# set paths to input csv files
in_plantings = arcpy.env.workspace + "/plantings_table"
in_pts_all_csv = home + "source_data_processing/planting_pts_all.csv"
in_method_join_table_csv = home + "source_data_processing/area_method_join_table.csv"

# output feature classes
out_pts_all_geo = arcpy.env.workspace + "/planting_pts_all_geo"
out_pts_all_prj = arcpy.env.workspace + "/planting_pts_all_prj"
out_pts_all_buffer = arcpy.env.workspace + "/planting_pts_all_buffer"
out_locations = arcpy.env.workspace + "/restoration_areas"
out_location_shoot_count = arcpy.env.workspace + "/area_join_table"
out_method_shoot_count_fc = "area_method_join_table"
out_method_shoot_count = arcpy.env.workspace + "/" + out_method_shoot_count_fc


# set spatial reference
spref_geo = "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]];-400 -400 1000000000;-100000 10000;-100000 10000;8.98315284119521E-09;0.001;0.001;IsHighPrecision"
spref_StPl = "PROJCS['NAD_1983_HARN_StatePlane_Washington_South_FIPS_4602_Feet',GEOGCS['GCS_North_American_1983_HARN',DATUM['D_North_American_1983_HARN',SPHEROID['GRS_1980',6378137.0,298.257222101]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Lambert_Conformal_Conic'],PARAMETER['False_Easting',1640416.666666667],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',-120.5],PARAMETER['Standard_Parallel_1',45.83333333333334],PARAMETER['Standard_Parallel_2',47.33333333333334],PARAMETER['Latitude_Of_Origin',45.33333333333334],UNIT['Foot_US',0.3048006096012192]]"


print("read in csv files...")
arcpy.XYTableToPoint_management(in_table=in_pts_all_csv,
                                out_feature_class=out_pts_all_geo,
                                x_field="longitude",
                                y_field="latitude",
                                coordinate_system=spref_geo)
arcpy.TableToTable_conversion(in_rows=in_method_join_table_csv,
                              out_path=arcpy.env.workspace,
                              out_name=out_method_shoot_count_fc)

print("projecting all planting points ...")
arcpy.Project_management(in_dataset=out_pts_all_geo,
                         out_dataset=out_pts_all_prj,
                         out_coor_system=spref_StPl,
                         transform_method="NAD_1983_HARN_To_WGS_1984_2",
                         in_coor_system=spref_geo,
                         preserve_shape="NO_PRESERVE_SHAPE",
                         max_deviation=None,
                         vertical="NO_VERTICAL")

print("buffering all planting points ...")
arcpy.Buffer_analysis(in_features=out_pts_all_prj,
                      out_feature_class=out_pts_all_buffer,
                      buffer_distance_or_field="1000 feet",
                      line_side="FULL",
                      dissolve_option="LIST",
                      dissolve_field="restoration_area",
                      method="PLANAR")

print("getting convex hull of location buffers ...")
arcpy.MinimumBoundingGeometry_management(in_features=out_pts_all_buffer,
                                         out_feature_class=out_locations,
                                         geometry_type="CONVEX_HULL",
                                         group_option="LIST",
                                         group_field="restoration_area")

print("summarizing location shoot count totals ...")
statfield=[["shoot_count", "Sum"]]
arcpy.Statistics_analysis(in_table=in_plantings,
                          out_table=out_location_shoot_count,
                          statistics_fields=statfield,
                          case_field="restoration_area")

print("joining total and planting method shoot counts ...")
arcpy.JoinField_management(in_data=out_locations,
                           in_field="restoration_area",
                           join_table=out_location_shoot_count,
                           join_field="restoration_area")
arcpy.JoinField_management(in_data=out_locations,
                           in_field="restoration_area",
                           join_table=out_method_shoot_count,
                           join_field="restoration_area")


# clean up
print("cleaning up...")
arcpy.Delete_management(out_pts_all_geo)
arcpy.Delete_management(out_pts_all_prj)
arcpy.Delete_management(out_pts_all_buffer)

dropFields = ["restoration_area_1", "FREQUENCY", "restoration_area_12"]
arcpy.DeleteField_management(in_table=out_locations,
                             drop_field=dropFields)



