rm(list=ls())
library(XLConnect)
library(dplyr)
wb<-loadWorkbook("age-1970-2000.xls")
wbs<-getSheets(wb)
mystat <- data.frame()
mystat_ctr <-1
for (i in seq(wbs)) {
  tws <- tbl_df(readWorksheet(wb, wbs[i]))
  cn <-colnames(tws)
  ncn <- c("Col1", "PID", "Pref", "Total")
  for(j in 5:length(cn)){
    ncn <- c(ncn, paste0("a", (j-5)*5,"t",(j-4)*5-1))
  }
  colnames(tws)<-ncn
  tdim <- dim(tws)
  ws <- tws[9:tdim[1],2:tdim[2]]
  ws <- tws[9:tdim[1],1:tdim[2]]
  
  wdim <- dim(ws)
  for(k in 1:wdim[1]) {
    ws[k,]<-gsub(",","", ws[k,])
  }
  
  ws[1,2]<-"00"
  ws<-ws[!is.na(ws$PID),2:wdim[2]]
  fdim <- dim(ws)
  fcn <- colnames(ws)
  ## reshape
  for (p in 1:fdim[1]) {
    for(q in 3:fdim[2]) {
      mystat[mystat_ctr,1]  <- wbs[i]
      mystat[mystat_ctr,2]  <- ws[p,1]
      mystat[mystat_ctr,3]  <- ws[p,2]
      mystat[mystat_ctr,4]  <-fcn[q]
      mystat[mystat_ctr,5]  <-ws[p,q]
      mystat_ctr <- mystat_ctr+1
    }
  }
}
colnames(mystat)<- c("Year","PID", "Prefecture","AgeGroup","Population")

write.csv(mystat, file="japancensus_long_1.csv")
