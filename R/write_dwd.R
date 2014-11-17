#' Writes dat as csv-file
#'
#' @param dat a data.table
#' @return -

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

write_dwd_s3 <- function(dat, zip = TRUE){
  filename = paste0("station",dat[,head(station_id,1)])
  write.csv(dat, file=paste0(getwd(),"/",filename,".csv"), row.names = FALSE)
  zip(paste0(getwd(),"/",filename,".tar.gz"), paste0(getwd(),"/",filename,".csv"))
  
  if (zip){
    file = paste0(getwd(),"/",filename,".tar.gz")
  } else {
    file = paste0(getwd(),"/",filename,".csv")
  }

  system(paste("aws s3 mv", 
               file, 
               paste0("s3://dwd-oekoproj/station-dat/")
  ))
}