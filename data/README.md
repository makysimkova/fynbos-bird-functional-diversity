# Data

Collected on 8–10 October 2025 at Klipbokkop (protected fynbos) and on farmland in Modder Rivier, near Worcester, Western Cape, South Africa. Field data are licensed under CC BY 4.0. Coordinates are WGS84 decimal degrees.

## `raw/bird_counts.csv`
One row per species per point count: 494 rows, 50 points, 966 individuals.

| Column | Description |
|---|---|
| `Location` | `Klipbokkop` or `Farm` |
| `ID` | Point ID (`K1`–`K31` Klipbokkop, `F1`–`F19` farmland) |
| `Latitude (S)`, `Longitude (E)` | Point position |
| `Day`, `Date`, `Time` | Survey day of the course, date (DD.MM.YYYY) and start time |
| `Species` | Common name, eBird taxonomy; unidentified birds are recorded as "sp." |
| `Count` | Individuals of that species counted in the 10-minute count |
| `Diet` | Unused (empty) |

## `raw/species_name_map.csv`
Common name → scientific name for the 80 names in `bird_counts.csv`. The 9 "sp." records have no scientific name.

## `raw/avonet_traits_subset.csv`
AVONET trait values (eBird taxonomy) for the 64 recorded species with an AVONET match. These are the values used in the analysis. Source: Tobias et al. (2022), *Ecology Letters* 25, 581–597, https://doi.org/10.1111/ele.13898 (CC BY 4.0). Seven recorded species have no match under the names used and are excluded from the functional diversity analysis: Alpine Swift, Cape Siskin, Familiar Chat, Grey-winged Francolin, Karoo Scrub Robin, Southern Fiscal and Yellow Canary.

## `raw/plant_quadrats.csv`
One row per plant family per quadrat: 20 points × 3 quadrats of 4 m².

| Column | Description |
|---|---|
| `Location` | `Klipbokkop` or `Modder rivier` (the farmland site) |
| `Day`, `Date` | Survey day; date not recorded |
| `Quadrat No` | Quadrat code; codes repeat between sites, so use `ID` for the point |
| `Latitude`, `Longitude` | Quadrat position |
| `Family` | Plant family, as recorded in the field |
| `Count` | Individuals; for grasses, one handful counted as one individual |
| `ID` | Point ID (`K1`–`K10` Klipbokkop, `M1`–`M10` Modder rivier) |

Family names are kept exactly as recorded, including spelling variants such as `Proteacea` and `Proteaceae`, so that the analysis reproduces the report. Three quadrats (`OM X`, `ON 2b`, `ON 2c`) have GPS positions away from their point and are left off the map. They are still included in the composition analysis.

## `processed/`
Written by `R/01_clean_join.R`:
- `bird_counts_traits.csv`: the bird counts with scientific names and traits attached; the 443 records used in the analysis.
- `plant_quadrats_clean.csv`: the plant records with the columns needed for the analysis.
