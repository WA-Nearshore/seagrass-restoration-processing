#########1#########2#########3#########4#########5#########6#########7#########8
#
# Script to import seagrass restoration planting tables into ArcGIS and
# project from lat/lon geographic coords to DNR State Plane projection.
#
# Inputs:  source_data_processing/planting_pt.csv
#          source_data_processing/planting_ln.csv
#          source_data_processing/planting_poly.csv
#          source_data_processing/plantings_table.csv
#
# Outputs: GIS_storymap_prep2/GIS_storymap_prep2.gdb/planting_pt
#          GIS_storymap_prep2/GIS_storymap_prep2.gdb/planting_ln
#          GIS_storymap_prep2/GIS_storymap_prep2.gdb/planting_poly
#          GIS_storymap_prep2/GIS_storymap_prep2.gdb/plantings_table
#          GIS_storymap_prep2/GIS_storymap_prep2.gdb/planting_pt_all
#          source_data_processing/planting_centroids.csv
#
#
# October 2019
#
################################################################################

import arcpy

arcpy.env.overwriteOutput = True

# set workspace
home = "K:/projects/Eelgrass_Restoration/Restoration_Storymap/2019_06/"
# home = "C:/Users/pete/OneDrive/Work-current/Restoration_Storymap/2019_06/"
arcpy.env.workspace = home + "GIS_storymap_prep2/GIS_storymap_prep2.gdb"

# set paths to input/output csv files
in_pt_csv = home + "source_data_processing/planting_pt.csv"
in_ln_csv = home + "source_data_processing/planting_ln.csv"
in_poly_csv = home + "source_data_processing/planting_poly.csv"
in_planting_csv = home + "source_data_processing/plantings_table.csv"
csvoutput_path = home + "/source_data_processing"


# set paths to interim output feature classes
out_pt_geo = arcpy.env.workspace + "/planting_pt_geo"
out_ln_geo = arcpy.env.workspace + "/planting_ln_geo"
out_poly_geo = arcpy.env.workspace + "/planting_poly_geo"

out_ln_prj = arcpy.env.workspace + "/planting_ln_prj"
out_poly_prj = arcpy.env.workspace + "/planting_poly_prj"

out_poly_prj_to_ln = arcpy.env.workspace + "/planting_poly_prj_ln"

out_poly_centroid = arcpy.env.workspace + "/planting_poly_centroid"
out_ln_centroid = arcpy.env.workspace + "/planting_ln_centroid"
planting_centroids = arcpy.env.workspace + "/planting_pt_all"
out_poly_centroid_geo = arcpy.env.workspace + "/planting_poly_centroid_geo"
out_ln_centroid_geo = arcpy.env.workspace + "/planting_ln_centroid_geo"
planting_centroids_geo = arcpy.env.workspace + "/planting_centroids_geo"


# set paths to final output feature classes (plantings_table above is also an output)
out_pt_prj = arcpy.env.workspace + "/plantings_pt"
out_ln_prj_to_ln = arcpy.env.workspace + "/plantings_ln"
out_poly_prj_to_poly = arcpy.env.workspace + "/plantings_poly"

# set spatial reference
spref_geo = "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]];-400 -400 1000000000;-100000 10000;-100000 10000;8.98315284119521E-09;0.001;0.001;IsHighPrecision"
spref_StPl = "PROJCS['NAD_1983_HARN_StatePlane_Washington_South_FIPS_4602_Feet',GEOGCS['GCS_North_American_1983_HARN',DATUM['D_North_American_1983_HARN',SPHEROID['GRS_1980',6378137.0,298.257222101]],PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]],PROJECTION['Lambert_Conformal_Conic'],PARAMETER['False_Easting',1640416.666666667],PARAMETER['False_Northing',0.0],PARAMETER['Central_Meridian',-120.5],PARAMETER['Standard_Parallel_1',45.83333333333334],PARAMETER['Standard_Parallel_2',47.33333333333334],PARAMETER['Latitude_Of_Origin',45.33333333333334],UNIT['Foot_US',0.3048006096012192]]"



# import planting tables from csv to point/cluster/line/polygon feature classes and table
print("\nImporting planting layers ....")
arcpy.XYTableToPoint_management(in_table=in_pt_csv,
                                out_feature_class=out_pt_geo,
                                x_field="longitude",
                                y_field="latitude",
                                coordinate_system=spref_geo)
arcpy.XYTableToPoint_management(in_table=in_ln_csv,
                                out_feature_class=out_ln_geo,
                                x_field="longitude",
                                y_field="latitude",
                                coordinate_system=spref_geo)
arcpy.XYTableToPoint_management(in_table=in_poly_csv,
                                out_feature_class=out_poly_geo,
                                x_field="longitude",
                                y_field="latitude",
                                coordinate_system=spref_geo)
arcpy.TableToGeodatabase_conversion(Input_Table=in_planting_csv,
                                    Output_Geodatabase=arcpy.env.workspace)


print("Projecting...")
arcpy.Project_management(in_dataset=out_pt_geo,
                         out_dataset=out_pt_prj,
                         out_coor_system=spref_StPl,
                         transform_method="NAD_1983_HARN_To_WGS_1984_2",
                         in_coor_system=spref_geo,
                         preserve_shape="NO_PRESERVE_SHAPE",
                         max_deviation=None,
                         vertical="NO_VERTICAL")
arcpy.Project_management(in_dataset=out_ln_geo,
                         out_dataset=out_ln_prj,
                         out_coor_system=spref_StPl,
                         transform_method="NAD_1983_HARN_To_WGS_1984_2",
                         in_coor_system=spref_geo,
                         preserve_shape="NO_PRESERVE_SHAPE",
                         max_deviation=None,
                         vertical="NO_VERTICAL")
arcpy.Project_management(in_dataset=out_poly_geo,
                         out_dataset=out_poly_prj,
                         out_coor_system=spref_StPl,
                         transform_method="NAD_1983_HARN_To_WGS_1984_2",
                         in_coor_system=spref_geo,
                         preserve_shape="NO_PRESERVE_SHAPE",
                         max_deviation=None,
                         vertical="NO_VERTICAL")


print("grouping points to line...")
arcpy.PointsToLine_management(Input_Features=out_ln_prj,
                              Output_Feature_Class=out_ln_prj_to_ln,
                              Line_Field="planting_code",
                              Close_Line="NO_CLOSE")

print("grouping points to polygon...")
arcpy.MinimumBoundingGeometry_management(in_features=out_poly_prj,
                                         out_feature_class=out_poly_prj_to_poly,
                                         geometry_type="CONVEX_HULL",
                                         group_option="LIST",
                                         group_field=["planting_code"])

print("getting centroids, adding lat/long and exporting merged plantings to csv ...")
# get centroid points
arcpy.FeatureToPoint_management(in_features=out_ln_prj_to_ln,
                                out_feature_class=out_ln_centroid,
                                point_location="CENTROID")
arcpy.FeatureToPoint_management(in_features=out_poly_prj_to_poly,
                                out_feature_class=out_poly_centroid,
                               point_location="CENTROID")
# merge planting points, line centroids and poly centroids into one pt layer
inputs = [out_pt_prj, out_ln_centroid, out_poly_centroid]
arcpy.Merge_management(inputs=inputs,
                       output=planting_centroids)
# project to geographic lat/lon
arcpy.Project_management(in_dataset=planting_centroids,
                         out_dataset=planting_centroids_geo,
                         out_coor_system=spref_geo,
                         transform_method="NAD_1983_HARN_To_WGS_1984_2",
                         in_coor_system=spref_StPl,
                         preserve_shape="NO_PRESERVE_SHAPE",
                         max_deviation=None,
                         vertical="NO_VERTICAL")
# add fields to hold lat/long coordinates
arcpy.AddField_management(in_table=planting_centroids_geo,
                          field_name="lat",
                          field_type="DOUBLE")
arcpy.AddField_management(in_table=planting_centroids_geo,
                          field_name="long",
                          field_type="DOUBLE")
# add lat/lon coordinates
arcpy.CalculateGeometryAttributes_management(in_features=planting_centroids_geo,
                                             geometry_property=[["long","POINT_X"],
                                                                ["lat" ,"POINT_Y"]])
# export as csv
arcpy.TableToTable_conversion(in_rows=planting_centroids_geo,
                              out_path=csvoutput_path,
                              out_name="planting_centroids.csv")



print("joining attributes...")
arcpy.JoinField_management(in_data=out_ln_prj_to_ln,
                           in_field="planting_code",
                           join_table=in_planting_csv,
                           join_field="planting_code")
arcpy.JoinField_management(in_data=out_poly_prj_to_poly,
                           in_field="planting_code",
                           join_table=in_planting_csv,
                           join_field="planting_code")



print("\nCleaning up...")
arcpy.Delete_management(out_pt_geo)
arcpy.Delete_management(out_ln_geo)
arcpy.Delete_management(out_poly_geo)
arcpy.Delete_management(out_ln_prj)
arcpy.Delete_management(out_poly_prj)
arcpy.Delete_management(out_poly_prj_to_ln)
arcpy.Delete_management(out_ln_centroid)
arcpy.Delete_management(out_poly_centroid)
arcpy.Delete_management(planting_centroids_geo)





