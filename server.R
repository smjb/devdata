###
# File     : server.R
# Author   : smjb
# Context  : shiny application
#   AppName: Simple Analytics of Japanese Population, 1970 - 2010
#   For    : Coursera Data Scientist Specialization
#   For    : Module 9 - Developing Data Products
#   Date   : Sept 2015
# Remark   : rCharts not used as it has unpredictable errors that is time consuming to 
# Remark   : be debugged. The effort is too much for simple application like this.
###

library(shiny)
library(rCharts)
library(ggplot2)

# load primary file that process the datafile
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
## --

shinyServer(function(input, output) {

  # [     ]  Area Plot of Population Proportion Distribution over time each selected Prefecture 
  #          at selected prefecture on Navigation Panel (Prefecture View)
  output$chart100pct_pref <- renderPlot({
    minyear <- input$timeframe[1]
    maxyear <- input$timeframe[2]
    pref <- input$pref
    x <- PrefAgePop(minyear=minyear, maxyear=maxyear, pref = pref)
    dx <- dim(x)
    p<-ggplot(x, aes(Year, PopPct))+geom_area()+aes(fill=AgeGroup)
    p<-p+theme(legend.position="right",panel.background=element_rect(fill="white"))+
      labs(y="Population, %", 
           title=paste("Evolution of Age Group Distribution in", getPrefName(pref)))+
      guides(fill=guide_legend(title="Age Group", reverse=TRUE))
    return(p)
  })
  
  # [     ]  Area Plot of Population Distribution over time each selected Prefecture
  #          at selected prefecture on Navigation Panel (Prefecture View)
  output$chart_pref <- renderPlot({
    minyear <- input$timeframe[1]
    maxyear <- input$timeframe[2]
    pref <- input$pref
    agegrp <- input$agegroup
    x <- PrefAgePop(minyear=minyear, maxyear=maxyear, pref = pref)
    dx <- dim(x)
    p<-ggplot(x, aes(Year, Population/1000))+geom_area()+aes(fill=AgeGroup)
    p<-p+theme(legend.position="right",panel.background=element_rect(fill="white"))+
      labs(y="Population (millions)", title=paste("Evolution of Age Group Distribution in", getPrefName(pref)))+
      guides(fill=guide_legend(title="Age Group", reverse=TRUE))
    return(p)
  })
  
  # [      ] Plot Population Proportion Change over time Group by Birth Year and initial age group
  #          on Navigation Panel (Age Tracking)
  output$AgeEvolutionPct <- renderPlot({
    minyear <- input$timeframe2[1]
    maxyear <- input$timeframe2[2] 
    pref <- input$pref2
    paste("Age Evo : ", pref)
    x <- getBornYearStat(minyear, maxyear, pref)    
    r <- ggplot(x, aes(MinAge,PopPct))+geom_line()+aes(colour=factor(BornYear))+
      guides(col=guide_legend(ncol=6, title="Year Born", reverse=TRUE))
    r<-r+theme(panel.background=element_rect(fill="white"))
    r<-r+labs(x="Age during Census",y="% of Population", 
              title=paste("Age vs Population Proportion tracking by Year of Birth in", 
                          getPrefName(pref)))
    
    return (r)
  })
  
  # [      ] Plot Population Change over time Group by Birth Year and initial age group
  #          on Navigation Panel (Age Tracking)
  output$AgeEvolution <- renderPlot({
    minyear <- input$timeframe2[1]
    maxyear <- input$timeframe2[2] 
    pref <- input$pref2
    x <- getBornYearStat(minyear,maxyear,pref)   
    
    r <- ggplot(x, aes(MinAge,Population/1000))+geom_line()+geom_point()+
      aes(colour=factor(BornYear))+
      guides(col=guide_legend(ncol=6, title="Year Born", reverse=TRUE))
    r<-r+theme(panel.background=element_rect(fill="white"),
               legend.key = element_rect(fill = "white"))
    r<-r+labs(x="Age during Census",y="Total Population (millions)", 
              title=paste("Age vs Population tracking by Year of Birth in", 
                          getPrefName(pref)))
    return (r)
  })

  # [      ] Plot Population Proportion Distribution over time for selected Age Group
  #          on Navigation Panel (Age Group View)
  output$showAgeGroupBoxPct <- renderPlot({
    yr = input$agyear
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, PopPct))+geom_boxplot()+xlab("Age Group")+
      ylab("Population, %")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+
      aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [      ] Plot Population Proportion Distribution for each age group for selected Census Year
  #          on Navigation Panel (Age Group Evolution)
  output$showAgeGroupEvolutionBoxPct <- renderPlot({
    yr = getAgeGroupName(input$ag)
    qstat <- getAgeQuantileStat(yr)
    g <- ggplot(qstat, aes(as.factor(Year), PopPct))+geom_boxplot()+xlab("Year")+
      ylab("Population, %")
    g<-g+labs(title=paste("Age Group",yr,"Population across Japan"))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+
      aes(fill=as.factor(Year))
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [      ] Show data table interactivelyon Navigation Panel (Table View)
  output$dispStatTable <- renderDataTable(jpstat)
  
  # [unused] Plot Population Distribution over time for selected Age Group
  #          on Navigation Panel (--unused--)
  output$showAgeGroupEvolutionBox <- renderPlot({
    yr = getAgeGroupName(input$ag)
    qstat <- getAgeQuantileStat(yr)
    g <- ggplot(qstat, aes(as.factor(Year), Population))+geom_boxplot()+xlab("Year")+
      ylab("Population, (million)")
    g<-g+labs(title=paste("Age Group",yr,"Population across Japan"))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+
      aes(fill=as.factor(Year))
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })

  # [unused] Violin Plot of Population Proportion Distribution over time for selected Age Group
  #          on Navigation Panel (--unused--)
  output$showAgeGroupViolin <- renderPlot({
    yr = input$timeframe[1]
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, PopPct))+geom_violin()+xlab("Age Group")+
      ylab("Population, %")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+
      aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [unused] display the timerange selected on Navigation Panel (--unused--)
  output$timerange <- renderText({
    paste("Input Year from ", input$timeframe[1], " to", input$timeframe[2])
  })
  
  # [unused] display the Prefecture selected on Navigation Panel (--unused--) 
  output$prefecture_selected <- renderText({
    paste("Prefecture Selected : ", preflist$Prefecture[preflist$PID==input$pref])
  })
  
  # [unused] display selected Age Range on Navigation Panel (--unused--)
  output$age_selected <- renderText({
    minage<-(as.integer(input$agegroup)-1)*5
    paste("Age Group : From ", agelist$MinAge[agelist$MinAge == minage], 
          "years old to", agelist$MaxAge[agelist$MinAge ==minage], "years old (",
          agelist$AgeGroup[agelist$MinAge == minage], ")")
  })
  
  # [unused] display selected Age Group on Navigation Panel (--unused--)
  output$agegroup_selected <- renderText({
    minage<-(as.integer(input$agegroup)-1)*5
    paste("Age Group : ", agelist$AgeGroup[agelist$MinAge == minage])
  })
  
  # [unused] Plot Population Distribution for each age group for selected Census Year
  #          on Navigation Panel (--unused--)
  output$showAgeGroupBox <- renderPlot({
    yr = input$agyear
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, Population))+geom_boxplot()+xlab("Age Group")+
      ylab("Population, (million)")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+
      aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
})
