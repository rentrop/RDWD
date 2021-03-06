#' wrapper function for data.table::fread that converts columns idate and itime to appropriate classes
#' 
#' @param input character specifiing the file to be read (file should contain idate- and itime-column)
#' @param other parameters passed to \code{\link[data.table]{fread}}
#' @return a \code{data.table} by default. See \code{\link[data.table]{fread}} for more details about \code{...} usage.
#' @examples
#' paths <- find.package("RDWD")
#' fread_dwd(paste0(paths,"/data/station183.csv"))

fread_dwd <- function(input, ...){
  dat <- fread(input, ...)
  if (all(c("idate", "itime") %in% names(dat))) {
    dat[, `:=`(idate = as.IDate(idate),
               itime = as.ITime(itime))]
  } else warning("No columns named idate and itime found")
  dat
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

#' fread dwd - data from AWS S3 Storage
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
    if(zip) for(k in seq_along(loc_file)) unzip(loc_file[k], exdir = loc_path)
    dat <- lapply(sub(".tar.gz", ".csv", loc_file), fread_dwd)
    
    file.remove(loc_file)
    if(zip) file.remove(sub(".tar.gz", ".csv", loc_file))
    
    dat
  } else {
    return(list())
  }
}