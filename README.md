# Rasterized Tracks Or Locations

MoveApps

Github repository: https://github.com/movestore/Simple-Raster-Map.git

## Description
This App maps the tracks as rasters on an interactive background map. The grid size is user defines and each grid cell can either contain the total number of locations, or the total number of tracks. It is the fastest option to plot large data sets (>100,000 locations).

## Documentation
The tracks are rasterized on a template raster with the chosen grid size in a Pseudo-Mercator projection (EPSG:3857) to match the projection of the underlying background map.
There are two options, to rasterize the locations, where all locations (of all tracks) that fall within each raster cell are counted, and to rasterize the tracks, where the locations are converted into a line (using the function `move2::mt_track_lines`) and the number of tracks that cross each raster cell are counted.

### Application scope
#### Generality of App usability
This App was developed for any taxonomic group. Specially useful for large datasets.

#### Required data properties

The App should work for any kind of (location) data.

### Input type
`move2::move2_loc`

### Output type
`move2::move2_loc`

### Artefacts

### Settings 
`Choose a raster grid size in Km`: Integer indicating the grid size for rasterizing your data. Large values give less but larger grid cells. Unit: `km`. Default: 50.

`Choose what to rasterize`: `Locations`: the total number of total (across all tracks) that fall within a pixel are counted. `Tracks`: the number of tracks (locations joint by a line) that cross each pixel are counted. Default: `Tracks`

`Download as HTML`: the map with the chosen setting can be downloaded as a `.html` file

`Store settings`: click to store the current settings of the App for future Workflow runs. 

### Changes in output data

The input data remains unchanged.

### Most common errors

### Null or error handling
