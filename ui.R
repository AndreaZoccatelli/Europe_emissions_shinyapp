#libraries ----
library(shiny)
library(tidyverse)
library(rgdal)
library(tmap)
library(ggplot2)
library(sf)

#import + setup ----
eu = readRDS("eu.rds")
yearr = read.csv("yearr.csv")

vars <- setdiff(names(yearr), c("eu_state", "code", "year", "X"))

#ui ----
navbarPage("Europe emissions", id="nav", 
  
  tabPanel("Visualizations", #first panel
           tmapOutput("map"), #map
           
           br(), #extra space
           br(),
           
           selectInput("var", "Select gas", vars, selected = vars[1]), #variable selector
           
           sliderInput("year", #year selector (slider)
                       "Select year", #label
                       min = min(yearr$year), #min value of the range
                       max = max(yearr$year), #max value of the range
                       value = 2011, #default value
                       step = 1, #step on the slider (+/- 1 year)
                       sep = "", 
                       width = "100%",
                       animate = animationOptions(interval = 3000, loop = FALSE)), #auto animate
           br(),
           
           plotOutput("mybar", width = "100%")), #bar plot

  tabPanel("Read Me",includeMarkdown("About.Rmd")) #second panel
)


