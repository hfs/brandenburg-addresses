---
title: Use with MapWithAI
layout: page
parent: Brandenburg Addresses 🇬🇧
nav_order: 4
---

# Use with MapWithAI

The possibly missing addresses can also be loaded via the
[JOSM plugin MapWithAI](https://josm.openstreetmap.de/wiki/Help/Plugin/MapWithAI)
and transferred more quickly into OSM objects! The plugin allows you to view
the same data and, if necessary, to transfer it as in the
[RapID-Editor](https://rapideditor.org/). Mostly these are automatically
detected missing streets and buildings. Since September 2023 it is relatively
easy to
[provide your own data for the plugin](https://www.openstreetmap.org/user/vorpalblade/diary/402377).


## One-time setup

The Brandenburg addresses as data source have to be set up once.

1. Install plugin `MapWithAI` version 824 or newer in JOSM if you don’t have
   it, yet: _Edit › Settings (F12) › Extensions_, search for `mapwithai` and
   check the box for the extension.
2. Add the missing addresses as data source: _Edit › Settings (F12) › MapWithAI
   preferences_. In the _Selected entries_ section, press the “Plus” button ➕.
   * 2\. _Enter Service URL_: `https://hfs.github.io/brandenburg-addresses/missing.pmtiles`
   * Check _Is the layer properly georeferenced?_
   * 3\. _Enter name for this source_:
     `GeoBasis-DE/LGB (2025): Georeferenzierte Adresse`. By setting the
     official name here, you ensure the correct attribution of the data source
     when uploading.
   * 4\. _What is the type of this source?_ `PMTILES`

![Screenshot of the dialog for adding a new MapWithAI data source](/brandenburg-addresses/assets/images/mapwithai_config_en.png)


## Data transfer during mapping

The plugin supports address mapping by automatically loading any missing addresses in the map view.
Addresses can be transferred into the OSM data quickly.

1. Load OSM data in the desired map view.
2. Load missing addresses: _Data › MapWithAI › GeoBasis-DE/LGB (2025): Georeferenzierte Adresse_
3. The possibly missing addresses appear in a new layer “MapWithAI”.  
![Screenshot of JOSM with missing address nodes in a MapWithAI layer. The layer is above a deactivated normal layer with OSM data](/brandenburg-addresses/assets/images/mapwithai_layer_en.jpg)
4. Now check which of these addresses are correct and can be adopted. There is
   a key combination Ctrl+R to quickly switch back to the data layer. Of course
   you can and should also use additional background layers e.g. the aerial
   images or WebAtlas.
5. if you want to transfer addresses, activate the MapWithAI layer again
   (Ctrl+R). Select the addresses to be transferred (lasso selection or
   shift-click). With Shift+A or in the menu _Data › MapWithAI › MapWithAI: Add
   selected data_ the data is transferred into the OSM layer.

![Screenshot of the JOSM data layer after importing some addresses from the MapWithAI layer](/brandenburg-addresses/assets/images/mapwithai_data_import_en.jpg)


This method allows you to add addresses more quickly once you have completed
the one-time setup. You no longer have to copy the street names and house
numbers from the background layer.


As you can see, the address tags are transferred to the building outlines if
they already exist. It is therefore advisable to first add or fix the building
outlines in the normal OSM data layer and only afterwards transfer the
addresses. If this behavior is not desired, it can also be deactivated in the
plugin settings by unchecking the box next to _Merge address nodes and
buildings_.


![Screenshot of the settings dialog of the MapWithAI plugin in JOSM](/brandenburg-addresses/assets/images/mapwithai_preferences_en.png)
