---
title: Adressen in Brandenburg
description: >-
  Dieses Projekt gleicht die offiziellen Adress-Daten (Hausnummern) des Landes
  Brandenburg mit den Adressen in OpenStreetMap ab und hebt die Adressen
  hervor, die in OpenStreetMap möglicherweise fehlen.
---

## *[🇬🇧 English Version](en)*


## Vorschau

{% include help_de.html %}
{% include map.html %}


## Hintergrund-Information

Die Geo-Basisdaten des Landes Brandenburg sind seit Ende 2019 als Open Data
unter der Lizenz „Datenlizenz Deutschland 2.0 Namensnennung
[dl/de/by-2.0](https://www.govdata.de/dl-de/by-2-0)“
freigegeben. Dazu gehören auch die
[Georeferenzierten Adressen (Hauskoordinaten)](https://geobasis-bb.de/lgb/de/geodaten/liegenschaftskataster/georeferenzierte-adresse/).
Seit April 2020 wurde die Verwendung für OpenStreetMap
[ermöglicht](https://wiki.openstreetmap.org/wiki/Brandenburg/Geoportal).

Dieses Projekt stellt die Georeferenzierten Adressen als Hintergrund-Layer für
den
[OpenStreetMap-Editor JOSM](https://josm.openstreetmap.de/)
zur Verfügung. Dabei werden die Adressen mit den Daten in OpenStreetMap
abgeglichen und diejenigen hervorgehoben, die in OpenStreetMap möglicherweise
fehlen.


## Quellenangabe

Diese Daten dürfen benutzt werden, um OpenStreetMap zu bearbeiten. Es muss dann
zwingend als Quellenangabe

    GeoBasis-DE/LGB (2022): Georeferenzierte Adresse

im `source`-Tag des Changesets angegeben werden.

Hintergrundinformationen siehe
[OSM-Wiki: Brandenburg/Geoportal](https://wiki.openstreetmap.org/wiki/Brandenburg/Geoportal).


## Nicht blind importieren!

Es gibt viele mögliche Gründe, warum eine Adresse nicht in OSM ist. Bitte
kopiere nicht blindlings Adressen in OSM, nur um „aufzuräumen“. Im Idealfall
nutzt man Informationen aus mehreren Quellen, um ein vollständiges Bild zu
bekommen.

Falls es Widersprüche zwischen den Daten in OSM und denen von der LGB gibt,
editiere im Zweifelsfall lieber nichts. Die Situation sollte am Boden vor Ort
überprüft werden. Du kannst eine Notiz hinterlassen.


### Unbebaute Grundstücke

Adressen werden zu Grundstücken zugeteilt und nicht zu Gebäuden. Unbebaute
Grundstücke in Wohngebieten haben also im Allgemeinen auch eine Hausnummer. In
OSM wird üblicherweise nur erfasst, was vor Ort zu sehen ist.

![Luftbild eines Wohngebiets mit vielen unbebauten Grundstücken](/brandenburg-addresses/assets/images/empty_lots.jpg)


### Neubaugebiet

Adressen werden zu Grundstücken zugeteilt, und zwar oft lange im Voraus. Hier
sollte die Situation vor Ort überprüft werden. Wenn vor Ort noch keine Häuser
oder Hausnummern zu sehen sind, sollten sie noch nicht hinzugefügt werden.

![Luftbild eines Neubaugebiets, in dem noch keine Häuser zu sehen sind. Viele Hausnummern sind schon offiziell zugeteilt, aber noch nicht in OSM erfasst](/brandenburg-addresses/assets/images/construction_site.jpg)


### Adressblock für ein Grundstück

Große Grundstücke – im Beispiel eine Schule – können mehrere Hausnummern
zugewiesen bekommen. Manchmal verwenden die Nutzer nur eine davon. Andere geben
den ganzen Block an („26–40“). Es sollte gemappt werden, was vor Ort zu sehen
ist, z.B. welche Hausnummern auf Schildern stehen.

![Luftbild eines Schulgeländes mit mehreren Hausnummern](/brandenburg-addresses/assets/images/school.jpg)


### Mehrere Hausnummern für ein Gebäude

Größere Gebäude – typischerweise Wohnblocks – können mehrere Hausnummern
erhalten. Im folgenden Beispiel sind die Hausnummern als Liste `1;3;5` usw.
erfasst. Dies könnte durch je einen Knoten pro Hausnummer ersetzt werden.
Üblicherweise werden diese dann an die Position der Eingänge gesetzt.

![Bildschirmfoto aus dem JOSM-Editor mit 4 Wohnblocks und als fehlend markierten Hausnummern](/brandenburg/addresses/assets/images/apartments.jpg)


## Tipps zum Bearbeiten von Adressen in JOSM

Über *Vorlagen › Vorlagen suchen… › Annotation/Address* gibt es einen Dialog,
mit dem man einfacher mehrere Adressen hinzufügen kann. Der Dialog merkt sich
alles bis auf die Hausnummer zwischen den Aufrufen. Wenn man mehrere
Hausnummern in einer Straße hinzufügen will, braucht man nur einmal
Straßenname, PLZ usw. einzutippen. Für das nächste Haus braucht man nur noch
die Hausnummer einzugeben.

Mit den Schaltflächen `+1`, `+2` usw. im Dialog kann man die Hausnummern
automatisch hochzählen lassen.

Schließlich kann man noch ein Tastaturkürzel für den Adressdialog hinzufügen.
Dazu unter *Vorlagen › Vorlagen suchen… ›* Rechtsklick auf *Annotation/Address
› Schaltfläche in Werkzeugleiste hinzufügen*. Es erscheint ein Knopf mit
Hausnummer-Icon in der Toolbar. Dort wiederum kann man mit der rechten
Maustaste draufklicken › *Tastenkürzel bearbeiten*. Es öffnet sich der
Einstellungs-Dialog, wo man ein Tastenkürzel auswählen kann.

Am besten fügt man zusätzlich zur Adress-Ebene noch das Luftbild `Brandenburg
GeoBasis-DE/LGB (2022): DOP20c` und die „offizielle“ Karte `Brandenburg
GeoBasis-DE/LGB (2022): WebAtlasDE BE/BB` hinzu. Mit den Tasten `Alt+1`,
`Alt+2` usw. kann man schnell Ebenen ein- und ausblenden.


## Siehe auch

* [Hausnummernauswertung auf regio-osm.de](https://regio-osm.de/hausnummerauswertung/)
* [Addresses with errors in OSM – Brandenburg](https://osm.zz.de/dbview/?db=addresses-bb&layer=addresserror#52.42587,13.61755,8z)


## Letzte Änderung

* Georeferenzierte Adressen: Stand $ADDRESS_DATE
* OpenStreetMap dump: $OSM_DATE
* OpenStreetMap letzte Änderung von: $CHANGE_DATE
* Daten generiert: $TILES_DATE
