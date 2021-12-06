---
title: R-Spatial in der Nussschale
author: Chris Reudenbach
date: '2021-12-03'
slug: []
categories:
  - bGIS
tags:
  - basics
subtitle: ''
description: ''
image: ''
toc: yes
output:
  blogdown::html_page:
    keep_md: yes
weight: 500
---

## Change Detection Trockenstress Fichten im Harz 

Am Beispiel eines typischen Arbeitsablaufs könne sowohl die frisch erworbenen R-Fertigkeiten gefestigt  als auch eine gute Arbeitspraxis eingeübt werden. Die Fragestellung mit der wir uns beschäftigen wollen ist die Erfassung der flächenhaften Verluste von Fichtenwald am Beispiel des Westharzes. 

Grundsätzlich können Sie dies bereits mit ihren Basis-Fähigkeiten erfolgreich bearbeiten. Damit Sie sofort mit einer guten Struktur starten treffen wir noch ein paar Vorbereitungen. Zunächst installieren sie bitte das Paket `envimaR`. Da das Paket auf `Github` zur Verfügung gestellt wird müssen wir es wie folgt installieren:

```r

# first install the utility package devtools
install.packages("devtools)

# Install envimaR
devtools::install_github("envima/envimaR")
```

Wir benötigen dieses Paket um bequem eine definierte Areitsumgebung zu erzeugen.

Nach der Installation navigieren Sie zu `File->New Project->New Directory`. Dann scrollen Sie nach unten bis zur Auswahl `Project structure with envimaR`. Diese wählen Sie aus. Navigieren sie zu einem Verzeichnis ihrer Wahl. Geben sie einen Projektnamen ein z.B. `geoinfo`. Sie werden in einem neuen Projekt "abgesetzt" das wie folgt aussieht:

![](images/folder.png)

Doppelklicken sie auf das Verzeichnis `src` Sie sehen eine Datei namens `main.R` oöffen Sie diese durch Doppelklick.. Dann öffnen Sie in den Ordner `function`. Hier öffnen Sie die Datei `000_setup.R`. Ersetzen Sie den Inhalt des folgenden Scripts:
<script src="https://gist.github.com/gisma/3dfbdd4de0d5b23e51df9885475da82f.js"></script>

Dann speichern und schliessen sie die Datei. Fürs erste ist die Vorbereitung abgeschlossen.


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

Damit Sie Sentinel Daten benutzen können müssen Sie bei SciHub ein [Konto anlegen](https://scihub.copernicus.eu/dhus/#/self-registration)!

Der einfachste Weg, `sen2r` zu benutzen, ist, die grafische Benutzeroberfläche (GUI) zu öffnen und sie im interaktiven Modus zu benutzen. Allerdings muss man hier in den Einstellungen aus einer Vielzahl von Optionen wählen. Die dafür erforderlichen Kenntnisse sind auch für die unten vorgestellte Kommandozeilenversion notwendig. Beide Schnittstellen können automatisiert werden. Wir empfehlen die API, aber letztlich bleibt es Ihnen überlassen. Verwenden Sie dazu die gleichnamige Funktion.

```r
sen2r::sen2r()
```


## Change Detection mit Sentinel Daten
Wir planen eine Veränderung der Waldbedeckung im Harz zu berechnen. Nachdem wir die Vorbereitung abgeschlossen haben (Anlegen der Projektumgebung und Einrichten des sen2r Pakets inkl. des Kontos bei Copernicus) kann es losgehen.

Was zu tun ist:

1. Festlegen der zentralen Parameter wie z.B. Datum (Zeitreihe), Bildausschnitt (AOI),sowie weiterer Parameter wie zb. verschiedene Verzeichnisse.
2. Herunterladen der Daten durch Aufruf der konfigurierten `sen2r::sen2r()` Funktion. Diese lädt dann über die sogenannte API von Copernicus die Daten herunter oder sendet eine email, falls die angeforderten Daten  erst aus dem *Langzeitspeicher* geladen werden müssen. 
3. Berechnen der Oberflächenalbedo  (beipielhaft)


Im folgenden Skript werden auf der Grundlage der oben gezeigten Projekteinrichtung Sentinel-2-Daten für den Juni 2019 heruntergeladen und exemplarisch zuätzlich die Oberflächenalbedo berechnet. 

Achtung zu Beginn muss ein Ausschnitt digitalisiert werden (`harz = mapedit::editMap()`). Das Interface ist selbsterklärend und schaut etwas wie folgt aus:

![](images/HARZ.png)


<script src="https://gist.github.com/gisma/5a11edd28cf81cee523e273b0064bcea.js"></script>

Die [sen2r vignette](https://sen2r.ranghetti.info/) bietet viele hilfreiche Informationen über die Benutzung der GUI und den Zugriff auf die Funktionen von `sen2r` aus `R` heraus.


Für die Bereechnung nutzen wir eine Formel und  die Funktion `stack` aus dem Paket `raster`.  Durch die Verwendung der `::`-Syntax, d.h. `Paket::Funktion`, garantieren wir, dass wir eine bestimmte Funktion aus einem bestimmten Paket verwenden. Dieses Konzept ist wichtig, um sicherzustellen, dass wir die richtige Funktion verwenden (da einige Pakete die gleichen Funktionsnamen verwenden, was als Maskierung bezeichnet wird).
