#' Saves a data.table as csv-file
#'
#' @param dat a data.table
#' @return Nothing

write_dwd_csv <- function(dat){
  filename = paste0("station",dat[1,station_id],".csv")
  write.csv(dat, file=paste0(getwd(),"/",filename), row.names = FALSE)
  invisible(1)
}

#' Saves a data.table as csv- or tar.gz file and moves it to S3
#'
#' @param dat a data.table
#' @param zip logical
#' @param dir character string of S3 bucket/directory like "my_bucket"
#' @return Nothing

write_dwd_s3 <- function(dat, zip = TRUE, 
                         dir_s3 = stop("please provide s3 directory")){
  filename = paste0("station",dat[1,station_id])
  write.csv(dat, file=paste0(getwd(),"/",filename,".csv"), row.names = FALSE)
  
  if (zip){
    zip(paste0(getwd(),"/",filename,".tar.gz"), paste0(filename,".csv"))
    file.remove(paste0(getwd(),"/",filename,".csv"))
    file = paste0(getwd(),"/",filename,".tar.gz")
  } else {
    file = paste0(getwd(),"/",filename,".csv")
  }
  system(paste("aws s3 mv", file, paste0("s3://", dir_s3)))
  invisible(1)
}