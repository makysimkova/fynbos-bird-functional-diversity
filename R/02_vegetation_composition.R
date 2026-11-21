# Plant family composition by site: Bray-Curtis dissimilarity, PERMANOVA and PCoA.
# The three quadrats per point are pooled and counts square-root transformed.
# Outputs: outputs/tables/permanova.csv, outputs/figures/figS1_vegetation_pcoa.png,
#          outputs/figures/figS2_top_families.png

community <- plants |>
  group_by(ID, Family) |>
  summarise(Count = sum(Count), .groups = "drop") |>
  pivot_wider(names_from = Family, values_from = Count, values_fill = 0) |>
  column_to_rownames("ID")

point_sites <- plants |>
  distinct(ID, Location) |>
  column_to_rownames("ID")
point_sites <- point_sites[rownames(community), , drop = FALSE]

community_sqrt <- sqrt(community)
bray <- vegdist(community_sqrt, method = "bray")

set.seed(1)
permanova <- adonis2(community_sqrt ~ Location, data = point_sites, permutations = 999)
write_csv(rownames_to_column(as.data.frame(permanova), "term"), path_tables("permanova.csv"))

pcoa <- cmdscale(bray, eig = TRUE, k = 2)
variance_explained <- round(pcoa$eig[1:2] / sum(pcoa$eig) * 100, 1)
pcoa_scores <- tibble(
  ID       = rownames(community),
  PCoA1    = pcoa$points[, 1],
  PCoA2    = pcoa$points[, 2],
  Location = point_sites$Location
)

fig_pcoa <- ggplot(pcoa_scores, aes(PCoA1, PCoA2, colour = Location)) +
  geom_point(size = 3, alpha = 0.8) +
  labs(x = paste0("PCoA1 (", variance_explained[1], "%)"),
       y = paste0("PCoA2 (", variance_explained[2], "%)"), colour = NULL) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "bottom")
save_fig(fig_pcoa, "figS1_vegetation_pcoa.png")

top_families <- plants |>
  group_by(Location, Family) |>
  summarise(Total_Count = sum(Count), .groups = "drop") |>
  group_by(Location) |>
  slice_max(Total_Count, n = 5) |>
  ungroup()

fig_families <- ggplot(top_families, aes(reorder(Family, Total_Count), Total_Count, fill = Location)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~ Location, scales = "free_y") +
  labs(x = NULL, y = "Individuals counted") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")
save_fig(fig_families, "figS2_top_families.png", width = 9, height = 4.5)
