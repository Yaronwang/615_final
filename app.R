library(shiny)
library(leaflet)
library(tidyverse)
library(dplyr)


data <- read.csv('MBTA.csv',header = T)
data$Hour <- as.numeric(substr(data$arrival_time,1,2))
Season <- unique(data$Season)
Transportion <- unique(data$route_id)
Time <- unique(data$Hour)

ui <- fluidPage(
  titlePanel("MBTA"),
  sidebarLayout(
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Map",leafletOutput("map")),
                  tabPanel("Table",tableOutput("table"))
      )
    ),sidebarPanel(
      checkboxGroupInput("Transportion", "Please select a transportion",Transportion),
      br(),
      selectInput("Time", "Please select a time to leave",Time),
      br(),
      checkboxGroupInput("Season","Please select a season",Season),
    )
  )
)

server <- function(input,output){
  rea <- reactive({
    data %>% filter(Season%in%input$Season, route_id%in%input$Transportion, Hour%in%input$Time)
  })
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(lat = rea()$stop_lat, lng = rea()$stop_lon,
                 popup= rea()$checkpoint_name)
  })
  output$table <- renderTable({rea()})
}

shinyApp(ui = ui, server = server)