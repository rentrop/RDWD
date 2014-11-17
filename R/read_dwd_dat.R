read_dwd_dat <- function(archive, write_station_dat){
  archive_split <- split(archive,archive$station_id)
  cat(paste("Time:", Sys.time()), file="read_dwd_dat_log.txt", sep="\n")
  
  vapply(archive_split, function(station){ 
    cat(paste("station_id = ", station[1,"station_id"]), 
        file="read_dwd_dat_log.txt", append=TRUE, sep="\n")
    
    dat <- lapply(split(station, 1:nrow(station)), read_dwd_table) 
    
    dat <- clean_dwd_table(station, dat) 
    
    for(i in seq_along(dat)){
      setkeyv(dat[[i]], c("station_id","idate","itime"))
      dat[[i]] <- unique(dat[[i]])
    }
    rm(i)
    dat <- Reduce(function(x, y) {
      merge(x, y, all=TRUE, by=c("station_id","idate","itime"))}, dat)
    
    write_station_dat(dat)
    
    rm(dat)
    gc()
    cat("", file="read_dwd_dat_log.txt",append=TRUE, sep="\n")
    return(c(station_id = station[1,"station_id"], 
             c("air_temperature", "cloudiness", "precipitation", 
               "soil_temperature", 
               "solar", "sun", "wind") %in% unique(station$type)))
  }, c(station_id = numeric(1), type = logical(7)))
}

read_dwd_table <- function(file){
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
    cat(paste("done:", file$url), 
        file="read_dwd_dat_log.txt",append=TRUE, sep="\n")
    dat
  }, error = function(e){
    dat <- read.table(text = "",
                      colClasses = colDef$colClasses,
                      col.names = colDef$col.names)
    cat(paste("error:", file$url), 
        file="read_dwd_dat_log.txt",append=TRUE, sep="\n")
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
  dat[[which(station$type == "solar")]][, sonnenzenit := mean(sonnenzenit), 
                                          by = list(idate, itime)]
  
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
  
  return(dat)
}