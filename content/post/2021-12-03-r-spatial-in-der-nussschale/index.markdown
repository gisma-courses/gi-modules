---
title: R-Spatial in der Nussschale
author: Chris Reudenbach
date: '2021-12-03'
slug: []
categories:
  - aGIS
tags:
  - basics
subtitle: ''
description: ''
image: ''
toc: yes
output:
  blogdown::html_page:
    keep_md: yes
weight: 100
---



## Vektordaten

Natürlich können in `R` auch Vektordaten verarbeitet werden. Das Paket, `sf` ist da Arbeitspferd um Vektordaten vieler Typen zu lesen, schreiben und analysieren. FürÜbungszwecke werden wir einige Daten aus der [Openstreetmap](https://www.openstreetmap.de/) (OSM) Datenbank herunterladen. Einen Überblick über die verfügbaren [Features](https://wiki.openstreetmap.org/wiki/Map_features) finden sie unter dem Link.
Mit dem folgenden R-Quellcode laden und visualisieren wir die Gebäude im Verwaltungsbereich Marburg:

```r
# Example Polygons
# OSM public data buildings marburg
# do not forget to add the osmdata package to your header section of the script

library(osmdata)
# loading OSM data for the Marburg region 
buildings = opq(bbox = "marburg de") %>% 
  add_osm_feature(key = "building") %>% 
  osmdata_sf()

buildings = buildings$osm_polygons

mapview::mapview(buildings)
```
## Sentinel-Satellitendaten

Satellitendaten hingegen sind mittlerweile prinzipiell leicht zugänglich. Ein Beispiel für solche Satellitendaten, die häufig in der Umwelt-Fernerkundung verwendet werden, ist die [Sentinel-2-Mission] (https://sentinel.esa.int/web/sentinel/missions/sentinel-2) der Europäischen Weltraumorganisation.

### Das Paket `sen2r` 

Mit dem Paket `sen2r` können Sie Sentinel-2-Bilder direkt in `R` herunterladen und vorverarbeiten.

Um `sen2r` zu installieren, müssen Sie `Rtools` installiert haben.

1. Gehe zu [http://cran.r-project.org/bin/windows/Rtools/](http://cran.r-project.org/bin/windows/Rtools/) 
1. Wählen Sie den Download-Link, der Ihrer Version von `R` entspricht
1. Öffnen Sie die .exe-Datei und verwenden Sie die Standardeinstellungen
1. **Vergewissern Sie sich, dass Sie das Kästchen ankreuzen, damit das Installationsprogramm Ihren PATH bearbeiten kann**
1. Führen Sie `library(devtools)` in `R` aus
1. Führen Sie `find_rtools()` aus -- wenn `TRUE`, hat die Installation richtig funktioniert

Dann muss das Paket nur noch wie jedes andere Paket installiert werden.

```r
install.packages("sen2r")
library(sen2r)
```

### Die `sen2r`-GUI
Der einfachste Weg, `sen2r` zu benutzen, ist, die grafische Benutzeroberfläche (GUI) zu öffnen und sie im interaktiven Modus zu benutzen. Allerdings muss man hier in den Einstellungen aus einer Vielzahl von Optionen wählen. Die dafür erforderlichen Kenntnisse sind auch für die unten vorgestellte Kommandozeilenversion notwendig. Beide Schnittstellen können automatisiert werden. Wir empfehlen die API, aber letztlich bleibt es Ihnen überlassen. Verwenden Sie dazu die gleichnamige Funktion.

```r
sen2r::sen2r()
```

### Die `sen2r` API

Damit Sie Sentinel Daten benutzen können müssen Sie bei SciHub ein [Konto anlegen](https://scihub.copernicus.eu/dhus/#/self-registration)!

Im folgenden Skript werden die Sentinel-2-Daten zur Berechnung der Oberflächenalbedo verwendet. Dazu sind die folgenden Schritte notwendig:
1. Festlegen einger Parameter wie z.B. Datum Bildausschnitt usw.
2. Herunterladen der Daten durch Konfigurieren und Ausführen von `sen2r` über die API
3. Berechnen Sie die Oberflächenalbedo (beispielhaft) 

<script src="https://gist.github.com/gisma/5a11edd28cf81cee523e273b0064bcea.js"></script>

Die [sen2r vignette](https://sen2r.ranghetti.info/) bietet viele hilfreiche Informationen über die Benutzung der GUI und den Zugriff auf die Funktionen von `sen2r` aus `R` heraus.



#### Raster Daten


Konkret verwenden wir die Funktion `stack` aus dem Paket `raster`, um eine sog. Geo-TIF-Datei zu importieren. Also ein *Rasterbild* mit räumlichen Eigenschaften wie einer Georeferenzierung. Durch die Verwendung der `::`-Syntax, d.h. `Paket::Funktion`, garantieren wir, dass wir eine bestimmte Funktion aus einem bestimmten Paket verwenden. Dieses Konzept ist wichtig, um sicherzustellen, dass wir die richtige Funktion verwenden (da einige Pakete die gleichen Funktionsnamen verwenden, was als Maskierung bezeichnet wird).
