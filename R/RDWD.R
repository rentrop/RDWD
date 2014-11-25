#' RDWD.
#'
#' @name RDWD
#' @docType package
#' @import data.table RCurl
NULL

#' All zip-archives of hourly data the DWD offers (as of 2014-11-25) 
#'
#' A dataset containing the URL's and some extracted information about all
#'  hourly weather data the DWD offers
#'
#' \itemize{
#'   \item url. url of the zip-archive
#'   \item station_id. ID of the weather station
#'   \item historical. Does this archive contain historical or recent data (historical, recent, NA)
#'   \item type. What kind of weather measurements does this archive include (wind, precipitation, sun, air_temperature, solar, soil_temperature, cloudiness)
#' }
#'
#' @docType data
#' @keywords datasets
#' @name archives_dwd
#' @usage data(archives_dwd)
#' @format A data frame with 7372 rows and 4 variables
#' @examples
#' \dontrun{
#' # To get an up to date version of archives_dwd run the following code
#' require(RDWD)
#' url <- "ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/hourly/"
#' folder <- dwd_dirlist(url)
#' names(folder) = gsub("(.*?)/","",folder)
#' # All directories except solar have 2 subdirectories: historical and recent
#' type <- unlist(sapply(names(folder), function(x){
#'   if (x=="solar") {
#'      NA
#'    } else {
#'      c("historical","recent")
#'    }
#'    }))
#'    names(type) <- gsub("\\d","",names(type))
#'    archive <- mapply(dwd_parse_dirlist, 
#'                  folder[names(type)],
#'                  type,
#'                  names(type),
#'                  SIMPLIFY = FALSE)
#'    archive <- do.call(rbind, archive)
#'    }
NULL

#' All (hourly) meta data of stations the DWD offers (as of 2014-11-17) 
#'
#' A dataset containing meta information about all the stations DWD offers
#'
#' \itemize{
#'   \item station_id. ID of the weather station
#'   \item von_datum. first date of recording
#'   \item bis_datum. last date of recording
#'   \item stationshoehe. sea level of station
#'   \item geoBreite. latitude
#'   \item geoLaenge. longitude
#'   \item stationsname. name of the weather station
#'   \item bundesland. federal state 
#' }
#'
#' @docType data
#' @keywords datasets
#' @name meta_dwd
#' @usage data(meta_dwd)
#' @format A data frame with 2174 rows and 8 variables
#' @examples
#' \dontrun{
#' # To get an up to date version of meta_dwd run the following code
#' require(RDWD)
#' url <- "ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/hourly/"
#' folder <- dwd_dirlist(url)
#' names(folder) = gsub("(.*?)/","",folder)
#' type <- unlist(sapply(names(folder), function(x){
#'  if (x=="solar") {
#'    NA
#'  } else {
#'    c("historical","recent")
#'  }
#' }))
#' names(type) <- gsub("\\d","",names(type))
#' archive <- mapply(dwd_parse_dirlist,
#'                   folder[names(type)],
#'                   type,
#'                   names(type),
#'                   meta = TRUE,
#'                   SIMPLIFY = FALSE)
#' archive <- do.call(rbind, archive)
#' meta_dwd <- read_dwd_meta_data(archive)
#' 
#' setkeyv(meta_dwd, "station_id")
#' meta_dwd_what <- dcast.data.table(meta_dwd, station_id~what,
#'                                   value.var="measured", 
#'                                   fun = any)
#' setkeyv(meta_dwd_what, "station_id")
#' meta_dwd[, c("von_datum", "bis_datum") := wind_dates(what, von_datum, 
#'                                                      bis_datum), 
#'            by = station_id]
#' meta_dwd[,`:=`(stationshoehe = mean(stationshoehe),
#'                geoBreite = mean(geoBreite),
#'                geoLaenge = mean(geoLaenge),
#'                stationsname = unique(stationsname),
#'                bundesland = unique(bundesland)), by = station_id]
#'  meta_dwd[, c("what", "measured") := NULL]
#'  meta_dwd <- unique(meta_dwd)
#'  meta_dwd <- merge(meta_dwd, meta_dwd_what, by="station_id")
#'  rm(meta_dwd_what)
#'  }
NULL