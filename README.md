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
data(archives_dwd)
```

## Possible subsets:

```r
archives_dwd <- archives_dwd[which(archives_dwd$station_id == 183),]
# archives_dwd <- archives_dwd[which(archives_dwd$type == "cloudiness"),]
```

## Reading the data by station
As the data is very large, `read_dwd_dat` will write the files to "./station*.csv" as
specified in `write_dwd_csv`. If you want to write them somewhere else: 
please write your own write function. See `write_dwd_s3` to see how moving them to AWS S3 might work.

```r
dat <- read_dwd_dat(archives_dwd, write_dwd_csv, ...)
```

All the meta-data like the station location we read by `read_dwd_meta_data(archive)`
You can load it easily by `data(meta_dwd)`.

## fread the data
To read the data after saving it once you can use

* `fread_dwd` to read it in and change class of idate and itime accordingly
* `fread_s3` wrapper around `fread_dwd` to pull data from S3 via the AWS CLI

[![Analytics](https://ga-beacon.appspot.com/UA-56469723-1/rentrop/RDWD)](https://github.com/igrigorik/ga-beacon)
