###
# File     : reloadData.R
# Author   : smjb
# Context  : shiny application
#   AppName: Simple Analytics of Japanese Population, 1970 - 2010
#   For    : Coursera Data Scientist Specialization
#   For    : Module 9 - Developing Data Products
#   Date   : Sept 2015
# Remark   : rCharts not used as it has unpredictable errors that is time consuming to 
# Remark   : be debugged. The effort is too much for simple application like this.
###

library(dplyr)
#library(rCharts)
library(reshape2)

# initialize global variables
rm(list=ls())
jpstat <- tbl_df(read.csv("jpstat_data.csv")) %>% mutate(BornYear = Year - MinAge)
preflist <- jpstat %>% select(PID, Prefecture) %>% distinct
agelist <- jpstat %>% filter(AgeGroup!="Total") %>% select(AgeGroup, MinAge, MaxAge) %>% distinct
yearlist <- jpstat%>% select(Year)%>%distinct
bornlist<-jpstat%>% select(BornYear)%>%distinct%>%arrange(BornYear)

# return Population of Japan
JapanPop <- function(minyear = 1970, maxyear=2010) {
  if(minyear<1970) minyear<-1970
  if(maxyear>2010) maxyear<-2010
  jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, PID==0, AgeGroup != "Total")
  return(jp)

}

# extract population data based on filters provided
SelAgePop <- function(minyear = 1970, maxyear=2010, SelAge = "Total", pref = 0) {
  if(maxyear < minyear) {
    t <- minyear
    minyear <- maxyear
    maxyear <- t
  }
  if(minyear<1970) minyear<-1970
  if(maxyear>2010) maxyear<-2010

  if(length(SelAge)==1) {
    if(SelAge=="Total") {
      jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, 
                                PID==pref, AgeGroup =="Total")
      # message(paste0("SelAge = TOTAL, PID=",pref))
    } else {
      jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, PID==pref, AgeGroup != "Total", AgeGroup %in% SelAge)
      #message(paste0("SelAge = ",SelAge, "PID=",pref, "min =", minyear, "max = ", maxyear))
    }
  } else {
      jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, PID==pref, AgeGroup != "Total", AgeGroup %in% SelAge)
      # message(paste0("SelAge = ",SelAge, "PID=",pref, "min =", minyear, "max = ", maxyear))
  }
  return(jp)
  
}

# Select prefecture population within time requested
PrefAgePop <- function(minyear = 1970, maxyear=2010,  pref = 0) {
  if(maxyear < minyear) {
    t <- minyear
    minyear <- maxyear
    maxyear <- t
  }
  if(minyear<1970) minyear<-1970
  if(maxyear>2010) maxyear<-2010
  # message(paste("SelAgePop called with (", minyear,",",maxyear,",", SelAge,",",pref,")"))
  
  jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, 
                              PID==pref, AgeGroup !="Total")
  return(jp)
  
}

jpGrowth <- function(){
  jp <- jpstat %>% filter(AgeGroup=="Total") %>% select(Year, Prefecture, Population)
  d <- tbl_df(dcast(jp, Prefecture ~ Year, value.var="Population")) %>% select(Prefecture, `1970`,`2010`) %>% 
    mutate(decreasing = `2010`<`1970`, cagr = round(log(`2010`/`1970`)/log(2010-1970)*100,3)) %>%
    arrange(cagr)

  return (d)  
}

# unused
calcGrowth <- function (PrefTable) {
  x <- dcast(PrefTable, AgeGroup ~ Year)  
  dx <- dim(x)
  v<-data.frame()
  for ( i in 1:dx[1]) {
    
  }
}

# unused
PrefAgePopGrowth <- function(minyear = 1970, maxyear=2010,  pref = 0) {
  if(maxyear < minyear) {
    t <- minyear
    minyear <- maxyear
    maxyear <- t
  }
  if(minyear<1970) minyear<-1970
  if(maxyear>2010) maxyear<-2010
  # message(paste("SelAgePop called with (", minyear,",",maxyear,",", SelAge,",",pref,")"))
  
  jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, 
                          PID==pref) %>% select(Year, AgeGroup, Population)
  x <- calcGrowth(jp)
  
  return(jp)
  
}

#return the population for the age group considered
AgePop <- function(minyear = 1970, maxyear=2010,  SelAge = 1) {
  if(maxyear < minyear) {
    t <- minyear
    minyear <- maxyear
    maxyear <- t
  }
  if(minyear<1970) minyear<-1970
  if(maxyear>2010) maxyear<-2010
  
  age <- as.integer(SelAge)
#   str(age)
  
  agegrp <- getAgeGroupName(age)
  #message(paste("AgePop called with (", minyear,",",maxyear,",", age,",",agegrp,")"))
  jp <- jpstat %>% filter(Year>=minyear, Year<=maxyear, AgeGroup == agegrp)
  return(jp)
  
}

# list all Prefectures
listPref <- function() {
  l <- jpstat %>% select(PID, Prefecture) %>% distinct %>% arrange(Prefecture, PID)
  v <- l$PID
  names(v) <- l$Prefecture
  z <- as.list(v)
  return (z)
}

# get prefecture name from PID
getPrefName <- function(pref = 0) {
  preflist$Prefecture[preflist$PID==pref]
}

# List Age group in human readable format
listAgeGroup <- function() {
  l <- jpstat %>% filter(AgeGroup != "Total") %>% 
              select(AgeGroup, MinAge, MaxAge)  %>% 
                distinct %>%
              arrange(MaxAge, desc(MinAge))
  i <- 1:length(l$MaxAge)
  v <- i
  names(v) <- paste0(l$MinAge, "yr - ", l$MaxAge, "yr")
  names(v) <- c(names(v[1:(length(v)-1)]),paste0(l$MinAge[max(i)],"+ yr"))

  z <- as.list(v)
  return (z)
}

# list of all years in dataset
listYear <- function() {
  l <- unique(jpstat$Year)
  return (l)
}

# list all Age Group in dataset
getAgeGroupList <- function() {
  r <- agelist %>% select(AgeGroup) %>% filter(AgeGroup!="Total") %>% distinct %>% arrange(AgeGroup)
  return (r)
}

# get Age Group name from index value
getAgeGroupName<- function (minyear) {
  # message("Hellow")
  minyear <- as.integer(minyear)
  if(minyear<3) {
    w <-paste0("a0",(minyear-1)*5, "t0",(minyear-1)*5+4)
  } else {
    w <-paste0("a",(minyear-1)*5, "t",(minyear-1)*5+4)
  }
#   message("World")
#   print(w)
  return (w)
}

# Get table of time range of interest for the selected prefecture
getBornYearStat <- function(minyear=1970, maxyear=2010, pref=0) {
  #message(paste("(",minyear,",",maxyear,",",pref,")"))
  minyear <- as.integer(minyear)
  maxyear <- as.integer(maxyear)
  bystat <- jpstat %>% filter(AgeGroup!="Total", PID==pref, Year>=minyear, Year<=maxyear)
  return(bystat)
}

#Select data for census year *yr*
getQuantileStat <- function(yr=1970) {
  if(yr<1970) yr<-1970
  qstat <- jpstat %>% filter(AgeGroup!="Total", Year ==yr)
  
  return(qstat)
}

# select data for selected age group
getAgeQuantileStat <- function(q = "a00t04") {
  
  qstat <- jpstat %>% filter(AgeGroup==q)
  
  return(qstat)
}

minyear = 1980
maxyear = 2006
pref=0
