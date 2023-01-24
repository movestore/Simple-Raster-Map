library('move')
library('shiny')
library('raster')
library('rgeos')

#setwd("/root/app/")

shinyModuleUserInterface <- function(id, label) {
  ns <- NS(id)
  
  tagList(
    titlePanel("Raster map of location density"),
    sliderInput(inputId = ns("grid"), 
                label = "Choose a raster grid size in m", 
                value = 50000, min = 1000, max = 300000),
    sliderInput(inputId = ns("num"), 
                label = "Choose a margin size (unit=degree)", 
                value = 0, min = 0, max = 30, step=0.1),
   plotOutput(ns("map"),height="90vh"),
   downloadButton(ns('savePlot'), 'Save Plot')
  )
}


shinyModule <- function(input, output, session, data) {
  current <- reactiveVal(data)
  
  SP <- SpatialPoints(data,proj4string=CRS("+proj=longlat +ellps=WGS84 +no_defs"))
  mid <- colMeans(coordinates(SP))
  SPT <- spTransform(SP,CRSobj=paste0("+proj=aeqd +lat_0=",mid[2]," +lon_0=",mid[1]," +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"))
  
  outputRaster <- reactive({
    raster(ext=extent(SPT), resolution=input$grid, crs = paste0("+proj=aeqd +lat_0=",mid[2]," +lon_0=",mid[1]," +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"), vals=NULL)
  })
  
  rasterObjT <- reactive({
      rasterize(SPT,outputRaster(),fun="count",update=TRUE)
  })  

  #edg <- 0
  #coastlines <- readOGR(paste0(getAppFilePath("coastlines"),"/ne_10m_coastline.shp"))
  #while(length(gIntersection(coastlines,as(extent(SP)+c(-edg,edg,-edg,edg),'SpatialPolygons'),byid=FALSE))==0) edg <- edg+0.5
  
  #coast <- reactive({
  #  coastlinesC <- crop(coastlines,extent(SP)+c(-input$num,input$num,-input$num,input$num)+c(-edg,edg,-edg,edg)) ##without extra edge this does not work if far from coast - need to add edge until any coast
  #  spTransform(coastlinesC,CRSobj=paste0("+proj=aeqd +lat_0=",mid[2]," +lon_0=",mid[1]," +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"))
  #})

  output$map <- renderPlot({
    #plot(coast(),axes=FALSE)
    plot(rasterObjT(),colNA=NA,axes=FALSE,asp=1,add=TRUE)
  })
  
  ### save map, takes some seconds ###
  output$savePlot <- downloadHandler(
    filename = "SimpleRasterPlot.png",
    content = function(file) {
      png(file)
      #plot(coast(),axes=FALSE)
      plot(rasterObjT(),colNA=NA,asp=1, add = TRUE) 
      dev.off()
    }
  )
  
  return(reactive({ current() }))
}


