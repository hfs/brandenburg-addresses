---
title: Using the data in JOSM
layout: page
parent: Brandenburg Addresses 🇬🇧
nav_order: 3
---

# Using the data in JOSM

The JOSM version must be **18578** or newer. You can download a recent version
from the [JOSM site](https://josm.openstreetmap.de/) if you don’t have it, yet.

The address data is served as vector data layer. You have to configure it once
as background imagery layer.

* *Preferences* (F12) › *Imagery* › *Imagery providers*.
* Press the button *+ MVT* next to the bottom table *Selected entries*.
* 2\. URL = `https://hfs.github.io/brandenburg-addresses/style.json`
* 5\. Enter name for this layer = `Brandenburg GeoBasis-DE/LGB (2022):
  Georeferenzierte Adresse`. If you use exactly this name (in German), it will
  automatically be used for the mandatory attribution in the `source` tag when
  uploading changsets.

![Screenshot of the dialog to add a new imagery provider](/brandenburg-addresses/assets/images/imagery_en.png)

Afterwards you can add the layer via the menu *Imagery* › *Brandenburg
GeoBasis-DE/LGB (2022): Georeferenzierte Adresse* hinzugefügt werden.
