fread_dwd <- function(input){
  dat <- fread(input)
  dat[, `:=`(idate = as.IDate(idate),
             itime = as.ITime(itime))]
}

paste_station <- function(..., collapse=NULL, zip = FALSE){
  if (zip) {
    paste0("station",...,".tar.gz", collapse=collapse)
  } else {
    paste0("station",...,".csv", collapse=collapse)
  }
}

cp_s3_files <- function(file, dir_s3, loc_path){
  system(paste("aws s3 cp",
               paste0("s3://", dir_s3),
               loc_path,                
               "--exclude '*'",
               paste("--include", shQuote(file), collapse=" "),
               "--recursive"
  ))
}

#' fread data from s3 empty
#' @param station_id if ids = TRUE numerical vector of station_id's else character-vector of files to download from S3
#' @param ids logical see station_id
#' @param zip logical if the files/ids specified in station_id are ziped
#' @param s3_path character path to s3-Bucket
#' @param loc_path path where the data is saved temporarily
#' @return List of data.tables which were downloaded
#' @examples
#' fread_s3(183)

fread_s3 <- function(station_id, 
                     ids = TRUE, 
                     zip = TRUE,
                     dir_s3 = "dwd-oekoproj", 
                     loc_path = tempdir()){
  if (ids) station_id <- paste_station(station_id, zip = zip)
  
  cp_s3_files(station_id, dir_s3 = dir_s3, loc_path = loc_path)
  
  ind <- station_id %in% list.files(loc_path)
  if (any(!ind)) {
    warning(paste("File", station_id[!ind], "not found in", dir_s3, "\n"))
  }
  if(any(ind)){
    loc_file <- paste0(loc_path, "/", station_id[ind])
    if(zip) unzip(loc_file, exdir = loc_path)
    dat <- lapply(sub(".tar.gz", ".csv", loc_file), fread_dwd)
    
    file.remove(loc_file)
    if(zip) file.remove(sub(".tar.gz", ".csv", loc_file))
    
    dat
  } else {
    return(list())
  }
}