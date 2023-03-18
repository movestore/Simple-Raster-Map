# Raster Map
MoveApps

Github repository: *github.com/movestore/Simple-Raster-Map*

## Description
Maps raster of all location points with coastlines background. Fastest option to plot large data sets (>100,000 locations). Start with large grid values to test performance. 

## Documentation
This App transforms all Movement data locations to a set of location points in an area equal distance projection. Those are then merged into a raster of given grid size and plotted. For orientation coastlines are added. For further analyses the input data set is also returned.

Two sliders are provided to (1) adjust the grid size of the raster and (2) adapt the margin size for better visibility of the coastlines. If the whole data set lies far from any coast, margins are automatically added.

### Input data
moveStack in Movebank format

### Output data
Shiny user interface (UI)
moveStack in Movebank format

### Artefacts
none

Pressing the "SavePlot" Button on the UI allows to download the raster map as png file.

### Settings 
`Choose a raster grid size in m`: Integer indicating the grid size for rasterizing your data. Large values give less, large grid cells. Please choose values between 1000 and 300000. This value can also be adapted in the UI. Unit: `m`. Default: 50000.

`Choose a margin size in degrees`: Margin size for better visibility of coastlines. Unit: degrees. Default 0.

### Null or error handling:
**Setting `Choose a raster grid size in m`:** This parameter has a default of 50000. If you provide a value outside of the provided range (1000 - 300000) the parameter will be mapped to the respective range edge (1000 if value too small, 300000 if value too large).

**Setting `Choose a margin size in degrees`:** Only positive values allowed. Best in range of 0 - 30 degrees.

**Data:** This App is not reducing the data in any form, so no empty tracks can occur. The output data set should have the same dimensions as the input.

