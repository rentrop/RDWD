#' RDWD.
#'
#' @name RDWD
#' @docType package
#' @import data.rable RCurl
NULL

#' All zip-archives of hourly data the DWD offers (as of 2014-10-11) 
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
#' @format A data frame with 6484 rows and 4 variables
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