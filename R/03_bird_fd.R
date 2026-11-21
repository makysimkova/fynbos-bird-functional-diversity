# Functional diversity (FRic, FEve, FDiv, FDis) of the bird community at each point count.
# Output: outputs/tables/fd_by_point.csv

trait_cols <- c(
  "Mass",
  "Beak.Length_Culmen", "Beak.Length_Nares",
  "Beak.Width", "Beak.Depth",
  "Tarsus.Length", "Wing.Length",
  "Hand.Wing.Index",
  "Trophic.Niche"
)

species_traits <- birds |>
  distinct(scientific_name, across(all_of(trait_cols))) |>
  arrange(scientific_name) |>
  column_to_rownames("scientific_name") |>
  mutate(Trophic.Niche = factor(Trophic.Niche))

# Points x species abundance matrix, species in the same order as the trait table
abundance <- birds |>
  group_by(ID, scientific_name) |>
  summarise(Abundance = sum(Count), .groups = "drop") |>
  pivot_wider(names_from = scientific_name, values_from = Abundance, values_fill = 0) |>
  column_to_rownames("ID")
abundance <- as.matrix(abundance[, rownames(species_traits)])

fd_res <- dbFD(
  x = species_traits,
  a = abundance,
  calc.FRic = TRUE,
  calc.FDiv = TRUE,
  corr = "cailliez",
  stand.x = TRUE,
  w.abun = TRUE,
  messages = FALSE
)

fd_table <- tibble(
  ID   = rownames(abundance),
  FRic = unname(fd_res$FRic),
  FEve = unname(fd_res$FEve),
  FDiv = unname(fd_res$FDiv),
  FDis = unname(fd_res$FDis)
) |>
  left_join(distinct(birds, ID, Location), by = "ID") |>
  relocate(Location, .after = ID)

write_csv(fd_table, path_tables("fd_by_point.csv"))
