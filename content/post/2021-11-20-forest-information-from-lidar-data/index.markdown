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
    keep_md: yes
weight: 101

---

## How to get started?

For this first example we take a typical situation:
- we have no idea about the software and possible solutions
- we have no idea about LiDAR data processing and analysis
- we just google something like *lidR package tutorial*

Among the top ten is [The lidR package book](https://jean-romain.github.io/lidRbook/) . So let’s follow the white rabbit…

## Creating a Canopy Height Model (CHM) reloaded

After successful application of the tutorial we will transfer it into a suitable script for our workflow. Please check the comments for better understanding and do it **step by step!** again. Please note that the following script is meant to be an basic example how:
- to organize scripts in common
- with a hands on example for creating a canopy height model.

After revisiting the tutorial is seems to be a good choice to follow the tutorial of the `lidR` developer that is [Digital Surface Model and Canopy Height model](https://jean-romain.github.io/lidRbook/chm.html) in the above tutorial. Why? because for the first Jean-Romain Roussel explains 6 ways how to create in a very simple approach a CHM, second to show up that it makes sense to read and third to loop back because it does not work with bigger files. Let us start with the new script structure.

<script src="https://gist.github.com/gisma/89881e23f5c2da91d161a9668386b715.js"></script>

{{% hp5 "/gi-modules/assets/misc/chm_one_tile.html" "700" "680" "center" "Canopy Height Model map" %}}

### lidR catalog - coping with computer memory resources

The above example is based on a las-tile of 250 by 250 meter. That means a fairly **small** tile size. If you did not run in memory or CPU problems you can deal with these tiles by simple looping.

**But** you have to keep in mind that even if a tile based processing can easily be handled with loops but has some pitfalls. E.g. if you compute some focal operations, you have to make sure that if the filter is close to the boundary of the tile that data from the neighboring tile is loaded in addition. Also the tile size may be a problem for your memory availability.

The `lidR` package comes with a feature called catalog and a set of catalog functions which make tile-based life easier. A catalog meta object also holds information on e.g. the cartographic reference system of the data or the cores used for parallel processing. So we start over again - this time with a **real** data set.

If not already done download the course related [LiDAR data set of the MOF area](http://gofile.me/3Z8AJ/c6m5CfvWZ) . Store the the data to the **`envrmt$path_l_raw`** folder.

Please note that dealing with `lidR` catalogs is pretty stressful for the memory administration of your `rsession`. So best practices is to **Restart your Rsesseion and clean up your environment**. This will help you to avoid frustrating situation like restarting your PC after hours of waiting…

Take the setup section of the above script and exchange the code part as found under *#— start script* with the following code chunk. This will setup a lidR catalog and a more sophisticated approach to calculate the DEM, DSM and CHM.

<script src="https://gist.github.com/gisma/4172ef049b116abb1454233c8950d587.js"></script>

### The visualization of an operating lidR catalog action.

The `mof_ctg` catalog is shows the extent of the original las file as provided by the the data server. The vector that is visualized is the resulting `lidR` catalog containing all extracted parameters. Same with the `mof100_ctg` here you see the extracted maximum Altitude of each tile used for visualization. Feel free to investigate the catalog parameters by clicking on the tiles.

{{% hp5 "/gi-modules/assets/misc/mof_sapflow_chm.html" "700" "680" "center" "Canopy Height Model map" %}}

### The whole clipped MOF area rendered to a canopy height model.

{{% hp5 "/gi-modules/assets/misc/chm_one_tile.html" "700" "680" "center" "Canopy Height Model map" %}}

Assuming the above script (or the script you have adapted) runs without any technical errors, the exciting part of the data preprocessing comes now. In addition we ave to cross check and answer a lot of questions:

-   Which algorithms did I use and why?
-   45m high trees - does that make sense?
-   If not why not?
-   What correction options do I have and why?
-   Is the error due to the data, the algorithms, the script or all together?
-   …

## Where to go?

To answer this questions we need a two folded approach.
- First we need technically to strip down the script to a *real* control script, all functionality that is used more than once will be moved into *functions* or other static scripts.
- Second from a scientific point of view we need to find out what algorithm is most suitable and reliable to answer the question of calculating a set of paramters for deriving structural forest index classes. This also includes that we have to decide which classes and why… .

## Ressources

-   You find all related materials at the [aGIS Ressource](https://gisma-courses.github.io/gi-modules/post/2021-11-16-agis-ressourcen/) post.

## Comments & Suggestions
