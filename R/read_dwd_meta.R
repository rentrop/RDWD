read_dwd_meta <- function(zip_file){
  name_meta <- system2("zipinfo", 
                       paste("-2", zip_file, "Stat*"), 
                       stdout = TRUE)
  read.csv2(unz(zip_file, name_meta), 
            stringsAsFactors=FALSE,
            dec=".",
            colClasses = c("integer", "integer", "double", "double",
                           "DWDDate","DWDDate","character","NULL"),
            strip.white = TRUE
  )
}

meta_file_type <- function(type){
  if (type %in% c("wind", "sun", "air_temperature"))
    return(width = diff(c(0, 11, 21, 31, 45, 56, 66, 107, 150)))
  else if (type %in% c("precipitation", "solar", "soil_temperature", 
                       "cloudiness"))
    return(width = diff(c(0, 5, 15, 25, 39, 50, 60, 101, 144)))
}

read_dwd_meta_data <- function(archive){
  colDef <- get_dwd_colDef(type="meta")
  
  options(warn = -1)
  dat <- lapply(split(archive,1:nrow(archive)), function(file){
    con <- url(file$url, encoding="Latin1")
    dat <- read.fwf(con, meta_file_type(file$type), skip = 2, 
                    na.strings="\032", strip.white = TRUE,
                    stringsAsFactors = FALSE,
                    col.names = colDef$col.names)
    dat <- dat[-nrow(dat), ]
    dat <- data.table(dat)
  })
  options(warn = 0)
  
  dat <- do.call(rbind, dat)
  dat <- transform(dat, von_datum = as.IDate(von_datum, format="%Y%m%d"),
                   bis_datum = as.IDate(bis_datum, format="%Y%m%d"),
                   stationshoehe = as.integer(stationshoehe),
                   geoBreite = as.double(geoBreite),
                   geoLaenge = as.double(geoLaenge)
  )
  setkeyv(dat, "station_id")
  dat <- dat[, j = list(min(von_datum), max(bis_datum), mean(stationshoehe),
                        mean(geoBreite), mean(geoLaenge), unique(stationsname),
                        unique(bundesland)), by=station_id]
  setnames(dat, colDef$col.names)
  write.csv(dat, file=paste0(getwd(),"/test.csv"), row.names = FALSE)
}