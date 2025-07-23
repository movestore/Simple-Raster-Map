library('move2')
library('shiny')
library(sf)
library(terra)
library(dplyr)
library(leaflet)
library("shinycssloaders")
library(htmlwidgets)


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
                            selected="tracks")),
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
    outputRaster <- rast(extent = st_bbox(data_aeqd),resolution =input$grid*1000 , crs = aeqd_crs) 
 
     ### rasterize tracks
    if(input$rast_typ=="tracks"){
    line_geoms <- mt_segments(data_aeqd)
    lines_sf_aeqd <- st_sf(ID = mt_track_id(data_aeqd), geometry = line_geoms)
    lines_sf_aeqd <- lines_sf_aeqd[st_geometry_type(lines_sf_aeqd) == "LINESTRING", ] # removing the last point!
    
    seg_rast <- rasterize(vect(lines_sf_aeqd),
                          outputRaster,
                          touches = TRUE,
                          field = NULL,
                          fun = "sum")
    seg_rast[seg_rast == 0] <- NA
    
    # id_list <- unique(lines_sf_aeqd$ID)
    # raster_list <- lapply(id_list, function(id_val) {
    #   line <- lines_sf_aeqd %>% dplyr::filter(ID == id_val)
    #   seg_rast <- rasterize(vect(line), outputRaster, touches = TRUE)
    #   values(seg_rast)[is.na(values(seg_rast))] <- 0
    #   return(seg_rast)
    # })
    # seg_rast_sum <- Reduce(`+`, raster_list)
    # values(seg_rast_sum)[values(seg_rast_sum) == 0] <- NA
    # seg_rast_sum
    
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
    if (input$rast_typ == 'tracks') {
      pal <- colorFactor('Spectral', na.color = 'transparent', domain = unique(na.omit(values(raster_image()))))
      legend_title <- 'number of tracks'
    } else if (input$rast_typ == 'locs') {
      pal <- colorNumeric('plasma', values(raster_image()), na.color = 'transparent')
      legend_title <- 'number of locations'
    }
    leaflet() %>%
      addTiles() %>%
      addRasterImage(raster_image(), opacity = 0.8, colors = pal) %>%
      addLegend(pal = pal, values = values(raster_image()), title = legend_title)
  })
  
  output$map <- renderLeaflet({mmap()})
  
  ## download as html
  output$save_html <- downloadHandler(
    filename = paste0("Rasterized_",input$rast_typ,"_at_",input$grid,"Km.html"),
    content = function(file) {
      saveWidget(widget = mmap(),file=file) })
  
  return(reactive({ current() }))
}


