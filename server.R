###
# File     : server.R
# Author   : smjb
# Context  : shiny application
#   AppName: Simple Analytics of Japanese Population, 1970 - 2010
#   For    : Coursera Data Scientist Specialization
#   For    : Module 9 - Developing Data Products
#   Date   : Sept 2015
###

library(shiny)
library(rCharts)
library(ggplot2)

# load primary file that process the datafile
source("reloadData.R")

# line only used during debugging. 
#options(shiny.error=browser) 

shinyServer(function(input, output) {
  
  # [unused] display the timerange selected on Navigation Panel (Age Group View)
  output$timerange <- renderText({
    paste("Input Year from ", input$timeframe[1], " to", input$timeframe[2])
  })
  
  # [unused] display the Prefecture selected on Navigation Panel (Age Group View) 
  output$prefecture_selected <- renderText({
    paste("Prefecture Selected : ", preflist$Prefecture[preflist$PID==input$pref])
  })
  
  # [unused] display selected Age Range on Navigation Panel (--unused--)
  output$age_selected <- renderText({
    minage<-(as.integer(input$agegroup)-1)*5
    paste("Age Group : From ", agelist$MinAge[agelist$MinAge == minage], "years old to", agelist$MaxAge[agelist$MinAge ==minage], "years old (", agelist$AgeGroup[agelist$MinAge == minage], ")")
  })
  
  # [unused] display selected Age Group on Navigation Panel (--unused--)
  output$agegroup_selected <- renderText({
    minage<-(as.integer(input$agegroup)-1)*5
    paste("Age Group : ", agelist$AgeGroup[agelist$MinAge == minage])
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
    r<-r+labs(x="Age during Census",y="% of Population", title=paste("Age vs Population Proportion tracking by Year of Birth in", getPrefName(pref)))
    
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
    r<-r+theme(panel.background=element_rect(fill="white"),legend.key = element_rect(fill = "white"))
    r<-r+labs(x="Age during Census",y="Total Population (millions)", title=paste("Age vs Population tracking by Year of Birth in", getPrefName(pref)))
    return (r)
  })
  
  # [unused] Plot Population Distribution for each age group for selected Census Year
  #          on Navigation Panel (Age Group)
  output$showAgeGroupBox <- renderPlot({
    yr = input$agyear
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, Population))+geom_boxplot()+xlab("Age Group")+ylab("Population, (million)")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [      ] Plot Population Proportion Distribution for each age group for selected Census Year
  #          on Navigation Panel (Age Group)
  output$showAgeGroupEvolutionBoxPct <- renderPlot({
    #message(paste("ag=",input$ag))
    yr = getAgeGroupName(input$ag)
    qstat <- getAgeQuantileStat(yr)
    g <- ggplot(qstat, aes(as.factor(Year), PopPct))+geom_boxplot()+xlab("Year")+ylab("Population, %")
    g<-g+labs(title=paste("Age Group",yr,"Population across Japan"))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=as.factor(Year))
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [unused] Plot Population Distribution over time for selected Age Group
  #          on Navigation Panel (Age Group Evolution in Time)
  output$showAgeGroupEvolutionBox <- renderPlot({
    yr = getAgeGroupName(input$ag)
    qstat <- getAgeQuantileStat(yr)
    g <- ggplot(qstat, aes(as.factor(Year), Population))+geom_boxplot()+xlab("Year")+ylab("Population, (million)")
    g<-g+labs(title=paste("Age Group",yr,"Population across Japan"))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=as.factor(Year))
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [      ] Plot Population Proportion Distribution over time for selected Age Group
  #          on Navigation Panel (Age Group Evolution in Time)
  output$showAgeGroupBoxPct <- renderPlot({
    yr = input$agyear
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, PopPct))+geom_boxplot()+xlab("Age Group")+ylab("Population, %")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [unused] Violin Plot of Population Proportion Distribution over time for selected Age Group
  #          on Navigation Panel (--unused--)
  output$showAgeGroupViolin <- renderPlot({
    yr = input$timeframe[1]
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, PopPct))+geom_violin()+xlab("Age Group")+ylab("Population, %")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  # [     ]  Area Plot of Population Proportion Distribution over time each selected Age Group 
  #          at selected prefecture on Navigation Panel (Age Group View)
  output$chart100pct_pref <- renderPlot({
    minyear <- input$timeframe[1]
    maxyear <- input$timeframe[2]
    pref <- input$pref
    agegrp <- input$agegroup
    x <- PrefAgePop(minyear=minyear, maxyear=maxyear, pref = pref)
    dx <- dim(x)
    p<-ggplot(x, aes(Year, PopPct))+geom_area()+aes(fill=AgeGroup)
    p<-p+theme(legend.position="right",panel.background=element_rect(fill="white"))+labs(y="Population, %", title=paste("Evolution of Age Group Distribution in", getPrefName(pref)))+
      guides(fill=guide_legend(title="Age Group", reverse=TRUE))
    return(p)
  })
  
  # [     ]  Area Plot of Population Distribution over time each selected Age Group 
  #          at selected prefecture on Navigation Panel (Age Group View)
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
})
