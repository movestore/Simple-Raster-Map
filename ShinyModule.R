library('move')
library('shiny')
library('raster')
library('rgeos')

#setwd("/root/app/")

shinyModuleUserInterface <- function(id, label, grid = 50000) {
  ns <- NS(id)
  
  tagList(
    titlePanel("Raster map of location density"),
    sliderInput(inputId = ns("grid"), 
                label = "Choose a raster grid size in m", 
                value = grid, min = 1000, max = 300000),
   plotOutput(ns("map"),height="90vh")
  )
}

shinyModuleConfiguration <- function(id, input) {
  ns <- NS(id)
  configuration <- list()

  print(ns('grid'))
  configuration["grid"] <- input[[ns('grid')]]

  configuration
}

shinyModule <- function(input, output, session, data, grid = 50000) {
  current <- reactiveVal(data)
  
  SP <- SpatialPoints(data,proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  SPT <- spTransform(SP,CRSobj="+proj=aeqd +lat_0=53 +lon_0=24 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
  
  outputRaster <- reactive({
    raster(ext=extent(SPT), resolution=input$grid, crs = "+proj=aeqd +lat_0=53 +lon_0=24 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs", vals=NULL)
  })
  
  rasterObjT <- reactive({
      rasterize(SPT,outputRaster(),fun="count",update=TRUE)
  })  


  coastlines <- readOGR("ne-coastlines-10m/ne_10m_coastline.shp")
  coastlinesC <- crop(coastlines,extent(SP))
  coast <- spTransform(coastlinesC,CRSobj="+proj=aeqd +lat_0=53 +lon_0=24 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")

  
  output$map <- renderPlot({
    plot(rasterObjT(),colNA=NA,axes=FALSE,asp=1) 
    plot(coast, add = TRUE)
  })
  
  return(reactive({ current() }))
}


