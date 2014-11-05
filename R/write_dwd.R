write_dwd_csv <- function(dat){
  filename = paste0("station",dat[,head(station_id,1)],".csv")
  write.csv(dat, file=paste0(getwd(),"/",filename), row.names = FALSE)
}

write_dwd_s3 <- function(dat){
  filename = paste0("station",dat[,head(station_id,1)],".csv")
  write.csv(dat, file=paste0(getwd(),"/",filename), row.names = FALSE)
  
  system(paste("aws s3 mv", 
               paste0(getwd(),"/",filename), 
               paste0("s3://dwd-oekoproj/station-dat/",filename)
  ))
}