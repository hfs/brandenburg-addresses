---
title: Verwendung mit MapWithAI
layout: page
parent: Adressen in Brandenburg 🇩🇪
nav_order: 4
---

# Verwendung mit MapWithAI

Die möglicherweise fehlenden Adressen können auch über das [JOSM-Plugin
MapWithAI](https://josm.openstreetmap.de/wiki/Help/Plugin/MapWithAI) geladen
und schneller übernommen werden! Das Plugin erlaubt es, die gleichen Daten
anzusehen und ggf. zu übernehmen wie im
[RapID-Editor](https://rapideditor.org/) – meistens sind das maschinell
erkannte fehlende Straßen und Gebäude. Seit September 2023 ist es relativ
einfach möglich,
[eigene Daten für das Plugin bereit zu stellen](https://www.openstreetmap.org/user/vorpalblade/diary/402377).


## Einmalige Einrichtung

Die Adressen als Datenquelle müssen einmalig eingerichtet werden.

1. Plugin `MapWithAI` Version 824 oder neuer in JOSM installieren sofern noch
   nicht vorhanden: _Bearbeiten › Einstellungen (F12) › Erweiterungen_, dort
   nach `mapwithai` suchen und den Haken bei der Erweiterung setzen.
2. Adressen als Datenquelle hinzufügen: _Bearbeiten › Einstellungen (F12) ›
   MapWithAI preferences_. Im Abschnitt _Gewählte Einträge_ den „Plus“-Button
   ➕ drücken.
   * 2\. _Enter Service URL_: `https://hfs.github.io/brandenburg-addresses/missing.pmtiles`
   * Haken setzen bei _Ist die Ebene richtig Georeferenziert?_
   * 3\. _Enter name for this source_:
     `GeoBasis-DE/LGB (2024): Georeferenzierte Adresse`. Wenn man hier den
     offiziellen Namen setzt, sorgt man gleich für die richtige Attributierung
     der Quelldaten beim Hochladen.
   * 4\. _What is the type of this source?_ `PMTILES`

![Bildschirmfoto des Dialogs zum Hinzufügen einer neuen MapWithAI-Datenquelle](/brandenburg-addresses/assets/images/mapwithai_config_de.png)


## Datenübernahme beim Mapping

Das Plugin unterstützt nun beim Mapping, indem die möglicherweise fehlenden
Adressen im Kartenausschnitt automatisch geladen werden und schnell übernommen
werden können.

1. OSM-Daten im gewünschten Kartenausschnitt laden.
2. Fehlende Adressen laden: _Daten › MapWithAI › GeoBasis-DE/LGB (2024): Georeferenzierte Adresse_
3. Die möglicherweise fehlenden Adressen erscheinen in einem neuen Layer „MapWithAI“.  
![Bildschirmfoto von JOSM mit fehlenden Adress-Knoten in einer MapWithAI-Ebene. Die Ebene liegt über einer deaktivierten normalen Ebene mit OSM-Daten](/brandenburg-addresses/assets/images/mapwithai_layer_de.jpg)
4. Jetzt überprüft man, welche von diesen Adressen übernommen werden sollen. Es
   gibt eine Tastenkombination Ctrl+R, um schnell zum Datenlayer zurückschalten
   zu können. Man kann und sollte natürlich auch zusätzliche Hintergrundebenen
   heranziehen, z.B. die Luftbilder oder WebAtlas.
5. Wenn man Adressen übernehmen möchte, aktiviert man wieder die
   MapWithAI-Ebene (Ctrl+R). Man wählt die Adressen aus, die übernommen werden
   sollen (Lasso-Auswahl oder Shift-Klick). Mit Umschalt+A oder im Menü _Daten
   › MapWithAI › MapWithAI: Add selected data_ werden die Daten übernommen.

![Bildschirmfoto von der JOSM-Datenebene nach Übernahme einiger Adressen aus der MapWithAI-Ebene](/brandenburg-addresses/assets/images/mapwithai_data_import_de.jpg)

Mit dieser Methode kann man schneller Adressen hinzufügen, wenn man den
einmaligen Einrichtungsaufwand hinter sich hat. Man muss die Straßennamen und
Hausnummern nicht mehr von der Hintergrundebene abtippen.

Wie man sieht, werden die Adressdaten auf die Gebäudeumrisse übernommen, wenn
es sie schon gibt. Es empfiehlt sich daher, bei Bedarf in der normalen
Datenebene zunächst die Gebäudeumrisse zu vervollständigen und erst danach die
Adressen zu übernehmen. Falls dieses Verhalten nicht gewünscht ist, kann man es
in den Plugin-Einstellungen auch abschalten, indem man den Haken bei _Merge
address nodes and buildings_ entfernt.

![Bildschirmfoto des Einstellungs-Dialogs des MapWithAI-Plugins in JOSM](/brandenburg-addresses/assets/images/mapwithai_preferences_de.png)
