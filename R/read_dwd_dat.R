#' Read and save archives from DWD
#' 
#' @param archive data.frame with columns "url", "station_id", "historical", "type" see ?archives_dwd
#' @param write_station_dat function how to save the data
#' @param logging logical | If TRUE a log-file of the process is generated and saved as "read_dwd_dat_log.txt"
#' @param ... further parameters for write_station_dat(dat, ...) 
#' @return data.frame | which station measures what
#' @examples 
#' data(archives_dwd)
#' archives_dwd <- archives_dwd[which(archives_dwd$station_id == 183 & archives_dwd$type == "wind"),]
#' read_dwd_dat(archives_dwd, write_dwd_csv, logging = FALSE)
#' if(!file.remove("station183.csv")) stop("station183.csv not found")

read_dwd_dat <- function(archive, write_station_dat, logging = TRUE, ...){
  types <- unique(archive$type)
  archive_split <- split(archive,archive$station_id)
  if(logging) cat(paste("Time:", Sys.time()), file="read_dwd_dat_log.txt", sep="\n")
  
  res <- vapply(archive_split, function(station){ 
    if(logging) {cat(paste("station_id = ", station[1,"station_id"]), 
                 file="read_dwd_dat_log.txt", append=TRUE, sep="\n")}
    
    dat <- lapply(split(station, 1:nrow(station)), read_dwd_table, logging) 
    
    dat <- clean_dwd_table(station, dat) 
    
    for(i in seq_along(dat)){
      setkeyv(dat[[i]], c("station_id","idate","itime"))
      dat[[i]] <- unique(dat[[i]])
    }
    rm(i)
    dat <- Reduce(function(x, y) {
      merge(x, y, all=TRUE, by=c("station_id","idate","itime"))}, dat)
    
    write_station_dat(dat, ...)
    
    rm(dat)
    gc()
    if(logging) cat("", file="read_dwd_dat_log.txt",append=TRUE, sep="\n")
    c(station[1,"station_id"],types %in% unique(station$type))
  }, setNames(c(numeric(1), logical(length(types))), c("station_id", types)))
  if(logging) {cat(paste("Time:", Sys.time()),file="read_dwd_dat_log.txt",
               append=TRUE,sep="\n")}
  res
}

read_dwd_table <- function(file, logging){
  temp <- tempfile()
  download.file(file$url,temp)
  colDef <- get_dwd_colDef(historical = file$historical, type = file$type)  
  file_name <- system2("zipinfo", paste("-2", temp, "produkt*"), stdout = TRUE)
  dat <- tryCatch({
    dat <- read.table(unz(temp, file_name), 
                      stringsAsFactors=FALSE,
                      na.strings="\032",
                      skip=1,
                      sep=";",
                      colClasses = colDef$colClasses,
                      col.names = colDef$col.names)
    dat <- dat[-nrow(dat),]
    if(logging) {cat(paste("done:", file$url), 
                 file="read_dwd_dat_log.txt",append=TRUE, sep="\n")}
    dat
  }, error = function(e){
    dat <- read.table(text = "",
                      colClasses = colDef$colClasses,
                      col.names = colDef$col.names)
    if(logging) {cat(paste("error:", file$url), 
                 file="read_dwd_dat_log.txt",append=TRUE, sep="\n")}
    dat
  }, finally = {}
  )
  ind <- which(names(dat) == "mess_datum")
  dat <- data.table(dat$mess_datum, dat[,-ind])
  closeAllConnections()
  unlink(temp)
  dat
}

clean_dwd_table <- function(station, dat){
  for (k in which(station$type == "solar")){
    dat[[k]][, sonnenzenit := mean(sonnenzenit), by = list(idate, itime)]
  }
  
  multi_dat <- names(which(table(station$type)==2))
  to_be_deleted <- integer()
  for(type in multi_dat){
    hist <- which(station$type == type & station$historical == "historical")
    rece <- which(station$type == type & station$historical == "recent")
    to_be_deleted <- c(to_be_deleted,rece)
    dat[[hist]] <- rbindlist(list(dat[[hist]],dat[[rece]]))
  }
  
  to_be_deleted <- sort(to_be_deleted) - seq_along(to_be_deleted) + 1
  for(i in to_be_deleted){
    dat[[i]] <- NULL
  }
  
  dat
}