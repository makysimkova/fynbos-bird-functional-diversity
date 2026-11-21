# Compare FD indices between sites and draw report Figure 3.
# Shapiro-Wilk decides between a t-test and a Wilcoxon rank-sum test for each index.
# Outputs: outputs/tables/fd_summary.csv, fd_tests.csv, outputs/figures/fig3_fd_boxplots.png

fd_indices <- c(FRic = "Functional Richness", FDis = "Functional Dispersion",
                FEve = "Functional Evenness", FDiv = "Functional Divergence")

fd_long <- fd_table |>
  pivot_longer(all_of(names(fd_indices)), names_to = "index", values_to = "value")

fd_summary <- fd_long |>
  group_by(index, Location) |>
  summarise(n = n(), mean = mean(value), sd = sd(value),
            min = min(value), max = max(value), .groups = "drop")
write_csv(fd_summary, path_tables("fd_summary.csv"))

compare_sites <- function(index) {
  values  <- split(fd_table[[index]], fd_table$Location)
  normal  <- all(sapply(values, function(v) shapiro.test(v)$p.value > 0.05))
  formula <- reformulate("Location", response = index)
  result  <- if (normal) t.test(formula, data = fd_table) else
    wilcox.test(formula, data = fd_table, exact = FALSE)
  tibble(index = index, test = if (normal) "t-test" else "Wilcoxon rank-sum",
         statistic = unname(result$statistic), p_value = result$p.value)
}
fd_tests <- bind_rows(lapply(names(fd_indices), compare_sites))
write_csv(fd_tests, path_tables("fd_tests.csv"))

plot_fd <- function(index) {
  ggplot(fd_table, aes(Location, .data[[index]], fill = Location)) +
    geom_boxplot(outlier.shape = NA, alpha = 0.7) +
    geom_jitter(width = 0.12, alpha = 0.8) +
    scale_fill_manual(values = site_colours) +
    labs(y = fd_indices[[index]], x = "") +
    theme_minimal()
}

set.seed(1)  # fixes the jitter
fd_panels <- lapply(names(fd_indices), plot_fd)
fig_fd <- (fd_panels[[1]] | fd_panels[[2]]) / (fd_panels[[3]] | fd_panels[[4]])
save_fig(fig_fd, "fig3_fd_boxplots.png", width = 10, height = 7)
