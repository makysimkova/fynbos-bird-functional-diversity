# Packages, paths and shared plotting settings used by every script.

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
  library(tibble)
  library(stringr)
  library(ggplot2)
  library(patchwork)
  library(FD)
  library(vegan)
  library(png)
  library(curl)
  library(here)
})

path_raw       <- function(...) here("data", "raw", ...)
path_processed <- function(...) here("data", "processed", ...)
path_figures   <- function(...) here("outputs", "figures", ...)
path_tables    <- function(...) here("outputs", "tables", ...)

# Colours used in the report
site_colours <- c("Klipbokkop" = "#377EB8", "Farm" = "red4")

save_fig <- function(plot, filename, width = 7, height = 5) {
  ggsave(path_figures(filename), plot, width = width, height = height, dpi = 300, bg = "white")
}
