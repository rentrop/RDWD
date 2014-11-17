get_dwd_colDef <- function(historical="historical", type="wind"){
  colDef <- switch(type,
                   wind = switch(historical, historical = colDef_hist_wind(),
                                 recent = colDef_rece_wind()),
                   sun = switch(historical, historical = colDef_hist_sun(),
                                recent = colDef_rece_sun()),
                   soil_temperature = colDef_soil_temperature(),
                   precipitation = colDef_precipitation(),
                   cloudiness = colDef_cloudiness(),
                   air_temperature = switch(historical, 
                                            historical = colDef_hist_air_temperature(),
                                            recent = colDef_rece_air_temperature()),
                   solar = colDef_solar(),
                   meta = colDef_meta()            
  )
}

colDef_hist_wind <- function(){
  colClasses <- c("integer", "DWDDaytime", "NULL",
                  "integer", "integer",
                  "double", "integer", 
                  "NULL")
  col.names <- c("station_id", "mess_datum", "NULL",
                 "qualitaets_niveau_wind", "struktur_version_wind",
                 "windgeschwindigkeit", "windrichtung",
                 "NULL") 
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_rece_wind <- function(){
  colClasses <- c("integer", "DWDDaytime",
                  "integer", "integer",
                  "double", "integer", 
                  "NULL")
  col.names <- c("station_id", "mess_datum", 
                 "qualitaets_niveau_wind", "struktur_version_wind",
                 "windgeschwindigkeit", "windrichtung",
                 "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_hist_sun <- function(){
  colClasses <- c("integer", "DWDDaytime", "NULL",
                  "integer", "integer",
                  "double", "NULL")
  col.names <- c("station_id", "mess_datum", "NULL",
                 "qualitaets_niveau_sun", "struktur_version_sun",
                 "stundensumme_sonnenschein", "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_rece_sun <- function(){
  colClasses <- c("integer", "DWDDaytime",
                  "integer", "integer",
                  "double", "NULL")
  col.names <- c("station_id", "mess_datum",
                 "qualitaets_niveau_sun", "struktur_version_sun",
                 "stundensumme_sonnenschein", "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_soil_temperature <- function(){
  colClasses <- c("integer", "DWDDaytime",
                  "integer", 
                  "double", "double",
                  "double", "double",
                  "double", "double",
                  "double", "double",
                  "double", "double",
                  "NULL")
  col.names <- c("station_id", "mess_datum",
                 "qualitaets_niveau_soil_temperature", 
                 "erdbodentemperatur", "mess_tiefe", 
                 "erdbodentemperatur", "mess_tiefe", 
                 "erdbodentemperatur", "mess_tiefe",
                 "erdbodentemperatur", "mess_tiefe",
                 "erdbodentemperatur", "mess_tiefe",
                 "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_precipitation <- function(){
  colClasses <- c("integer", "DWDDaytime",
                  "integer", 
                  "integer",
                  "double", "integer",
                  "NULL")
  col.names <- c("station_id", "mess_datum",
                 "qualitaets_niveau_precipitation", 
                 "niederschlag_gefallen_ind",
                 "niederschlagshoehe", "niederschlagsform",
                 "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_cloudiness <- function(){
  colClasses <- c("integer", "DWDDaytime",
                  "integer", "integer",
                  "NULL")
  col.names <- c("station_id", "mess_datum",
                 "qualitaets_niveau_cloudiness", "gesamt_bedeckungsgrad",
                 "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_hist_air_temperature <- function(){
  colClasses <- c("integer", "DWDDaytime", "NULL",
                  "integer", 
                  "integer",
                  "double", "double", "NULL")
  col.names <- c("station_id", "mess_datum", "NULL",
                 "qualitaets_niveau_air_temperature", 
                 "struktur_version_air_temperature",
                 "lufttemperatur", "rel_feuchte", "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_rece_air_temperature <- function(){
  colClasses <- c("integer", "DWDDaytime",
                  "integer", 
                  "integer",
                  "double", "double", "NULL")
  col.names <- c("station_id", "mess_datum",
                 "qualitaets_niveau_air_temperature",
                 "struktur_version_air_temperature",
                 "lufttemperatur", "rel_feuchte", "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_solar <- function(){
  colClasses <- c("integer", "character",
                  "integer", "integer",
                  "double", "double",
                  "double", "double",
                  "DWDDaytime", "NULL")
  col.names <- c("station_id", "mess_datum_woz",
                 "qualitaets_niveau_solar", "sonnenscheindauer",
                 "diffus_himmel_kw_j", "global_kw_j",
                 "athmosphaere_lw_j", "sonnenzenit",
                 "mess_datum", "NULL")
  return(list(colClasses = colClasses, col.names = col.names))
}

colDef_meta <- function(){
  colClasses <- c("integer", "DWDDate", "DWDDate",
                  "integer", "double", "double",
                  "char", "char")
  col.names <- c("station_id", "von_datum", "bis_datum",
                 "stationshoehe", "geoBreite", "geoLaenge",
                 "stationsname", "bundesland")
  return(list(colClasses = colClasses, col.names = col.names))
}