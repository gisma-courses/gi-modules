---
title: Analysis of massive sentinel data using STAC and gdalcubes
author: Marius Appel, Chris Reudenbach
date: '2022-02-15'
slug: []
bibliography: references.bib
categories:
  - rsgi
tags:
  - ecology
  - forest
  - Remote Sensing
subtitle: 'Time series and change detection using COG imagery and gdalcubes'
description: 
image: '/img/restefond-sp.jpg'
toc: yes
output:
  blogdown::html_page:
    keep_md: yes
weight: 100
---




# Introduction

Big thanks to Marius Appel who gave 2021 at OpenGeoHub Summer School 2021 a great  [workshop](https://appelmar.github.io/ogh2021/tutorial.html). This tutorial is an adapted version of it.

Sentinel-2 is currently the most important platform for Earth observation in all areas, but especially for climate change, land use and ecological issues at all levels, from the upper micro level to the global level.

 There are two operational Sentinel-2 satellites: Sentinel-2A and Sentinel-2B, both in sun-synchronous polar orbits and 180 degrees out of phase. This arrangement allows them to cover the Earth at mid-latitudes with a flyover time of about 5 days. 

The Sentinel-2 data are therefore predestined to record spatial and temporal changes on the Earth's surface (in early summer the forest was green, in late summer it has disappeared). They are ideal for timely studies before and after natural disasters or for biomass balancing, etc. 

## Cloud-Optimised GeoTIFFs (COGs)

Unfortunately, the official [Sentinel-2 archives](https://scihub.copernicus.eu/dhus/#/home) are anything but really user-friendly.  Even with highly convenient toos as [`sen2r`](https://sen2r.ranghetti.info/) it is sometimes cumbersome to process tTechnically the processed product levels are available to for download preprocessed as L1C and L2A products in JP2K format. Most of the data is stored on the long term storages. the preferred file format is JP2K which is storage efficient but has to be fully downloaded locally by the user and thus have high access costs and huge requirements for local storage space. The Cloud-Optimised GeoTIFFs (COGs) allow only the areas of interest to be loaded and also the processing is significantly faster. However, it requires optimised cloud services and technically a different access logic than in the processing chains used so far.

## SpatioTemporal Asset Catalog (STAC) 

The [SpatioTemporal Asset Catalog](https://stacspec.org/) (STAC) provides a common language for simplified indexing and searching of geospatial data. A "spatio-temporal asset" is a file that contains information in a specific space and time.

This approach allows all providers of spatio-temporal data (imagery, SAR, point clouds, data cubes, full motion video, etc.) to provide SpatioTemporal Asset Catalogs (STAC) for their data. STAC focuses on an easy to implement standard that organisations can use to make their data available in a durable and reliable way.

[Element84](https://www.element84.com/) has provided a public API called Earth-search, a central search catalogue for all public AWS datasets using STAC (including the new Sentinel-2 COGs). this contains, beginning 1 November 2017, more than 11.4 million Sentinel-2 scenes worldwide. 

# Goals

This tutorial demonstrates how we can access and process Sentinel-2 data in the cloud using the R packages: [`rstac`](https://cran.r-project.org/package=rstac) [@rstac] and [`gdalcubes`](https://cran.r-project.org/package=gdalcubes) [@gdalcubes]. Other packages used in this tutorial include [`stars`](https://cran.r-project.org/package=stars)[@stars] and [`tmap`](https://cran.r-project.org/package=tmap)[@tmap] for creating interactive maps, [`sf`](https://cran.r-project.org/package=sf)[@sf] for processing vector data, and [`colorspace`](https://cran.r-project.org/package=colorspace)[@colorspace] for visualizations with accessible colors.

*Notice that the examples have been selected to yield computation times acceptable for a live demonstration. Please feel free to apply the examples on larger areas of interest and/or using a higher spatial resolution.*


Furthermore, it shows different approaches to time series and difference analyses with different indices using the example of the Marburg Open Forest (MOF) for the period 1997-2021. 


Other packages used in this tutorial include [`stars`](https://cran.r-project.org/package=stars) and [`tmap`](https://cran.r-project.org/package=tmap) for creating interactive maps, [`sf`](https://cran.r-project.org/package=sf) for processing vector data, and 

## Retrieve some Areas of Interest
Most of the earth surface related remote sensing activities are heavily "disturbed" by the astmosphere , especially by clouds. So we aim to find a cloud-freesentinel data of an (arbitrary) AOI. The `rstac` package provides a convenient tool to find and filter adequate Sentinel-2 images. However, to address the AOI we need to provide the extend via the `bbox` argument of the corresponding function `stac_search()`. So first we  need to derive and transform the bounding box to latitude / longitude (WGS84) values, for which we use the `st_bbox()` and `st_transform()` functions. In addition we adapt the projection of the referencing vector objects to all later needs. Please note to project to three different CRS is for this examples convenience and clarity and somewhat cumbersome. The frest shape is provided in the data section. You may have a look at tutorial one for examples of retrieving vector geometries for this purpose.


```r
library(sf)
library(raster)
library(tidyverse)
library(downloader)
library(tmap)
library(tmaptools)
library(mapview)
library(gdalcubes)
library(OpenStreetMap)
library(stars)

forest = st_read(paste0(tutorialDir,"forest/only_forest.shp"))
forest_4326 =st_transform(forest,crs = 4326)
forest_3035 =st_transform(forest,crs = 3035)
forest_32632 =st_transform(forest,crs = 32632)

# call background map
osm_forest <- read_osm(forest,type = "bing")

# mapping the extents and boundaries of the choosen geometries
tmap_mode("view")
tmap_options(check.and.fix = TRUE) + 
  tm_basemap(server = c("Esri.WorldGrayCanvas", "OpenStreetMap", "Esri.WorldTopoMap","Esri.WorldImagery")) +
  tm_shape(forest) +   
  tm_polygons(alpha = 0.4, col="ZIELBESTOC")
```

The area is the Marbug Open forest (MOF) the Research Forest of the Marburg University.

## Time series analysis

This example shows how complex times series methods from external R packages can be applied in cloud computing environments using [`[rstac`](https://cran.r-project.org/package=rstac)  and [`gdalcubes`](https://cran.r-project.org/package=gdalcubes). We will use the [`bfast` R package](https://cran.r-project.org/package=bfast) containing unsupervised change detection methods identifying structural breakpoints in vegetation index time series. Specifically, we will use the `bfastmonitor()` function to monitor changes on a time series of Sentinel-2 imagery.

Compared to the first example, our study area is rather small, covering a small forest area in the southeast of Berlin. The area of interest is again available as a polygon in a GeoPackage file `gruenheide_forest.gpkg`, which for example can be visualized in a map using the [`tmap` package](https://cran.r-project.org/package=tmap) package.


### Querying images with `rstac`

Using the `rstac` package, we first request all available images from 2017 to 2020 that intersect with our region of interest. Here, since the polygon has WGS84 as CRS, we do **not** need to transform the bounding box before using the `stac_search()` function.


```r
library(rstac)
s = stac("https://earth-search.aws.element84.com/v0")
items <- s |>
    stac_search(collections = "sentinel-s2-l2a-cogs",
                bbox = c(st_bbox(forest_4326)["xmin"],
                         st_bbox(forest_4326)["ymin"],
                         st_bbox(forest_4326)["xmax"],
                         st_bbox(forest_4326)["ymax"]), 
                datetime = "2017-01-01/2021-12-31",
                limit = 1000) |>
    post_request() 
items
# Date and time of first and last images
range(sapply(items$features, function(x) {x$properties$datetime}))
```

This gives us 516 images recorded between Nov. 2017 and Dec. 2021.

### Creating a monthly Sentinel-2 data cube

To build a regular monthly data cube, we again need to create a gdalcubes image collection from the STAC query result. Notice that to include the `SCL` band containing per-pixel quality flags (classification as clouds, cloud-shadows, and others), we need to explicitly list the names of the assets. We furthermore ignore images with 75% or more cloud coverage.


```r
library(gdalcubes)
assets = c("B01","B02","B03","B04","B05","B06", "B07","B08","B8A","B09","B11","SCL")
s2_collection = stac_image_collection(items$features, asset_names = assets, property_filter = function(x) {x[["eo:cloud_cover"]] < 75}) 
s2_collection
```

The result still contains 92 images, from which we can now create a data cube. We use the transformed (UTM) bounding box of our polygon as spatial extent, 10 meter spatial resolution, bilinear spatial resampling and derive monthly median values for all pixel values from multiple images within a month, if available. Notice that we add 100m to each side of the cube.


```r
v = cube_view(srs = "EPSG:32632", 
              dx = 10, 
              dy = 10, 
              dt = "P1M",  
              aggregation = "median", 
              extent = list(t0 = "2017-01",
                            t1 = "2021-12", 
                            left = st_bbox(forest_32632)["xmin"]-100, 
                            right = st_bbox(forest_32632)["xmax"]+100,
                            bottom = st_bbox(forest_32632)["ymin"]-100, 
                            top = st_bbox(forest_32632)["ymax"]+100),
              resampling = "bilinear")
v
```

Next, we create a data cube, subset the red and near infrared bands and crop by our polygon, which simply sets pixel values outside of the polygon to NA. Afterwards we save the data cube as a single netCDF file. Notice that this is not neccessary but storing intermediate results makes debugging sometimes easier, especially if the methods applied afterwards are computationally intensive.



```r
  s2.mask = image_mask("SCL", values = c(3,8,9))
  gdalcubes_options(threads = 24, ncdf_compression_level = 5)
  raster_cube(s2_collection, v, mask = s2.mask) |>
    select_bands(c("B04","B08")) |>
    filter_geom(forest_32632$geometry) |>
    write_ncdf(file.path(tutorialDir,"lahntal.nc"),overwrite = TRUE)
```

### Reduction over space and time

To get an overview of the data, we can compute simple summary statistics (applying reducer functions) over dimensions. 

The `"count"` reducer is often very useful to get an initial understanding of an image collection:


```r
ncdf_cube(file.path(tutorialDir,"lahntal.nc")) |>
  reduce_time("count(B04)") |>
  plot(key.pos = 1, zlim=c(0,50), col = viridis::viridis, nbreaks = 10)
```

We can see that most time series contain valid observations for 30-50 months, which should be sufficient for our example. Similarly, it is also possible to reduce over space, leading to summary time series.

## Straightforward NDVI

Below, we derive minimum, maximum, and mean monthly kNdvi (first) and NDVI (second) values over all pixel time series.


```r
library(colorspace)
ndvi.col = function(n) {
  rev(sequential_hcl(n, "Green-Yellow"))
}
        
ncdf_cube(file.path(tutorialDir,"lahntal.nc")) |>
  apply_pixel("(1-exp(-((B08/10000)-(B04/10000))^2/(2))) / (1+exp(-((B08/10000)-(B04/10000))^2/(2)))", "kNDVI") |>
  reduce_time("min(kNDVI)", "max(kNDVI)", "mean(kNDVI)") |>
  plot(key.pos = 1,  col = ndvi.col, nbreaks = 4,)
```



```r
library(colorspace)
ndvi.col = function(n) {
  rev(sequential_hcl(n, "Green-Yellow"))
}
ncdf_cube(file.path(tutorialDir,"lahntal.nc")) |>
  apply_pixel("(B08-B04)/(B08+B04)", "NDVI") |>
  reduce_time("min(NDVI)", "max(NDVI)", "mean(NDVI)") |>
  plot(key.pos = 1, zlim=c(-0.2,1), col = ndvi.col, nbreaks = 128)
```

Possible reducers include `"min"`, `"mean"`, `"median"`, `"max"`, `"count"` (count non-missing values), `"sum"`, `"var"` (variance), and `"sd"` (standard deviation). Reducer expressions are always given as a string starting with the reducer name followed by the band name in parentheses. Notice that it is possible to mix reducers and bands.



```r
ncdf_cube(file.path(tutorialDir,"lahntal.nc")) |>
  apply_pixel("(B08-B04)/(B08+B04)", "NDVI") |>
  reduce_space("min(NDVI)", "max(NDVI)", "mean(NDVI)") |>
  plot(join.timeseries = TRUE)
```

The above examples can be applied  in a more flexible complex and and automatic way. Below you will find the growing season NDVI and the [kNDVI](https://advances.sciencemag.org/content/7/9/eabc7447) Median Difference calculated for 5 years.


```r
library(stars)
library(rstac)
library(gdalcubes)
library(tmaptools)
library(tmap)

gdalcubes_options(threads = 12)

# percentage
cloud_cover = 30

# spatial resolution
dx = 10
dy = 10

# ndvi operand
basic_ndvi_type = "median(NDVI)"
basic_kndvi_type = "median(kNDVI)"
# time slots as tibble
ts = tibble(t0 = c("2017-04-01","2018-04-01","2019-04-01","2020-04-01","2021-04-01"), 
            t1= c("2017-09-01","2018-09-01","2019-09-01","2020-09-01","2021-09-01"))
# names of the time slots
names_ndvi = paste(ts$t0,ts$t1,sep = " to ")

# sentinel channels
assets = c("B01","B02","B03","B04","B05","B06", "B07","B08","B8A","B09","B11","SCL")

# stac cloud
s = stac("https://earth-search.aws.element84.com/v0")

# mask derived from SCL layer
S2.mask = image_mask("SCL", values=c(3,8,9)) # clouds and cloud shadows

basic_ndvi <- function(col, v) {
  raster_cube(col, v, mask = S2.mask) %>%
    select_bands(c("B04", "B08")) %>%
    apply_pixel(c("(B08-B04)/(B08+B04)"), names="NDVI") %>%
    reduce_time(basic_ndvi_type)
}

basic_kndvi <- function(col, v) {
  raster_cube(col, v, mask = S2.mask) %>%
    select_bands(c("B04", "B08")) %>%
  apply_pixel("(1-exp(-((B08/10000)-(B04/10000))^2/(2))) / (1+exp(-((B08/10000)-(B04/10000))^2/(2)))", "kNDVI") |>
  reduce_time(basic_kndvi_type)
}

# (stac-search -> stac and cloud filter image collection -> create cube -> call user function)
kndvi = ndvi = v = item = col = list()
for (i in 1:nrow(ts)){
  # stac-search 
  item[[i]] <- s %>%
    stac_search(collections = "sentinel-s2-l2a-cogs",
                bbox = c(st_bbox(forest_4326)["xmin"],
                         st_bbox(forest_4326)["ymin"],
                         st_bbox(forest_4326)["xmax"],
                         st_bbox(forest_4326)["ymax"]), 
                datetime = paste(ts$t0[i],ts$t1[i],sep ="/"),
                limit = 500) %>% 
    post_request() 
  
  # stac and cloud filter image collection
  col[[i]] = stac_image_collection(item[[i]]$features, asset_names = assets, 
                                   property_filter = function(x) {x[["eo:cloud_cover"]] < cloud_cover})
  # create cube 
  v[[i]] = cube_view(srs = "EPSG:32632",  extent = list(t0 = ts$t0[[i]], t1 = ts$t1[[i]],
                                                        left = st_bbox(forest_32632)["xmin"], 
                                                        right = st_bbox(forest_32632)["xmax"],
                                                        bottom = st_bbox(forest_32632)["ymin"], 
                                                        top = st_bbox(forest_32632)["ymax"]),
                     dx = dx, dy = dy, dt = "P1D", aggregation = "median", resampling = "bilinear")
  # call user function
  basic_ndvi(col[[i]], v[[i]]) %>%
    st_as_stars() -> ndvi[[i]]
  
  basic_kndvi(col[[i]], v[[i]]) %>%
    st_as_stars() -> kndvi[[i]]
  
}

# now we may create a mask according to the NDVI extent and resolution
stars::write_stars(ndvi[[1]] * 0 ,paste0(tutorialDir,"forest/only_forestmask.tif"))
mask <- gdalUtils::gdal_rasterize(src_datasource=paste0(tutorialDir,"forest/only_forest.shp"),
                                  dst_filename=paste0(tutorialDir,"forest/only_forestmask.tif"),
                                  burn= 1,
                                  output_Raster=TRUE)
mask[mask == 0] = NA

# mapping the results
tmap_mode("plot")
tm_ndvi = lapply(seq(2:length(names_ndvi) -1),function(i){
  m = tm_shape(osm_forest) + tm_rgb() +
    tm_shape((ndvi[[i]] - ndvi[[i+1]]) * st_as_stars(mask )) +
    tm_raster(title = basic_ndvi_type) +
    tm_layout(panel.labels = paste(names_ndvi[[i]]," -  ",names_ndvi[[i+1]]),
              legend.show = TRUE,
              panel.label.height=0.6,
              panel.label.size=0.6,
              legend.text.size = 0.3,
              legend.outside = TRUE) +
    tm_grid()
})

tm_kndvi = lapply(seq(2:length(names_ndvi) -1),function(i){
  m = tm_shape(osm_forest) + tm_rgb() +
    tm_shape((kndvi[[i]] - kndvi[[i+1]]) * st_as_stars(mask )) +
    tm_raster(title = basic_ndvi_type) +
    tm_layout(panel.labels = paste(names_ndvi[[i]]," -  ",names_ndvi[[i+1]]),
              legend.show = TRUE,
              panel.label.height=0.6,
              panel.label.size=0.6,
              legend.text.size = 0.3,
              legend.outside = TRUE) +
    tm_grid()
})

tmap_arrange(tm_ndvi,ncol = 2,nrow=2)
tmap_arrange(tm_kndvi,ncol = 2,nrow=2)
```




## Applying bfastmonitor as a user-defined reducer function

To apply a more complex time series method such as `bfastmonitor()`, the data cube operations below allow to provide custom user-defined R functions instead of string expressions, which translate to built-in reducers. It is very important that these functions receive arrays as input and must return arrays as output, too. Depending on the operation, the dimensionality of the arrays is different:

+----------------+---------------------------------------------------------+------------------------------------+
| Operator       | Input                                                   | Output                             |
+================+=========================================================+====================================+
| `apply_pixel`  | Vector of band values for one pixel                     | Vector of band values of one pixel |
+----------------+---------------------------------------------------------+------------------------------------+
| `reduce_time`  | Multi-band time series as a matrix                      | Vector of band values              |
+----------------+---------------------------------------------------------+------------------------------------+
| `reduce_space` | Three-dimensional array with dimensions bands, x, and y | Vector of band values              |
+----------------+---------------------------------------------------------+------------------------------------+
| `apply_time`   | Multi-band time series as a matrix                      | Multi-band time series as a matrix |
+----------------+---------------------------------------------------------+------------------------------------+

There is no limit in what we can do in the provided R function, but we must take care of a few things:

1.  The reducer function is executed in a new R process without access to the current workspace. It is not possible to access variables defined outside of the function and packages must be loaded **within** the function.

2.  The reducer function **must** always return a vector with the same length (for all time series).

3.  It is a good idea to think about `NA` values, i.e. you should check whether the complete time series is `NA`, and that missing values do not produce errors.

Another possibility to apply R functions to data cubes is of course to convert data cubes to `stars` objects and use the `stars` package.

### Detecting magnitudes and time of kNDVI changes 
In our example, `bfastmonitor()` returns change date and change magnitude values per time series and we can use `reduce_time()`. The script below calculates the [kNDVI](https://advances.sciencemag.org/content/7/9/eabc7447), applies `bfastmonitor()`, and properly handles errors e.g. due to missing data with `tryCatch()`. Finally, resulting change dates and magnitudes for all pixel time series are written to disk as a netCDF file. The results shows the changes starting at 1/2019 until 12/2021 and Identify pretty well the impacts of drought an beetle in the MArburg University Forest (MOF).


```r
library(sf)
library(tmap)
library(tmaptools)
library(gdalcubes)
library(stars)
library(colorspace)
ndvi.col = function(n) {
  rev(sequential_hcl(n, "Green-Yellow"))
}
tutorialDir = path.expand("~/edu/agis/doc/data/tutorial/")

figtrim <- function(path) {
  img <- magick::image_trim(magick::image_read(path))
  magick::image_write(img, path)
  path
}
gdalcubes_options(threads = 12)
  system.time(
    ncdf_cube(file.path(tutorialDir,"lahntal.nc")) |>
      reduce_time(names = c("change_date", "change_magnitude","kndvi"), FUN = function(x) {
        knr <- exp(-((x["B08",]/10000)-(x["B04",]/10000))^2/(2))
        kndvi <- (1-knr) / (1+knr)   
        if (all(is.na(kndvi))) {
          return(c(NA,NA))
        }
        kndvi_ts = ts(kndvi, start = c(2017, 1), frequency = 12)
        library(bfast)
        tryCatch({
          result = bfastmonitor(kndvi_ts, start = c(2020,1), 
                                history = "all", level = 0.01)
          return(c(result$breakpoint, result$magnitude))
        }, error = function(x) {
          return(c(NA,NA))
        })
      }) |>
      write_ncdf(paste0(tutorialDir,"bf_results.nc"),overwrite = TRUE))
```


```r
# plotting it from the local ncdf  
tmap_mode("plot")
ncdf_cube(paste0(tutorialDir,"bf_results.nc")) |>
  st_as_stars() -> x
m1 = tm_shape(osm_forest) + tm_rgb() +
  tm_shape(x[1]) + 
  tm_raster(n = 6)  +
  tm_layout(
    legend.show = TRUE,
    panel.label.height=0.6,
    panel.label.size=0.6,
    legend.text.size = 0.4,
    legend.outside = TRUE) +
  tm_grid() 

m2 =  tm_shape(osm_forest) + tm_rgb() +
  tm_shape(x[2])  + tm_raster() +
  tm_layout(legend.title.size = 1,
    panel.label.height=0.6,
    panel.label.size=0.6,
    legend.text.size = 0.4,
    legend.outside = TRUE) +
  tm_grid() 
tmap_arrange(m1,m2)
```

Running `bfastmonitor()` is computationally expensive. However, since the data is located in the cloud anyway, it would be obvious to launch one of the more powerful machine instance types with many processors. Parallelization within one instance can be controlled entirely by `gdalcubes` using `gdalcubes_options()`.

To visualize the change detection results, we load the resulting netCDF file, convert it to a `stars` object, and finally use the `tmap` package to create an interactive map to visualize the change date.     

The result certainly needs some postprocessing to understand types of changes and to identify false positives.

# Summary

This example has shown, how more complex time series methods as from external R packages can be applied on data cubes. For computationally intensive methods, it is in many cases useful to store intermediate results by combining `write_ncdf()` and `ncdf_cube()`. 


# References
