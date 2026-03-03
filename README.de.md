# InfluxDB Measurement-Bereinigungsskript

Ein Bash-Skript, um mehrere Measurements aus einem InfluxDB-2.x-Bucket zu löschen.

**🇬🇧 English version:** [README.md](README.md)

## Überblick

Dieses Skript adressiert die Einschränkung, dass InfluxDBs `delete`-Befehl keine Wildcards oder Regex-Muster unterstützt. Statt jedes Measurement manuell einzeln zu löschen, automatisiert dieses Skript den Prozess durch Iteration über eine vordefinierte Liste von Measurements.

**Zweck:** Speziell für das Bereinigen interner InfluxDB-Metriken, die durch den eingebauten Scraper gesammelt werden (Prometheus/Go-Runtime-Metriken, interne InfluxDB-Statistiken, Storage-Metriken, Task-Scheduler-Metriken usw.). Diese Measurements sammeln sich häufig mit der Zeit an und können erheblichen Speicherplatz verbrauchen.

## Funktionen

- ✅ Stapelweises Löschen mehrerer Measurements
- ✅ Konfigurierbarer Bucket, Organisation und Zeitbereich
- ✅ Optionale Token-Authentifizierung
- ✅ Verfolgung von Erfolgen/Fehlern mit Zusammenfassung
- ✅ Sichere Fehlerbehandlung mit Unterdrückung von `stderr`

## Enthaltene Measurements

Das Skript ist bereits mit typischen InfluxDB-Scraper-Metriken vorkonfiguriert:

- **Go-Runtime-Metriken** (`go_*`): Garbage Collection, Speicherstatistiken, Goroutinen, Threads
- **Interne InfluxDB-Metriken** (`influxdb_*`): Buckets, Benutzer, Tokens, Organisationen, Uptime
- **Storage-Metriken** (`storage_*`): Cache, WAL, TSM-Dateien, Shards, Compactions
- **HTTP-API-Metriken** (`http_api_*`, `http_query_*`): Request-Anzahl, Laufzeiten, Bytes
- **Task-Scheduler-Metriken** (`task_*`): Ausführungsstatistiken, Worker-Status
- **Query-Compiler-Metriken** (`qc_*`): Kompilierung, Ausführung, Queueing
- **Service-Metriken** (`service_*`): Verschiedene interne Service-Call-Statistiken
- **BoltDB-Metriken** (`boltdb_*`): Datenbank-Lese- und Schreibzugriffe

Du kannst das Array `MEASUREMENTS` anpassen, um nur die Metriken zu löschen, die du wirklich entfernen möchtest.

## Voraussetzungen

- InfluxDB 2.x installiert
- InfluxDB CLI (`influx`) im `PATH` verfügbar
- Bash-Shell
- Ausreichende Berechtigungen, um Daten aus dem Ziel-Bucket zu löschen

## Installation

1. Skript herunterladen:
```bash
wget https://github.com/Marc-Berg/influxdb-metrics-cleanup/blob/main/delete_measurements.sh
```

2. Ausführbar machen:
```bash
chmod +x delete_measurements.sh
```

## Konfiguration

Skript öffnen und diese Variablen am Anfang anpassen:

```bash
BUCKET="test"                      # Name deines InfluxDB-Buckets
ORG="home"                         # Name deiner Organisation
TOKEN=""                           # Authentifizierungs-Token (leer lassen, falls nicht nötig)
START="1970-01-01T00:00:00Z"      # Start des Zeitbereichs
STOP="2030-01-01T00:00:00Z"       # Ende des Zeitbereichs
```

Measurements im Array `MEASUREMENTS` hinzufügen oder entfernen:

```bash
MEASUREMENTS=(
"go_gc_duration_seconds"
"go_goroutines"
"go_info"
# ... hier weitere Measurements ergänzen
)
```

## Verwendung

Skript einfach ausführen:

```bash
./delete_measurements.sh
```

### Beispielausgabe

```
Starting deletion process for 123 measurements...
Bucket: test
Organization: home

Deleting 'go_gc_duration_seconds'... ✓
Deleting 'go_goroutines'... ✓
Deleting 'go_info'... ✓
...

Done!
Successfully deleted: 120
Failed: 3
```

## Measurements finden

Alle Measurements in deinem Bucket auflisten:

```bash
influx query 'import "influxdata/influxdb/schema"
schema.measurements(bucket: "YOUR_BUCKET")' \
  --org YOUR_ORG
```

Oder per Flux in der InfluxDB-UI:

```flux
import "influxdata/influxdb/schema"
schema.measurements(bucket: "YOUR_BUCKET")
```

## Sicherheitshinweis

⚠️ **Warnung**: Dieses Skript löscht Daten **dauerhaft**. Daher immer:
- Zuerst in einem Nicht-Produktiv-Bucket testen
- Vorab ein Backup erstellen
- Das Array `MEASUREMENTS` doppelt prüfen
- Den Zeitbereich (`START` und `STOP`) verifizieren

## Fehlerbehebung

**Skript meldet Fehler:**
- Prüfen, ob die InfluxDB CLI installiert und im `PATH` ist
- Verifizieren, dass dein Token Löschrechte hat
- Sicherstellen, dass Bucket- und Org-Namen korrekt sind

**Probleme mit Token-Authentifizierung:**
- Wenn deine InfluxDB-Instanz keine Tokens benötigt, `TOKEN=""` leer lassen
- Wenn nötig, in der InfluxDB-UI ein Token mit Löschrechten erzeugen

## Mitwirken

Beiträge sind willkommen! Du kannst gerne:
- Bugs melden
- Features vorschlagen
- Pull Requests einreichen

## Lizenz

MIT License – Details in der Datei [LICENSE](LICENSE)