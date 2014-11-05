# RDWD

RDWD is an __very experimental__ R package to read the data of the [Deutsche Wetter Dienst (DWD)](http://www.dwd.de/)
the german weather authorities.
The DWD offers all the data they measure for free which is awsome!  
__But:__ They are using a strange csv-format, which is why we wrote this package to read their data.

The following code will explain how you can read all the hourly-delivered data propperly.
We are using `zipinfo` so you will need to install it. Also we use AWS S3 to store the data but you dont need to do this.

## Base URL of all hourly climate data the DWD offers

```r
require(RDWD)
url <- "ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/climate/hourly/"
```

## Get directories of the measurement-types

```r
folder <- dwd_dirlist(url)
names(folder) = gsub("(.*?)/","",folder)
# All directories except solar have 2 subdirectories: historical and recent
type <- unlist(sapply(names(folder), function(x){
  if (x=="solar") {
    NA
  } else {
    c("historical","recent")
  }
}))
names(type) <- gsub("\\d","",names(type))
```


## Creating comprehensive list of all zip-archive the DWD offers 

```r
archive <- mapply(dwd_parse_dirlist, 
              folder[names(type)],
              type,
              names(type),
              SIMPLIFY = FALSE)
archive <- do.call(rbind, archive)
```

## cleaning up

```r
ind <- which(ls()=="archive")
rm(list = ls()[-ind])
gc()
```

## Possible subsets:

```r
archive <- archive[which(archive$station_id == 183),]
# archive <- archive[which(archive$type == "cloudiness"),]
```

## Reading the data by station
As the data is very large, `read_dwd_dat` will write the files to "./station*.csv" as
specified in `write_dwd_csv`. If you want to write them somewhere else: 
please write your own write function. See `write_dwd_s3` to see how moving them to AWS S3 might work.

```r
dat <- read_dwd_dat(archive, write_dwd_csv)
cat(paste("Time:", Sys.time()),file="read_dwd_dat_log.txt",append=TRUE,sep="\n")
row.names(dat) <- c("station_id","air_temperature", "cloudiness", 
                    "precipitation", "soil_temperature", 
                    "solar", "sun", "wind")
```

All the meta-data like the station location we read by `read_dwd_meta_data(archive)`
You can load it easily by `data(meta_dwd)`.

## fread the data
To read the data after saving it once you can use

* `fread_dwd` to read it in and change class of idate and itime accordingly
* `fread_s3` wrapper around `fread_dwd` to pull data from S3 via the AWS CLI

[![Analytics](https://ga-beacon.appspot.com/UA-56469723-1/rentrop/RDWD)](https://github.com/igrigorik/ga-beacon)
