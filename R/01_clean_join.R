# Clean the bird point counts, attach scientific names and AVONET traits,
# and tidy the plant quadrat data.
# Outputs: data/processed/bird_counts_traits.csv, data/processed/plant_quadrats_clean.csv

name_map <- read_csv(path_raw("species_name_map.csv"), show_col_types = FALSE)
traits   <- read_csv(path_raw("avonet_traits_subset.csv"), show_col_types = FALSE)

birds_raw <- read_csv(path_raw("bird_counts.csv"), show_col_types = FALSE) |>
  rename(lat = `Latitude (S)`, lon = `Longitude (E)`) |>
  mutate(Species = str_trim(Species))

# Records identified only to genus ("sp.") have no scientific name and are dropped;
# species without an AVONET match are dropped by the inner join, as in the report.
birds <- birds_raw |>
  left_join(name_map, by = c("Species" = "species")) |>
  filter(!is.na(scientific_name)) |>
  inner_join(traits, by = "scientific_name")

stopifnot(
  n_distinct(birds_raw$ID) == 50,
  n_distinct(birds$scientific_name) == 64,
  nrow(birds) == 443
)

write_csv(birds, path_processed("bird_counts_traits.csv"))

plants <- read_csv(path_raw("plant_quadrats.csv"), show_col_types = FALSE, name_repair = "unique_quiet") |>
  select(Location, ID, Quadrat = `Quadrat No`, Latitude, Longitude, Family, Count) |>
  filter(!is.na(ID), !is.na(Family), !is.na(Count))

write_csv(plants, path_processed("plant_quadrats_clean.csv"))
