---
title: Don’t import blindly!
layout: page
parent: Brandenburg Addresses 🇬🇧
nav_order: 2
---

# Don’t import blindly!


There are many possible reasons why an address is not in OSM. Please do not
blindly copy addresses into OSM just to "clean up". Ideally, you should use
information from several sources to get a complete idea about reality.

If there are contradictions between the data in OSM and that from LGB, if in
doubt, rather don’t edit anything. The situation should be checked on the
ground. You can leave a note.

## Undeveloped plots

Addresses are assigned to plots and not to buildings. Undeveloped plots in residential areas therefore generally also have a house number. OSM usually only records what can be seen
[on the ground](https://wiki.openstreetmap.org/wiki/Good_practice#Map_what's_on_the_ground).

![Aerial view of a residential area with many empty plots](/brandenburg-addresses/assets/images/empty_lots.jpg)


## New developments

Addresses are allocated to plots of land, often well in advance before
construction starts. Here the situation should be checked on the ground. If no
houses or house numbers can be seen on site, they should not be added to OSM,
yet.

![Aerial view of a new development area where no houses can be seen yet. Many house numbers are already officially allocated, but not yet recorded in OSM](/brandenburg-addresses/assets/images/construction_site.jpg)


## Address block for a property

Large plots of land – a school in the example – can have several house numbers
assigned. Sometimes the occupants use only one of them. Others specify the
whole block (“26–40”). You should map what you see on site, e.g. which house
numbers are shown on signage.

![Aerial view of a school campus with several house numbers](/brandenburg-addresses/assets/images/school.jpg)


## Multiple house numbers for one building

Larger buildings – typically apartment blocks – can have multiple house
numbers.  In the example in the screenshot, the house numbers have been
recorded as a list `1;3;5` in OSM. You may want to replace this with single
nodes per house number.  Usually these are then placed at the position of the
building entrances.

![Screenshot from the JOSM editor with 4 apartment blocks and house numbers marked as missing](/brandenburg-addresses/assets/images/apartments.jpg)
