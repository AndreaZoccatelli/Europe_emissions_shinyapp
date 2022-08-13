#libraries ----
library(shiny)
library(tidyverse)
library(rgdal)
library(tmap)
library(ggplot2)

#import + setup ----
eu = readRDS("eu.rds")
yearr = read.csv("yearr.csv")

vars <- setdiff(names(yearr), c("eu_state", "code", "year", "X"))

#server ----
function(input, output, session) {
  
  dataInput <- reactive( 
    {eu = eu %>% filter(year == input$year) #filter table using year selected with slider by user
     eu}
    )
  
  output$map <- renderTmap(
    {tm_shape(dataInput()) + #render of the map filtered by the choices of the user
      tm_view(set.view = c(9,55,3.4)) + #map centering using coordinates and zoom level
      tm_polygons(vars[1], zindex = 401, id = "eu_state")} #use as default the first variable (greenhouse)
    )
  
  tabfilter <- reactive(
    {yearr = yearr %>% 
      filter(year == input$year) %>%
      select(eu_state, input$var) #apply filters also to the table used for the barplot
    yearr = na.omit(yearr) #remove all NA values
    yearr = yearr[order(yearr[,2], decreasing = T),] #arrange using emission value
    yearr = yearr %>% head(10)
    yearr}
    )
  
  
  observe( 
    {var <- input$var
    tmapProxy("map", session, #map
              {tm_remove_layer(401) +
               tm_shape(dataInput()) +
               tm_polygons(
                 var,
                 popup.vars = c(" " = var),
                 n = 6, #number of steps in which the range of values is divided
                 zindex = 401,
                 id = "eu_state")}) #id displayed in the popup: the full name of the country
    })
  
  output$mybar <- renderPlot( #bar plot
    tabfilter() %>% 
    ggplot()+
    geom_col(aes(reorder(tabfilter()[,1], tabfilter()[,2]), tabfilter()[,2]), fill = "#ea6e13")+
    xlab("")+
    ylab("")+
    theme_minimal()+
    theme(text=element_text(size=12))+
    ggtitle("10 countries with highest emissions")+
    coord_flip())
}