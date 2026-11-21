# Reproduces every table and figure from data/raw/.
# Run from the project root:  Rscript run_all.R
# The maps (05_maps.R) need Google Chrome or Chromium for the screenshots.

scripts <- c(
  "00_setup.R",
  "01_clean_join.R",
  "02_vegetation_composition.R",
  "03_bird_fd.R",
  "04_fd_stats_figures.R",
  "05_maps.R"
)

for (script in scripts) {
  message("Running ", script)
  source(file.path("R", script))
}
