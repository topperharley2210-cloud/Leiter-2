LeiterCheck PWA

Dateien:
- index.html
- manifest.webmanifest
- service-worker.js
- icon-192.svg
- icon-512.svg

Wichtig:
Für Kamera, Service Worker und PWA-Installation sollte die App über HTTPS bereitgestellt werden.
Einfaches Öffnen der index.html als lokale Datei reicht für diese Funktionen nicht zuverlässig aus.

iPad/iPhone:
1. App-URL in Safari öffnen.
2. Teilen.
3. „Zum Home-Bildschirm“ auswählen.

Android:
1. App-URL in Chrome/Edge öffnen.
2. Menü öffnen.
3. „App installieren“ oder „Zum Startbildschirm hinzufügen“.

Die Daten werden weiterhin lokal im Browser/auf dem Gerät gespeichert.

Copyright-Hinweis in der App: © 2026 T. Geib · LeiterCheck
Datenschutzhinweis ist über die Startseite erreichbar.

Datensicherung:
- Backup als JSON-Datei herunterladen
- Backup auf demselben oder einem anderen Gerät wiederherstellen

QR-Sammeldruck:
- Mehrere QR-Etiketten gleichzeitig auswählen und drucken
- Größen 40x40 mm, 50x30 mm und 60x40 mm
- Inventarnummer wird auf dem Etikett nicht angezeigt
- Standort kann optional ein-/ausgeblendet werden

Prüfplaketten/PDF:
- QR-Etiketten als druckfertigen A4-Bogen ausgeben
- Prüfplaketten mit nächstem Prüftermin ausgeben
- Kombinierte QR-/Prüfplaketten möglich
- Im Browser-Druckdialog kann die Ausgabe als PDF gespeichert werden
- Inventarnummer wird weiterhin nicht sichtbar aufgedruckt

Prüfstatus V18:
- Grün: Prüfung länger als 30 Tage gültig
- Gelb: innerhalb der nächsten 30 Tage fällig
- Rot: Prüftermin überschritten
- Grau: kein Prüftermin hinterlegt
- Statusübersicht auf der Startseite
- Historienansicht pro Arbeitsmittel

V19:
- Prüfung kann nur mit Prüfer-Unterschrift gespeichert werden
- Speichern-Schaltfläche bleibt bis zur Unterschrift deaktiviert
- Nächster Prüftermin kann automatisch um 6, 12 oder 24 Monate gesetzt werden
- Neuer Prüftermin wird in die Stammdaten übernommen und im Prüfprotokoll gespeichert

V20 Freigabe/Sperre:
- Ohne Mangel: standardmäßig freigegeben
- Bei Mängeln: eingeschränkt oder gesperrt auswählbar
- Gesperrte Arbeitsmittel erhalten keinen automatischen neuen Prüftermin
- Freigabestatus wird am Arbeitsmittel und im Prüfprotokoll gespeichert
- Filter nach Freigabestatus in der Arbeitsmittelliste

V21 Benutzerrollen & Dashboard:
- Lokale Benutzerverwaltung mit Administrator und Prüfer
- Schutz vor Löschen des letzten Administrators
- Benutzer werden in Datensicherungen aufgenommen
- Dashboard zeigt gesperrte Arbeitsmittel und in 30 Tagen fällige Prüfungen
- Dashboard zeigt die fünf zuletzt gespeicherten Prüfungen
- Struktur dient als Vorbereitung für spätere Cloud-Anmeldung und Synchronisation

V22 Cloud & echte Anmeldung
===========================
Backend: Supabase (Postgres + Auth).

Enthalten:
- E-Mail/Passwort-Anmeldung
- Administrator oder Prüfer
- gemeinsamer Betrieb/Arbeitsbereich
- Einladungscode für weitere Prüfer
- Cloud -> Gerät und Gerät -> Cloud
- automatische Cloud-Synchronisierung nach Änderungen
- lokale Offline-Daten bleiben erhalten
- Prüfer werden in der Oberfläche von Admin-Funktionen ausgeschlossen
- SQL-Datei supabase_setup.sql für Datenbank, Funktionen und Row Level Security

Einrichtung:
1. Kostenloses Supabase-Projekt erstellen.
2. SQL Editor öffnen und supabase_setup.sql einmal vollständig ausführen.
3. In Authentication die gewünschte E-Mail-Konfiguration prüfen.
4. In LeiterCheck -> Cloud & Benutzer die Project URL und den öffentlichen Anon/Publishable Key eintragen.
5. Erstes Konto anlegen/anmelden und einen Betrieb erstellen.
6. Administrator kann den angezeigten Einladungscode an Prüfer weitergeben.

Sicherheit:
- Niemals den Supabase service_role Key in index.html oder LeiterCheck eintragen.
- Die Datenbank verwendet Row Level Security, sodass nur Mitglieder des jeweiligen Betriebs dessen Daten lesen/schreiben können.
- Die Rollenbeschränkung einzelner App-Funktionen ist in V22 zusätzlich clientseitig umgesetzt. Für streng regulierte Mehrmandanten-/Enterprise-Nutzung sollten Schreibrechte später auch tabellenweise serverseitig nach Rollen getrennt werden.
