###
# File     : ui.R
# Author   : smjb
# Context  : shiny application
#   AppName: Simple Analytics of Japanese Population, 1970 - 2010
#   For    : Coursera Data Scientist Specialization
#   For    : Module 9 - Developing Data Products
#   Date   : Sept 2015
# Remark   : rCharts not used as it has unpredictable errors that is time consuming to 
# Remark   : be debugged. The effort is too much for simple application like this.
###

# The user-interface definition of the Shiny web app.
library(shiny)
#library(rCharts)
library(dplyr)

source("reloadData.R")

# line only used during debugging. 
#options(shiny.error=browser) 

## UI Layout Brief
# UI has a Top Navigation Bar, with 4 Navigation Panel : 
# 1. Population View by Prefecture (Prefecture View)
# 2. Age Tracking by Prefecture (Age Tracking)
# 3. Age Group Statistics on Census Year (Age Group View)
# 4. Age Group Evolution in Time (Age Group Evolution)
# 5. Raw Data View (Table View)
# 6. About Page (About)
## --


shinyUI(
  fluidPage(
    titlePanel("Visualization of Japan Population Estimates"),
    navbarPage(
      "Japan",
      tabPanel(
        "Population View", 
        sidebarLayout(
          position = "right",
          sidebarPanel(
            "Select Parametric Value : ",
            sliderInput(
              "timeframe",
              "Census Year",
              min = 1970, 
              max = 2010, 
              value = c(1980, 2005)
            ), #sliderInput.timeframe
            selectInput(
              "pref", 
              label = h3("Select Prefecture"), 
              choices = listPref(),
              selected = 0
            ) #selectInput.pref
          ), #sideBarPanel.control
          mainPanel(
            h4("Background"),
            p(paste0("The plots below shows the total population evolution in time for each age group.",
                     "The age group is in the format a{xx}t{yy} where it is read as the age group between {xx} and {yyy}.",
                     "You can use the control panel on the right to examine the population of each Prefecture during the desired time range.")),
            h4("Total population evolution in time by age group"),
            plotOutput("chart_pref"),
            h4("Total population proportion evolution in time by age group"),
            plotOutput("chart100pct_pref")
          )#mainpanel
        )#SiteBarLayout.right
      ),#Tabpanel.tab1
      tabPanel( 
        "Age tracking", 
        sidebarLayout(
          position = "right",
          sidebarPanel(
            "Select Parametric Value : ",
            sliderInput(
              "timeframe2", 
              "Census Year",
              min = 1970, 
              max = 2010, 
              value = c(1980, 2005)
            ), #sliderInput.timeframe2
            selectInput(
              "pref2", 
              label = h3("Select Prefecture"), 
              choices = listPref(),
              selected = 0
            )
          ), #sideBarPanel.control
          mainPanel(
            h1("Population tracking in Time"),
            p("The population are grouped by their birth year and their age. The birth year is within +/- 5 years since the census age rage is 5 years."),
            p("Each line shows a group of population born the same year, and how the group size grows or shrink in time."),
            p("An increasing slope shows net immigration while decreasing slope shows net decline in population due to death or emigration."),
            p("You can visualize at what age the emigration or immigration happens and which prefecture gains or lose most population."),
            h4("View by population"),
            plotOutput("AgeEvolution"),
            h4("View by percentage of population of that age group compared to overall  population during the census year"),
            plotOutput("AgeEvolutionPct")
          )#mainpanel
        )#SiteBarLayout.right
      ),#Tabpanel.tab2
      tabPanel( 
        "Age Group View", 
        sidebarLayout(
          position = "right",
          sidebarPanel(
            "Select Parametric Value : ",
            selectInput(
              "agyear", 
              label = h3("Census Year"), 
              choices = yearlist,
              selected = 1980
            )
          ), #sideBarPanel.control
          mainPanel(
            p("The graph below shows how the population proportion for each age group for the selected year is distributed between the different prefectures."),
            plotOutput("showAgeGroupBoxPct")
          )#mainpanel
        )#SiteBarLayout
      ),#Tabpanel.tab3
      tabPanel( 
        "Age Group Evolution", 
        sidebarLayout(
          position = "right",
          sidebarPanel(
            "Select Parametric Value : ",
            selectInput(
              "ag", 
              label = h3("AgeGroup"), 
              choices = listAgeGroup(),
              selected = 1
            )
          ), #sideBarPanel.control
          mainPanel(
            p("The graph below shows how the population proportion of the selected age group changes over time."),
            p("This will show in a much clearer way on which age group is increasing and which are decreasing over time."),
            p("You will see that the birth rate is decreasing while the longevity is increasing."),
            plotOutput("showAgeGroupEvolutionBoxPct")
          )#mainpanel
        )#SiteBarLayout
      ),#Tabpanel.tab4
      tabPanel( 
        "Table View", 
        mainPanel(
          p("You can use the fields at the bottom of this table to filter data."),
          fluidRow(
            column(10,
                   dataTableOutput('dispStatTable')
            ) # column
          ) #fluid row
        ) #main
      ),#Tabpanel.tab5
      tabPanel( 
        "About", 
        mainPanel(
          h2("Data source"),
          p("Census data from 1970 to 2010 is downloaded from "),
          a("http://www.stat.go.jp/english/data/jinsui/2.htm"),
          h2("Preprocessing"),
          p("The data from multiple Excel spreadsheets are extracted and processed using the R-script reshape_jap.R and reshape_jap2.R."),
          p("The shinyApp only use preprocessed file to speed up the operations."),
          h2("Slides"),
          p("The pitching slides can be found"),
          a("http://smjb.github.io/devdata_pitch")
        ) #main
      )#Tabpanel.tab5
    ) #navPanel
  )#fluidpage
)#shiny
