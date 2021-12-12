---
title: Forest Information from LiDAR data
author: Chris Reudenbach
date: '2021-11-20'
slug: []
categories: ["aGIS"]
tags: ["forest", "lidar","ecology","forestry"]
description: ''
image: '/assets/images/forest-sp.jpg'
toc: true
output:
  blogdown::html_page:
    keep_md: true
weight: 101

---
## How to get started?

For this first example we take a typical situation:
- we have no idea about the software and possible solutions
- we have no idea about LiDAR data processing and analysis
- we just google something like *lidR package tutorial*

Among the top ten is [The lidR package book](https://jean-romain.github.io/lidRbook/) . So let's follow the white rabbit...

## Creating a Canopy Height Model (CHM) reloaded

After successful application of the tutorial we will transfer it into a suitable script for our workflow. Please check the comments for better understanding and do it **step by step!** again. Please note that the following script is meant to be an basic example how: 
- to organize scripts in common 
- with a hands on example for creating a canopy height model.


After revisiting the tutorial is seems to be a good choice to follow the tutorial of the `lidR` developer that is  [Digital Surface Model and Canopy Height model](https://jean-romain.github.io/lidRbook/chm.html)  in the above tutorial. Why? because for the first Jean-Romain Roussel explains 6 ways how to create in a very simple approach a CHM, second to show up that it makes sense to read and third to loop back because it does not work with bigger files. Let us start with the new script structure.


## Start Script

<script src="https://gist.github.com/gisma/89881e23f5c2da91d161a9668386b715.js"></script>

      

`{{% hp5 "/gi-modules/assets/misc/chm_one_tile.html" "700" "680" "center" "Canopy Height Model map" %}}`{=html}

### lidR catalog - coping with computer memory resources

The above example is based on a las-tile of 250 by 250 meter. That means a fairly **small** tile size. If you did not run in memory or CPU problems you can deal with these tiles by simple looping.  

**But** you have to keep in mind that even if a tile based processing can easily be handled with loops but has some pitfalls. E.g. if you compute some focal operations, you have to make sure that if the filter is close to the boundary of the tile that data from the neighboring tile is loaded in addition. Also the tile size may be a problem for your memory availability. 

The `lidR` package comes with a feature called catalog and a set of catalog functions which make tile-based life easier. A catalog meta object also holds information on e.g. the cartographic reference system of the data or the cores used for parallel processing. So we start over again - this time with a **real** data set.

If not already done download the course related [LiDAR data set of the MOF area](http://gofile.me/3Z8AJ/c6m5CfvWZ) . Store the the data to the **`envrmt$path_l_raw`** folder. 



Please note that dealing with `lidR` catalogs is pretty stressful for the memory administration of your `rsession`. So best practices is to **Restart your Rsesseion and clean up your environment**. This will help you to avoid frustrating situation like restarting your PC after hours of waiting...


Take the setup section of the above script and exchange the code part as found under *start script* with the following code chunk. This will setup a lidR catalog and a more sophisticated approach to calculate the DEM, DSM and CHM. 



<script src="https://gist.github.com/gisma/4172ef049b116abb1454233c8950d587.js"></script>


### The visualization of an operating lidR catalog action.

The `mof_ctg` catalog is shows the extent of the original las file as provided by the the data server. The vector that is visualized is the resulting `lidR` catalog containing all extracted parameters. Same with the `mof100_ctg` here you see the extracted maximum Altitude of each tile used for visualization. Feel free to investigate the catalog parameters by clicking on the tiles.  


```r
require(envimaR)
```

```
## Loading required package: envimaR
```

```r
# MANDANTORY: defining the root folder DO NOT change this line
rootDIR = "~/edu/agis"

#-- Further customization of the setup by the user this section 
#-- can be freely customized only the definition of additional packages 
#-- and directory paths MUST be done using the two variables 
#-- appendpackagesToLoad and appendProjectDirList
#-- feel free to remove this lines if you do not need them
# define  additional packages comment if not needed
appendpackagesToLoad = c("lidR","future")
# define additional subfolders comment if not needed
appendProjectDirList =  c("data/lidar/","data/lidar/l_raster","data/lidar/l_raw","data/lidar/l_norm")

## define current projection (It is not magic you need to check the meta data or ask your instructor) 
## ETRS89 / UTM zone 32N
proj4 = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
epsg_number = 25832

# MANDANTORY: calling the setup script also DO NOT change this line
source(file.path(envimaR::alternativeEnvi(root_folder = rootDIR),"src/agis_setup.R"),echo = TRUE)
```

```
## 
## > require(envimaR)
## 
## > packagesToLoad = c("mapview", "mapedit", "tmap", "raster", 
## +     "sf", "dplyr", "tidyverse", "RStoolbox", "randomForest", 
## +     "e1071", "caret")
## 
## > if (exists("appendpackagesToLoad") && appendpackagesToLoad[[1]] != 
## +     "") {
## +     packagesToLoad = append(packagesToLoad, appendpackagesToLoad)
##  .... [TRUNCATED] 
## 
## > if (!exists("rootDIR")) {
## +     cat("variable rootDIR is NOT defined\n '~/edu/agis' is set by default")
## +     rootDIR = "~/edu/agis"
## + }
## 
## > if (!exists("alt_env_id")) {
## +     cat("variable alt_env_id is NOT defined\n 'COMPUTERNAME' is set by default")
## +     alt_env_id = "COMPUTERNAME"
## +  .... [TRUNCATED] 
## variable alt_env_id is NOT defined
##  'COMPUTERNAME' is set by default
## > if (!exists("alt_env_value")) {
## +     cat("variable alt_env_value is NOT defined\n 'PCRZP' is set by default")
## +     alt_env_value = "PCRZP"
## + }
## variable alt_env_value is NOT defined
##  'PCRZP' is set by default
## > if (!exists("alt_env_root_folder")) {
## +     cat("variable alt_env_root_folder is NOT defined\n 'F:/BEN/edu' is set by default")
## +     alt_env_root_f .... [TRUNCATED] 
## variable alt_env_root_folder is NOT defined
##  'F:/BEN/edu' is set by default
## > rootDir = envimaR::alternativeEnvi(root_folder = rootDIR, 
## +     alt_env_id = alt_env_id, alt_env_value = alt_env_value, alt_env_root_folder = alt_e .... [TRUNCATED] 
## 
## > projectDirList = c("data/", "run/", "src/", "tmp", 
## +     "doc/")
## 
## > if (exists("appendProjectDirList") && appendProjectDirList[[1]] != 
## +     "") {
## +     projectDirList = append(projectDirList, appendProjectDirList)
##  .... [TRUNCATED] 
## 
## > envrmt = envimaR::createEnvi(root_folder = rootDir, 
## +     folders = projectDirList, fcts_folder = "src/functions/", 
## +     path_prefix = "path_", l .... [TRUNCATED]
```

```
## Loading required package: mapview
```

```
## Loading required package: mapedit
```

```
## Loading required package: tmap
```

```
## Loading required package: raster
```

```
## Loading required package: sp
```

```
## Loading required package: sf
```

```
## Linking to GEOS 3.9.1, GDAL 3.3.2, PROJ 7.2.1
```

```
## Loading required package: dplyr
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:raster':
## 
##     intersect, select, union
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```
## Loading required package: tidyverse
```

```
## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
```

```
## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
## ✓ tibble  3.1.6     ✓ stringr 1.4.0
## ✓ tidyr   1.1.4     ✓ forcats 0.5.1
## ✓ readr   2.1.1
```

```
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## x tidyr::extract() masks raster::extract()
## x dplyr::filter()  masks stats::filter()
## x dplyr::lag()     masks stats::lag()
## x dplyr::select()  masks raster::select()
```

```
## Loading required package: RStoolbox
```

```
## Loading required package: randomForest
```

```
## randomForest 4.6-14
```

```
## Type rfNews() to see new features/changes/bug fixes.
```

```
## 
## Attaching package: 'randomForest'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     margin
```

```
## The following object is masked from 'package:dplyr':
## 
##     combine
```

```
## Loading required package: e1071
```

```
## 
## Attaching package: 'e1071'
```

```
## The following object is masked from 'package:raster':
## 
##     interpolate
```

```
## Loading required package: caret
```

```
## Loading required package: lattice
```

```
## 
## Attaching package: 'caret'
```

```
## The following object is masked from 'package:purrr':
## 
##     lift
```

```
## Loading required package: lidR
```

```
## Loading required package: future
```

```
## 
## Attaching package: 'future'
```

```
## The following object is masked from 'package:caret':
## 
##     cluster
```

```
## The following object is masked from 'package:raster':
## 
##     values
```

```
## 
## > raster::rasterOptions(tmpdir = envrmt$path_tmp)
## 
## > rgdal::set_thin_PROJ6_warnings(TRUE)
## 
## > mvTop = mapview::mapviewPalette("mapviewTopoColors")
## 
## > mvSpec = mapview::mapviewPalette("mapviewSpectralColors")
## 
## > mvVec = mapview::mapviewPalette("mapviewVectorColors")
## 
## > mvRas = mapview::mapviewPalette("mapviewRasterColors")
```

```r
# 1 - start script
#-----------------------------

utils::download.file(url="https://github.com/gisma/gismaData/raw/master/uavRst/data/lidR_data.zip",
                     destfile=paste0(envrmt$path_tmp,"/chm.zip"))
unzip(paste0(envrmt$path_tmp,"/chm.zip"),
      exdir = envrmt$path_tmp,  
      overwrite = TRUE)

#---- Get all *.las files of a folder into a list
las_files = list.files(envrmt$path_tmp,
                       pattern = glob2rx("*.las"),
                       full.names = TRUE)

#---- create CHM as provided by
# source: https://github.com/Jean-Romain/lidR/wiki/Rasterizing-perfect-canopy-height-models
las = readLAS(las_files[1])
```

```
## Warning: Invalid data: ScanAngleRank greater than 90 degrees
```

```r
las = lidR::lasnormalize(las, knnidw())
```

```
## Warning: lidR::lasnormalize is deprecated. Use normalize_height instead.
```

```
## Warning: There were 14 degenerated ground points. Some X Y Z coordinates were
## repeated. They were removed.
```

```
## Warning: There were 180 degenerated ground points. Some X Y coordinates were
## repeated but with different Z coordinates. min Z were retained.
```

```
## Inverse distance weighting: [=============================================-----] 91% (16 threads)
Inverse distance weighting: [==============================================----] 92% (16 threads)
Inverse distance weighting: [==============================================----] 93% (16 threads)
Inverse distance weighting: [===============================================---] 94% (16 threads)
Inverse distance weighting: [===============================================---] 95% (16 threads)
Inverse distance weighting: [================================================--] 96% (16 threads)
Inverse distance weighting: [================================================--] 97% (16 threads)
Inverse distance weighting: [=================================================-] 98% (16 threads)
Inverse distance weighting: [=================================================-] 99% (16 threads)
Inverse distance weighting: [==================================================] 100% (16 threads)
```

```r
# reassign the projection
sp::proj4string(las) <- sp::CRS(proj4)

# calculate the chm with the pitfree algorithm
chm = lidR::grid_canopy(las, 0.25, pitfree(c(0,2,5,10,15), c(0,1), subcircle = 0.2))
```

```
## Delaunay rasterization[======================================------------] 77% (16 threads)
Delaunay rasterization[=======================================-----------] 78% (16 threads)
Delaunay rasterization[=======================================-----------] 79% (16 threads)
Delaunay rasterization[========================================----------] 80% (16 threads)
Delaunay rasterization[========================================----------] 81% (16 threads)
Delaunay rasterization[=========================================---------] 82% (16 threads)
Delaunay rasterization[=========================================---------] 83% (16 threads)
Delaunay rasterization[==========================================--------] 84% (16 threads)
Delaunay rasterization[==========================================--------] 85% (16 threads)
Delaunay rasterization[===========================================-------] 86% (16 threads)
Delaunay rasterization[===========================================-------] 87% (16 threads)
Delaunay rasterization[============================================------] 88% (16 threads)
Delaunay rasterization[============================================------] 89% (16 threads)
Delaunay rasterization[=============================================-----] 90% (16 threads)
Delaunay rasterization[=============================================-----] 91% (16 threads)
Delaunay rasterization[==============================================----] 92% (16 threads)
Delaunay rasterization[==============================================----] 93% (16 threads)
Delaunay rasterization[===============================================---] 94% (16 threads)
Delaunay rasterization[===============================================---] 95% (16 threads)
Delaunay rasterization[================================================--] 96% (16 threads)
Delaunay rasterization[================================================--] 97% (16 threads)
Delaunay rasterization[=================================================-] 98% (16 threads)
Delaunay rasterization[=================================================-] 99% (16 threads)
Delaunay rasterization[==================================================] 100% (16 threads)
Delaunay rasterization[================================------------------] 64% (16 threads)
Delaunay rasterization[================================------------------] 65% (16 threads)
Delaunay rasterization[=================================-----------------] 66% (16 threads)
Delaunay rasterization[=================================-----------------] 67% (16 threads)
Delaunay rasterization[==================================----------------] 68% (16 threads)
Delaunay rasterization[==================================----------------] 69% (16 threads)
Delaunay rasterization[===================================---------------] 70% (16 threads)
Delaunay rasterization[===================================---------------] 71% (16 threads)
Delaunay rasterization[====================================--------------] 72% (16 threads)
Delaunay rasterization[====================================--------------] 73% (16 threads)
Delaunay rasterization[=====================================-------------] 74% (16 threads)
Delaunay rasterization[=====================================-------------] 75% (16 threads)
Delaunay rasterization[======================================------------] 76% (16 threads)
Delaunay rasterization[======================================------------] 77% (16 threads)
Delaunay rasterization[=======================================-----------] 78% (16 threads)
Delaunay rasterization[=======================================-----------] 79% (16 threads)
Delaunay rasterization[========================================----------] 80% (16 threads)
Delaunay rasterization[========================================----------] 81% (16 threads)
Delaunay rasterization[=========================================---------] 82% (16 threads)
Delaunay rasterization[=========================================---------] 83% (16 threads)
Delaunay rasterization[==========================================--------] 84% (16 threads)
Delaunay rasterization[==========================================--------] 85% (16 threads)
Delaunay rasterization[===========================================-------] 86% (16 threads)
Delaunay rasterization[===========================================-------] 87% (16 threads)
Delaunay rasterization[============================================------] 88% (16 threads)
Delaunay rasterization[============================================------] 89% (16 threads)
Delaunay rasterization[=============================================-----] 90% (16 threads)
Delaunay rasterization[=============================================-----] 91% (16 threads)
Delaunay rasterization[==============================================----] 92% (16 threads)
Delaunay rasterization[==============================================----] 93% (16 threads)
Delaunay rasterization[===============================================---] 94% (16 threads)
Delaunay rasterization[===============================================---] 95% (16 threads)
Delaunay rasterization[================================================--] 96% (16 threads)
Delaunay rasterization[================================================--] 97% (16 threads)
Delaunay rasterization[=================================================-] 98% (16 threads)
Delaunay rasterization[=================================================-] 99% (16 threads)
Delaunay rasterization[==================================================] 100% (16 threads)
Delaunay rasterization[=============================================-----] 90% (16 threads)
Delaunay rasterization[=============================================-----] 91% (16 threads)
Delaunay rasterization[==============================================----] 92% (16 threads)
Delaunay rasterization[==============================================----] 93% (16 threads)
Delaunay rasterization[===============================================---] 94% (16 threads)
Delaunay rasterization[===============================================---] 95% (16 threads)
Delaunay rasterization[================================================--] 96% (16 threads)
Delaunay rasterization[================================================--] 97% (16 threads)
Delaunay rasterization[=================================================-] 98% (16 threads)
Delaunay rasterization[=================================================-] 99% (16 threads)
Delaunay rasterization[==================================================] 100% (16 threads)
Delaunay rasterization[=================================-----------------] 67% (16 threads)
Delaunay rasterization[==================================----------------] 68% (16 threads)
Delaunay rasterization[==================================----------------] 69% (16 threads)
Delaunay rasterization[===================================---------------] 70% (16 threads)
Delaunay rasterization[===================================---------------] 71% (16 threads)
Delaunay rasterization[====================================--------------] 72% (16 threads)
Delaunay rasterization[====================================--------------] 73% (16 threads)
Delaunay rasterization[=====================================-------------] 74% (16 threads)
Delaunay rasterization[=====================================-------------] 75% (16 threads)
Delaunay rasterization[======================================------------] 76% (16 threads)
Delaunay rasterization[======================================------------] 77% (16 threads)
Delaunay rasterization[=======================================-----------] 78% (16 threads)
Delaunay rasterization[=======================================-----------] 79% (16 threads)
Delaunay rasterization[========================================----------] 80% (16 threads)
Delaunay rasterization[========================================----------] 81% (16 threads)
Delaunay rasterization[=========================================---------] 82% (16 threads)
Delaunay rasterization[=========================================---------] 83% (16 threads)
Delaunay rasterization[==========================================--------] 84% (16 threads)
Delaunay rasterization[==========================================--------] 85% (16 threads)
Delaunay rasterization[===========================================-------] 86% (16 threads)
Delaunay rasterization[===========================================-------] 87% (16 threads)
Delaunay rasterization[============================================------] 88% (16 threads)
Delaunay rasterization[============================================------] 89% (16 threads)
Delaunay rasterization[=============================================-----] 90% (16 threads)
Delaunay rasterization[=============================================-----] 91% (16 threads)
Delaunay rasterization[==============================================----] 92% (16 threads)
Delaunay rasterization[==============================================----] 93% (16 threads)
Delaunay rasterization[===============================================---] 94% (16 threads)
Delaunay rasterization[===============================================---] 95% (16 threads)
Delaunay rasterization[================================================--] 96% (16 threads)
Delaunay rasterization[================================================--] 97% (16 threads)
Delaunay rasterization[=================================================-] 98% (16 threads)
Delaunay rasterization[=================================================-] 99% (16 threads)
Delaunay rasterization[==================================================] 100% (16 threads)
```

```r
# # write it to tif
 raster::writeRaster(chm,file.path(envrmt$path_l_raster,"/mof_chm_one_tile.tif"),overwrite=TRUE) 
```


```r
# - visualize 
# -------------------
  
library(tmap)
library(leaflet)

# set tmap options
tmap::tmap_mode("view")
```

```
## tmap mode set to interactive viewing
```

```r
 tmap::tmap_leaflet(tmap::tm_shape(chm) %>%  tmap::tm_raster(palette = mvTop(256),legend.hist.title = "height/m",alpha = 0.7) %>% tmap::tm_basemap(server = c('OpenStreetMap','Esri.WorldImagery')))
```

```
## Warning in if (!(g %in% bases)) {: the condition has length > 1 and only the
## first element will be used
```




## old

`{{% hp5 "/gi-modules/assets/misc/mof_sapflow_chm.html" "700" "680" "center" "Canopy Height Model map" %}}`{=html}


### The whole clipped MOF area rendered to a canopy height model. 


`{{% hp5 "/gi-modules/assets/misc/chm_one_tile.html" "700" "680" "center" "Canopy Height Model map" %}}`{=html}


Assuming the above script (or the script you have adapted) runs without any technical errors, the exciting part of the data preprocessing comes now. In addition we ave to cross check and answer a lot of questions:

- Which algorithms did I use and why? 
- 45m high trees - does that make sense? 
- If not why not? 
- What correction options do I have and why? 
- Is the error due to the data, the algorithms, the script or all together?
- ...

## Where to go?

To answer this questions we need a two folded approach. 
- First we need technically to strip down the script to a *real* control script, all functionality that is used more than once will be moved into *functions* or other static scripts. 
- Second from a scientific point of view we need to find out what algorithm is most suitable and reliable to answer the question of calculating a set of paramters for deriving structural forest index classes. This also includes that we have to decide which classes and why... .



## Ressources

- You find all related materials at the [aGIS Ressource](https://gisma-courses.github.io/gi-modules/post/2021-11-16-agis-ressourcen/) post.


## Comments & Suggestions  

