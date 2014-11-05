setOldClass("DWDDaytime")
setAs("character", "DWDDaytime", function(from){IDateTime(strptime(from, "%Y%m%d%H"))})

setOldClass("DWDDate")
setAs("character", "DWDDate", function(from){IDateTime(strptime(from, "%Y%m%d"))})