# The user-interface definition of the Shiny web app.
library(shiny)
library(rCharts)
library(dplyr)

source("reloadData.R")

shinyUI(
  fluidPage(
    titlePanel("Population of Japan - Age Analysis"),
    navbarPage(
      "Japan Population Census",
      tabPanel(
        "Age Group View", 
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
              label = h3("prefecture"), 
              choices = listPref(),
              selected = 0
            ), #selectInput.pref
            selectInput(
              "agegroup", 
              label = h3("AgeGroup"), 
              choices = listAgeGroup(),
              selected = 1
            ) #selectinput.agegroup
          ), #sideBarPanel.control
          mainPanel(
            #             textOutput("timerange"),
            #             textOutput("prefecture_selected"),
            #             #showOutput("chart100pct_pref", "nvd3"),
            #             textOutput("age_selected"),
            #             #showOutput("AgeEvolution", "polycharts"),
            #plotOutput("showAgeGroupBox"),
            plotOutput("chart_pref"),
            plotOutput("chart100pct_pref")
            #             
            #             #showOutput("prefchart", "nvd3"),
            #             textOutput("agegroup_selected")
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
              label = h3("prefecture"), 
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
        "Age Group ", 
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
            #            h1("Distribution of Prefectures Population by Age Group"),
            #           p("xyz"),
            #          h4("View by population"),
            plotOutput("showAgeGroupBoxPct"),
            h4("% ")
          )#mainpanel
        )#SiteBarLayout
      ),#Tabpanel.tab3
      tabPanel( 
        "Age Group Evolution in Time", 
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
            #            h1("Distribution of Prefectures Population by Age Group"),
            #           p("xyz"),
            #          h4("View by population"),
            #            plotOutput("showAgeGroupEvolutionBox"),
            plotOutput("showAgeGroupEvolutionBoxPct"),
            h4("% ")
          )#mainpanel
        )#SiteBarLayout
      )#Tabpanel.tab4
    ) #navPanel
  )#fluidpage
)#shiny
