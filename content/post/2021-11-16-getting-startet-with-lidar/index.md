---
title: "Getting startet with LiDAR"
author: Chris Reudenbach
date: '2021-11-16'
slug: []
categories: ["aGIS"]
tags: ["forest", "lidar","ecology","forestry"]
description: 'Light detection and ranging (LiDAR) observations are point clouds representing the returns of laser pulses reflected from objects, e.g. a tree canopy. Processing LiDAR (or optical point cloud) data generally  requires more computational resources than 2D optical observations.'
image: '/img/bayern-religion-sp.jpg'
toc: true
output:
  blogdown::html_page:
    keep_md: yes
weight: 100
---



## LiDAR data and LAS data format
Technically spoken the LiDAR data comes in the LAS file format (for a format definition i.e. have a look at the [American Society for Photogrammetry & Remote Sensing LAS documentation file](https://www.asprs.org/a/society/committees/standards/LAS_1_4_r13.pdf)). One LAS data set typically but not necessarily covers an area of 1 km by 1 km. Since the point clouds in the LAS data sets are large, a spatial index file (LAX) considerably reduces search and select operations in the data.



## Brief Overview of LiDAR Software Tools
The development of the software is rapid. A few years ago, it was only possible to manipulate, manage and analyze LiDAR data with complex special tools.  Especially the (partly (commercial) [LAStools](https://rapidlasso.com/lastools/) software was unrivaled for many years. Many remote sensing and remote sensing software tools have acquired licenses on this basis or developed components independently. Examples are [GRASS GIS](http://grasswiki.osgeo.org/wiki/LIDAR) and [ArcGIS](https://desktop.arcgis.com/en/arcmap/10.3/manage-data/las-dataset/a-quick-tour-of-lidar-in-arcgis.htm).
Beside the GIS packages there are a number of powerful specialists.  Two important and typical representatives are [3D forest](https://www.3dforest.eu/#about) and [FUSION](http://forsys.cfr.washington.edu/FUSION/fusion_overview.html).


However all solution can be linked to R (we did it over the years) the `lidr` package has revolutionized the processing of LiDAR data in the R ecotop and is definitely by far the best choice (and even faster an more reliable than commercial tools). Extensive documentation and workflow examples can be found in the Wiki of the respective [GitHub repository](https://github.com/Jean-Romain/lidR). A very recent publication is avaiblable at Remote Sensing of Environment [idR: An R package for analysis of Airborne Laser Scanning (ALS) data](https://www.sciencedirect.com/science/article/pii/S0034425720304314#f0015).




## Start up test 

For the following, make sure these libraries are part of your setup (should be the case if you follow [project oriented workflow post]( {{< ref "2021-11-13-project-oriented-workflow" >}})).

We make a short general check that we can start over with the real processing, i.e. we check if everything is ready to use. first set up your project environment:





```r
# 0 - specific setup
#-----------------------------

require(envimaR)

# MANDANTORY: defining the root folder DO NOT change this line
rootDIR = "~/edu/agis"
# define  additional packages comment if not needed
appendpackagesToLoad = c("lidR","future")
# define additional subfolders comment if not needed
appendProjectDirList =  c("data/lidar/","data/lidar/l_raster","data/lidar/l_raw","data/lidar/l_norm")

## define current projection (It is not magic you need to check the meta data or ask your instructor) 
## ETRS89 / UTM zone 32N
proj4 = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
epsg_number = 25832

# MANDANTORY: calling the setup script also DO NOT change this line
source(file.path(envimaR::alternativeEnvi(root_folder = rootDIR),"src/agis_setup.R"), echo = FALSE,verbose = FALSE)
```



```r
# NOTE file size is about 12MB
utils::download.file(url="https://github.com/gisma/gismaData/raw/master/uavRst/data/lidR_data.zip",
                     destfile=paste0(envrmt$path_tmp,"/chm.zip"))
unzip(paste0(envrmt$path_tmp,"/chm.zip"),
      exdir = envrmt$path_tmp,  
      overwrite = TRUE)

las_files = list.files(envrmt$path_tmp,
                       pattern = glob2rx("*.las"),
                       full.names = TRUE)
```

If you want to read a single (not to big) LAS file, you can use the `readLAS` function. Plotting the data set results in a 3D interactive screen which opens from within R.


```r
library(rgl)
knitr::knit_hooks$set(webgl = hook_webgl)
lidar_file = readLAS(las_files[1])
```

```
Warning: Invalid data: ScanAngleRank greater than 90 degrees
```

```r
plot(lidar_file, bg = "green", color = "Z",colorPalette = mvTop(256))
```

![](/gi-modules/assets/videos/las_mof_plot.gif)
<figure>
  <figcaption> 
  Example forest LiDAR data set.
  </figcaption>
</figure>


If this works, you're [good to go]( {{< ref "2021-11-20-forest-information-from-lidar-data" >}}) for LiDAR data analysis.


## Comments & Suggestions  

