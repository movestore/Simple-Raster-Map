library('move2')
library('shiny')
library(sf)
library(terra)
library(dplyr)
library(leaflet)
library("shinycssloaders")
library(htmlwidgets)
library(shinyBS)


# data <- readRDS("./data/raw/input4_move2loc_LatLon.rds")

shinyModuleUserInterface <- function(id, label) {
  ns <- NS(id)
  
  tagList(
    titlePanel("Map of rasterized tracks"),
    fluidRow(
      column(3, sliderInput(inputId = ns("grid"), 
                            label = "Choose a raster grid size in Km", 
                            value = 50, min = 1, max = 300)),
      column(3, radioButtons(inputId = ns("rast_typ"), 
                            label = "Choose what to rasterize", 
                            c("Locations" = "locs",
                              "Tracks" = "tracks"),
                            selected="tracks"),
             bsTooltip(id=ns("rast_typ"), title="'Locations': the total number of total (across all tracks) that fall within a pixel are counted. 'Tracks': the number of tracks (locations joint by a line) that cross each pixel are counted", placement = "bottom", trigger = "hover")), #, options = list(container = "body")
      column(2,downloadButton(ns("save_html"),"Download as HTML", class = "btn-sm"))
    ),
    
    withSpinner(leafletOutput(ns("map"),height="85vh"))
  )
}


shinyModule <- function(input, output, session, data) {
  current <- reactiveVal(data)
 
  raster_image <- reactive({
    aeqd_crs <- "ESRI:54032"
    data_aeqd <- st_transform(data,aeqd_crs)
    outputRaster <- rast(extent = st_bbox(data_aeqd),resolution = input$grid*1000, crs = aeqd_crs) #
 
     ### rasterize tracks
    if(input$rast_typ=="tracks"){
    line_geoms <- mt_track_lines(data_aeqd)
    lines_sf_aeqd <- vect(line_geoms[,mt_track_id_column(data_aeqd)])

    lines_sf_aeqd$id <- 1:length(lines_sf_aeqd)
    raster_list <- lapply(1:length(lines_sf_aeqd), function(i) {
      rr <- rasterize(lines_sf_aeqd[i, ], outputRaster, field=1, touches = TRUE,background=0)
      rr
    })
    raster_stack <- rast(raster_list)
    seg_rast_sum <- app(raster_stack, sum)
    seg_rast_sum[seg_rast_sum == 0] <- NA
    seg_rast_sum
    
  ### rasterize locs
    } else if(input$rast_typ=="locs"){
    pts_sf_aeqd <- st_coordinates(data_aeqd)
    pnt_rast <- rasterize(vect(pts_sf_aeqd), outputRaster, fun="count")
    values(pnt_rast)[values(pnt_rast) == 0] <- NA
    pnt_rast
    }
  })
  
  ## plot on map
  mmap <- reactive({
    raster_ll <- project(raster_image(), "EPSG:4326")
    if (input$rast_typ == 'tracks') {
      # pal <- colorFactor('Spectral', na.color = 'transparent', domain = unique(na.omit(values(raster_image()))))
      pal <- colorNumeric('Spectral', values(raster_ll), na.color = 'transparent')
      legend_title <- 'number of tracks'
    } else if (input$rast_typ == 'locs') {
      pal <- colorNumeric('Spectral', values(raster_ll), na.color = 'transparent')
      legend_title <- 'number of locations'
    }
    leaflet() %>%
      addTiles() %>%
      addRasterImage(raster_ll, opacity = 0.8, colors = pal) %>%
      addLegend(pal = pal, values = values(raster_ll), title = legend_title)
  })
  
  output$map <- renderLeaflet({mmap()})
  
  ## download as html
  output$save_html <- downloadHandler(
    filename = paste0("Rasterized_",input$rast_typ,"_at_",input$grid,"Km.html"),
    content = function(file) {
      saveWidget(widget = mmap(),file=file) })
  
  return(reactive({ current() }))
}


