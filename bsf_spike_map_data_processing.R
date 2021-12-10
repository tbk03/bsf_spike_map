library(sf)
library(tidyverse)
library(rmapshaper)


# # prepare shapefile for uploading to datawrapper
# shape_file_name <- "Counties_and_Unitary_Authorities_(December_2019)_Boundaries_UK_BUC.shp"
# shape_file_path <- "geospatial_data/vector/UK/Counties_and_Unitary_Authorities_(December_2019)_Boundaries_UK_BUC/"
#
# counties_and_UAs <- st_read(str_c("../../", shape_file_path, shape_file_name)) %>%
#
#   # filter to England only
#   filter(str_detect(ctyua19cd, "^E")) %>%
#
#   # set crs to WGS 84 (as required by datawrapper)
#   st_transform(crs = 4326)
#
# # simplify polygons
# counties_and_UAs_simp <- ms_simplify(counties_and_UAs, keep = 0.8,
#                                      keep_shapes = FALSE)
#
# # plot polygons to check what simplification look like
# ggplot() +
#   geom_sf(data = counties_and_UAs_simp)
#
#
# # write simplified shapefile to GeoJSON format for import to datawrapper
# st_write(counties_and_UAs_simp, "Counties_and_Unitary_Authorities_(December_2019)_Boundaries_UK_BUC.JSON",
#            driver = "geojson", delete_dsn = TRUE)

# prepare shapefile for uploading to datawrapper
shape_file_name <- "Local_Authority_Districts_(May_2021)_UK_BUC.shp"
shape_file_path <- "geospatial_data/vector/UK/Local_Authority_Districts_(May_2021)_UK_BUC/"

las <- st_read(str_c("../../", shape_file_path, shape_file_name)) %>%

  # filter to England only
  filter(str_detect(LAD21CD, "^E")) %>%

  # set crs to WGS 84 (as required by datawrapper)
  st_transform(crs = 4326)

# simplify polygons
las_simp <- ms_simplify(las, keep = 0.01,
                                     keep_shapes = FALSE)

# plot polygons to check what shape file looks like
ggplot() +
  geom_sf(data = las)


# write simplified shapefile to GeoJSON format for import to datawrapper
st_write(las, "Local_Authority_Districts_(May_2021)_UK_BUC.JSON",
         driver = "geojson", delete_dsn = TRUE)



# read in BSF application data by LA
bsf_apps <- read_csv("bsf_reg_la_20211209.csv") %>%
  janitor::clean_names() %>%
  rename(LAD21NM = local_authority) %>%
  left_join(las) %>%
  select(LAD21NM, LAD21CD, count, LONG, LAT)

write_csv(bsf_apps,"bsf_apps.csv")

# output for qgis- following instructions here to create the 3D map
# https://aurelienchaumet.github.io/realisations/spikes_map_en/
bsf_df <- read_csv("bsf_reg_la_20211209.csv") %>%
  janitor::clean_names() %>%
  rename(LAD21NM = local_authority)

las %>%
  left_join(bsf_df) %>%
  select(bsf_app_coun = count) %>%
  mutate(bsf_app_coun = replace_na(bsf_app_coun, 1)) %>%
  st_write("bsf_app_by_la.gpkg", delete_dsn = TRUE)

