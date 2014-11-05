fread_dwd <- function(input){
  dat <- fread(input)
  dat[, `:=`(idate = as.IDate(idate),
             itime = as.ITime(itime))]
}

paste_station <- function(..., collapse=NULL){
  paste0("station",...,".csv", collapse=collapse)
}

cp_s3_files <- function(file, s3_path, loc_path){
  system(paste("aws s3 cp",
               s3_path,
               loc_path,                
               "--exclude '*'",
               paste("--include", shQuote(file), collapse=" "),
               "--recursive"
  ))
}

fread_s3 <- function(station_id, 
                     ids = TRUE, 
                     s3_path="s3://dwd-oekoproj/", loc_path=NULL){
  if (ids) station_id <- paste_station(station_id)
  if (is.null(loc_path)) loc_path <- tempdir()
  
  cp_s3_files(station_id, s3_path = s3_path, loc_path = loc_path)
  
  ind <- station_id %in% list.files(loc_path)
  if (any(!ind)) {
    warning(paste("File", station_id[!ind], "not found in", s3_path, "\n"))
  }
  
  if(any(ind)){
    loc_path <- paste0(loc_path, "/", station_id[ind]) 
    dat <- lapply(loc_path, fread_dwd)
    
    file.remove(loc_path)
    
    dat
  } else {
    return(list())
  }
}