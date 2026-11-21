# Report Figures 1 and 2: plant quadrats and bird point counts on an OpenStreetMap basemap.
# Tiles are downloaded once into data/external/osm_tiles/ (not committed) and stitched in R.
# Outputs: outputs/figures/fig1_plant_quadrats_map.png, fig2_bird_points_map.png

# Quadrats recorded with GPS positions away from their point; left off the map, as in the report.
misplaced_quadrats <- c("OM X", "ON 2b", "ON 2c")

plant_points <- plants |>
  filter(!is.na(Latitude), !is.na(Longitude), !Quadrat %in% misplaced_quadrats) |>
  distinct(Location, Quadrat, lat = Latitude, lon = Longitude)

bird_points <- birds_raw |>
  distinct(Location, ID, lat, lon)

# Web Mercator: longitude/latitude -> global pixel coordinates at a given zoom
tile_size <- 256
lon_to_px <- function(lon, zoom) (lon + 180) / 360 * 2^zoom * tile_size
lat_to_px <- function(lat, zoom) {
  rad <- lat * pi / 180
  (1 - log(tan(rad) + 1 / cos(rad)) / pi) / 2 * 2^zoom * tile_size
}

fetch_tile <- function(x, y, zoom) {
  cache <- here("data", "external", "osm_tiles", zoom, x, paste0(y, ".png"))
  if (!file.exists(cache)) {
    dir.create(dirname(cache), recursive = TRUE, showWarnings = FALSE)
    handle <- new_handle(useragent = "fynbos-bird-functional-diversity (research figure; github.com/makysimkova)")
    curl_download(sprintf("https://tile.openstreetmap.org/%d/%d/%d.png", zoom, x, y), cache, handle = handle)
    Sys.sleep(0.2)
  }
  readPNG(cache)[, , 1:3]
}

# Stitched basemap covering a pixel extent: list(image, xmin, xmax, ymin, ymax)
osm_basemap <- function(px_x, px_y, zoom) {
  tiles_x <- floor(px_x[1] / tile_size):floor(px_x[2] / tile_size)
  tiles_y <- floor(px_y[1] / tile_size):floor(px_y[2] / tile_size)
  image <- array(0, c(length(tiles_y) * tile_size, length(tiles_x) * tile_size, 3))
  for (i in seq_along(tiles_y)) for (j in seq_along(tiles_x)) {
    rows <- (i - 1) * tile_size + seq_len(tile_size)
    cols <- (j - 1) * tile_size + seq_len(tile_size)
    image[rows, cols, ] <- fetch_tile(tiles_x[j], tiles_y[i], zoom)
  }
  list(image = image,
       xmin = min(tiles_x) * tile_size, xmax = (max(tiles_x) + 1) * tile_size,
       ymin = min(tiles_y) * tile_size, ymax = (max(tiles_y) + 1) * tile_size)
}

# Same view for both maps (about 8.2 x 5.6 km), matching the framing of the report figures
zoom <- 15
view_lon <- c(19.3392, 19.4283)
view_lat <- c(-33.7945, -33.8447)
metres_per_px <- 156543.03392 * cos(mean(view_lat) * pi / 180) / 2^zoom
view_x <- lon_to_px(view_lon, zoom)
view_y <- lat_to_px(view_lat, zoom)
basemap <- osm_basemap(view_x, view_y, zoom)

scale_bar_px <- 500 / metres_per_px

point_map <- function(points, colours) {
  points <- mutate(points, x = lon_to_px(lon, zoom), y = lat_to_px(lat, zoom))
  bar_x <- view_x[1] + 15
  bar_y <- view_y[1] + 15
  ggplot(points, aes(x, y, colour = Location)) +
    annotation_raster(basemap$image, basemap$xmin, basemap$xmax, -basemap$ymax, -basemap$ymin) +
    geom_point(aes(y = -y), size = 1.6, alpha = 0.9) +
    annotate("rect", xmin = bar_x, xmax = bar_x + scale_bar_px, ymin = -bar_y - 40, ymax = -bar_y,
             fill = "white", alpha = 0.8, colour = "grey30", linewidth = 0.6) +
    annotate("text", x = bar_x + 10, y = -bar_y - 20, label = "500 m", hjust = 0, size = 3.5) +
    annotate("label", x = view_x[2] - 10, y = -view_y[2] + 10, label = "© OpenStreetMap contributors",
             hjust = 1, vjust = 0, size = 2.5, linewidth = 0, fill = "white", alpha = 0.8) +
    scale_colour_manual(values = colours) +
    coord_fixed(xlim = view_x, ylim = -rev(view_y), expand = FALSE) +
    theme_void() +
    theme(legend.position = "none")
}

map_width <- 7
map_height <- map_width * diff(view_y) / diff(view_x)

save_fig(point_map(plant_points, c("Klipbokkop" = "darkorange", "Modder rivier" = "darkblue")),
         "fig1_plant_quadrats_map.png", width = map_width, height = map_height)
save_fig(point_map(bird_points, c("Klipbokkop" = "red", "Farm" = "purple")),
         "fig2_bird_points_map.png", width = map_width, height = map_height)
