---
title: Einbinden der Daten in JOSM
layout: page
parent: Adressen in Brandenburg 🇩🇪
nav_order: 3
---

# Einbinden der Daten in JOSM

Die JOSM-Version muss **18578** oder neuer sein. Eine neuere Version kann man
ggf. auf der [JOSM-Seite](https://josm.openstreetmap.de/) herunterladen.

Die Daten werden als Vektordaten-Layer bereitgestellt. Sie müssen einmalig als
Hintergrundbild eingerichtet werden.

* *Einstellungen* (F12) › *Hintergrundbild* › *Hintergrundanbieter*.
* Neben der unteren Liste *Gewählte Einträge* drücke den Knopf *+ MVT*.
* 2\. URL = `https://hfs.github.io/brandenburg-addresses/style.json`
* 5\. Name für diese Ebene eingeben = `Brandenburg GeoBasis-DE/LGB (2024):
  Georeferenzierte Adresse`. Wenn man genau diesen Namen verwendet, kann man
  beim Upload von Änderungen leicht die zwingend nötige Quellenangabe im
  `source`-Tag hinzufügen.

![Bildschirmfoto des Dialogs zum Hinzufügen einer neuen Hintergrundebene](/brandenburg-addresses/assets/images/imagery_de.png)

Anschließend kann die Ebene über das Menü *Hintergrund* › *Brandenburg
GeoBasis-DE/LGB (2024): Georeferenzierte Adresse* hinzugefügt werden.



