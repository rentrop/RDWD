dwd_dirlist <- function(url, full = TRUE){
  dir <- unlist(
    strsplit(
      getURL(url,
             ftp.use.epsv = FALSE,
             dirlistonly = TRUE),
      "\n")
  )
  if(full) dir <- paste0(url, dir)
  return(dir)
}

dwd_parse_dirlist <- function(url, historical, type, meta = FALSE){
  if (is.na(historical)){
    url <- paste0(url,"/")
  } else {
    url <- paste0(url,"/",historical,"/")
  }
  print(url)
  zip_file <- dwd_dirlist(url, full = FALSE)
  if (meta){
    if(length(grep("*.txt", zip_file)) != 0){
      data.frame(url = paste0(url, zip_file[grep("*.txt", zip_file)]),
                 historical = historical, type = type, 
                 stringsAsFactors = FALSE)
    }
  } else {
    station_id <- as.numeric(sub('\\D*(\\d{5}).*', '\\1', zip_file))
    data.frame(url = paste0(url,zip_file), station_id,  
               historical = historical, type = type,
               stringsAsFactors = FALSE)
  }
}