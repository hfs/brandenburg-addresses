---
title: Nicht blind importieren!
layout: page
parent: Adressen in Brandenburg 🇩🇪
nav_order: 2
---

# Nicht blind importieren!

Es gibt viele mögliche Gründe, warum eine Adresse nicht in OSM ist. Bitte
kopiere nicht blindlings Adressen in OSM, nur um „aufzuräumen“. Im Idealfall
nutzt man Informationen aus mehreren Quellen, um ein vollständiges Bild zu
bekommen.

Falls es Widersprüche zwischen den Daten in OSM und denen von der LGB gibt,
editiere im Zweifelsfall lieber nichts. Die Situation sollte am Boden vor Ort
überprüft werden. Du kannst eine Notiz hinterlassen.


## Unbebaute Grundstücke

Adressen werden zu Grundstücken zugeteilt und nicht zu Gebäuden. Unbebaute
Grundstücke in Wohngebieten haben also im Allgemeinen auch eine Hausnummer. In
OSM wird üblicherweise nur erfasst, was vor Ort zu sehen ist.

![Luftbild eines Wohngebiets mit vielen unbebauten Grundstücken](/brandenburg-addresses/assets/images/empty_lots.jpg)


## Neubaugebiet

Adressen werden zu Grundstücken zugeteilt, und zwar oft lange im Voraus. Hier
sollte die Situation vor Ort überprüft werden. Wenn vor Ort noch keine Häuser
oder Hausnummern zu sehen sind, sollten sie noch nicht hinzugefügt werden.

![Luftbild eines Neubaugebiets, in dem noch keine Häuser zu sehen sind. Viele Hausnummern sind schon offiziell zugeteilt, aber noch nicht in OSM erfasst](/brandenburg-addresses/assets/images/construction_site.jpg)


## Adressblock für ein Grundstück

Große Grundstücke – im Beispiel eine Schule – können mehrere Hausnummern
zugewiesen bekommen. Manchmal verwenden die Nutzer nur eine davon. Andere geben
den ganzen Block an („26–40“). Es sollte gemappt werden, was vor Ort zu sehen
ist, z.B. welche Hausnummern auf Schildern stehen.

![Luftbild eines Schulgeländes mit mehreren Hausnummern](/brandenburg-addresses/assets/images/school.jpg)


## Mehrere Hausnummern für ein Gebäude

Größere Gebäude – typischerweise Wohnblocks – können mehrere Hausnummern
erhalten. Im folgenden Beispiel sind die Hausnummern als Liste `1;3;5` usw.
erfasst. Dies könnte durch je einen Knoten pro Hausnummer ersetzt werden.
Üblicherweise werden diese dann an die Position der Eingänge gesetzt.

![Bildschirmfoto aus dem JOSM-Editor mit 4 Wohnblocks und als fehlend markierten Hausnummern](/brandenburg-addresses/assets/images/apartments.jpg)



