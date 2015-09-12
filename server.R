library(shiny)
library(rCharts)
library(ggplot2)

source("reloadData.R")
options(shiny.error=browser)
shinyServer(function(input, output) {
  output$timerange <- renderText({
    paste("Input Year from ", input$timeframe[1], " to", input$timeframe[2])
  })
  
  output$prefecture_selected <- renderText({
    paste("Prefecture Selected : ", preflist$Prefecture[preflist$PID==input$pref])
  })
  
  output$age_selected <- renderText({
    minage<-(as.integer(input$agegroup)-1)*5
    paste("Age Group : From ", agelist$MinAge[agelist$MinAge == minage], "years old to", agelist$MaxAge[agelist$MinAge ==minage], "years old (", agelist$AgeGroup[agelist$MinAge == minage], ")")
  })
  
  output$agegroup_selected <- renderText({
    minage<-(as.integer(input$agegroup)-1)*5
    paste("Age Group : ", agelist$AgeGroup[agelist$MinAge == minage])
  })
  
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
  
  output$AgeEvolution <- renderPlot({
    minyear <- input$timeframe2[1]
    maxyear <- input$timeframe2[2] 
    pref <- input$pref2
    paste("Age Evo : ", pref)
    x <- getBornYearStat(minyear,maxyear,pref)   
    
    r <- ggplot(x, aes(MinAge,Population/1000))+geom_line()+geom_point()+
      aes(colour=factor(BornYear))+
      guides(col=guide_legend(ncol=6, title="Year Born", reverse=TRUE))
    r<-r+theme(panel.background=element_rect(fill="white"),legend.key = element_rect(fill = "white"))
    r<-r+labs(x="Age during Census",y="Total Population (millions)", title=paste("Age vs Population tracking by Year of Birth in", getPrefName(pref)))
    #r<-r+scale_color_brewer()
    
    # r
    #  r <- rPlot(PopPct~MinAge, data=x, type="line", color="BornYear")
    # r$set(title=paste0("Population Growth/Decline based on Year of Birth -  ", preflist$Prefecture[preflist$PID==input$pref]))
    #r$set(xlab="Age")
    #r$layer(x="Age")
    return (r)
  })
  
  output$showAgeGroupBox <- renderPlot({
    yr = input$agyear
    #message("Entered dungeon")
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, Population))+geom_boxplot()+xlab("Age Group")+ylab("Population, (million)")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  #showAgeGroupEvolutionBox
  output$showAgeGroupEvolutionBoxPct <- renderPlot({
    #message(paste("ag=",input$ag))
    yr = getAgeGroupName(input$ag)
    #message(yr)
    
    
    qstat <- getAgeQuantileStat(yr)
    g <- ggplot(qstat, aes(as.factor(Year), PopPct))+geom_boxplot()+xlab("Year")+ylab("Population, %")
    g<-g+labs(title=paste("Age Group",yr,"Population across Japan"))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=as.factor(Year))
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  output$showAgeGroupEvolutionBox <- renderPlot({
    #message(paste("ag=",input$ag))
    yr = getAgeGroupName(input$ag)
    #message(yr)
    
    
    qstat <- getAgeQuantileStat(yr)
    g <- ggplot(qstat, aes(as.factor(Year), Population))+geom_boxplot()+xlab("Year")+ylab("Population, (million)")
    g<-g+labs(title=paste("Age Group",yr,"Population across Japan"))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=as.factor(Year))
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  output$showAgeGroupBoxPct <- renderPlot({
    yr = input$agyear
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, PopPct))+geom_boxplot()+xlab("Age Group")+ylab("Population, %")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
  output$showAgeGroupViolin <- renderPlot({
    yr = input$timeframe[1]
    qstat <- getQuantileStat(yr)
    g <- ggplot(qstat, aes(AgeGroup, PopPct))+geom_violin()+xlab("Age Group")+ylab("Population, %")
    g<-g+labs(title=paste("Population Statistics across Japan, Year = ", yr))
    g<-g+theme(panel.background=element_rect(fill="white"), legend.position="none")+aes(fill=AgeGroup)
    g<-g+theme(axis.text.x=element_text(angle=90))
    return (g)
  })
  
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
    #      nPlot(Population ~ Year, data=x, group='AgeGroup', type="stackedAreaChart",xlab="123")
    return(p)
  })
  
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
    
    
    #      nPlot(Population ~ Year, data=x, group='AgeGroup', type="stackedAreaChart",xlab="123")
    return(p)
  })
  
  
  
})
