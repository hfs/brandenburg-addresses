---
title: Brandenburg Addresses 🇬🇧
layout: home
has_children: true
---

# Addresses in Brandenburg (Germany) in OpenStreetMap

This project compares the official address data (house numbers) of the state of
Brandenburg in Germany with the addresses mapped in OpenStreetMap. It
highlights the addresses that might still be missing in OpenStreetMap.

## Preview

{% include help_en.html %}
{% include map.html %}


## Background info

The basic geo data of the state of Brandenburg (in Germany) are available as
Open Data under the license “Data licence Germany – attribution – version 2.0
[dl/de/by-2.0](https://www.govdata.de/dl-de/by-2-0)”. This includes the
[Georeferenced Addresses (house number coordinates)](https://geobasis-bb.de/lgb/de/geodaten/liegenschaftskataster/georeferenzierte-adresse/).
Since April 2020 it is possible to use this data in OpenStreetMap.


## Using the data in JOSM

This project provides the Georeferenced Addresses as background layer for the
[OpenStreetMap editor JOSM](https://josm.openstreetmap.de/).
The official addresses are compared to the ones on OpenStreetMap. Those
addresses that might be missing in OpenStreetMap are highlighted.


### Overview on low zoom level

On low zoom levels you get an overview where addresses might be missing in
OpenStreetMap: Red colors mean that more addresses could not be matched.

![Screenshot of the OSM editor JOSM with the georeferenced addresses as background layer](assets/images/josm_1.jpg)


### Single addresses as points

If you zoom in a little, the single addresses are drawn as points and colored:
white = match, pink = no match, blue = match, but more than 75 m apart.

![Georeferenced addresses as background layer with points for each address](assets/images/josm_2.jpg)


### House numbers

If zoom the map to the level of single houses, the house numbers are shown. In
this view it’s easy to add house numbers if it’s clear which street they belong
to.

![Georeferenced addresses as background layer with single house numbers](assets/images/josm_2.jpg)


### Complete Addresses

If you zoom in even further, the complete addresses including street, postal
code, municipal district and municipality are shown. This is helpful to get
this data directly, or if it’s not clear which street the number belongs to.

![Background layer with complete addresses](assets/images/josm_4.jpg)


## Use with MapWithAI

An alternative method for advanced mappers is to [use the data with MapWithAI](mapwithai/)
