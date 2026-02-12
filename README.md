# InfluxDB Measurement Cleanup Script

A bash script to efficiently delete multiple measurements from an InfluxDB 2.x bucket.

## Overview

This script addresses the limitation that InfluxDB's `delete` command does not support wildcards or regex patterns in predicates. Instead of manually deleting each measurement one by one, this script automates the process by iterating through a predefined list of measurements.

**Purpose:** Specifically designed to clean up internal InfluxDB metrics that are collected by the built-in scraper (Prometheus/Go runtime metrics, InfluxDB internal stats, storage metrics, task scheduler metrics, etc.). These measurements often accumulate over time and can consume significant storage space.

## Features

- ✅ Batch deletion of multiple measurements
- ✅ Configurable bucket, organization, and time range
- ✅ Optional token authentication
- ✅ Success/failure tracking with summary report
- ✅ Safe error handling with stderr suppression

## Included Measurements

The script comes pre-configured with common InfluxDB scraper metrics:

- **Go runtime metrics** (`go_*`): Garbage collection, memory stats, goroutines, threads
- **InfluxDB internal metrics** (`influxdb_*`): Buckets, users, tokens, organizations, uptime
- **Storage metrics** (`storage_*`): Cache, WAL, TSM files, shards, compactions
- **HTTP API metrics** (`http_api_*`, `http_query_*`): Request counts, durations, bytes
- **Task scheduler metrics** (`task_*`): Execution stats, worker status
- **Query compiler metrics** (`qc_*`): Compilation, execution, queueing
- **Service metrics** (`service_*`): Various internal service call statistics
- **BoltDB metrics** (`boltdb_*`): Database reads and writes

You can customize the `MEASUREMENTS` array to include only the metrics you want to delete.

## Prerequisites

- InfluxDB 2.x installed
- InfluxDB CLI (`influx`) available in your PATH
- Bash shell
- Appropriate permissions to delete data from the target bucket

## Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/Marc-Berg/influxdb-measurement-cleanup/main/delete_measurements.sh
```

2. Make it executable:
```bash
chmod +x delete_measurements.sh
```

## Configuration

Edit the script and modify these variables at the top:

```bash
BUCKET="test"                      # Your InfluxDB bucket name
ORG="home"                         # Your organization name
TOKEN=""                           # Your authentication token (leave empty if not needed)
START="1970-01-01T00:00:00Z"      # Start of time range
STOP="2030-01-01T00:00:00Z"       # End of time range
```

Add or remove measurements from the `MEASUREMENTS` array:

```bash
MEASUREMENTS=(
"go_gc_duration_seconds"
"go_goroutines"
"go_info"
# ... add your measurements here
)
```

## Usage

Simply run the script:

```bash
./delete_measurements.sh
```

### Example Output

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

## How to Find Your Measurements

To list all measurements in your bucket:

```bash
influx query 'import "influxdata/influxdb/schema"
schema.measurements(bucket: "YOUR_BUCKET")' \
  --org YOUR_ORG
```

Or using Flux in the InfluxDB UI:

```flux
import "influxdata/influxdb/schema"
schema.measurements(bucket: "YOUR_BUCKET")
```

### Finding Scraper Metrics Specifically

To find measurements that match common scraper patterns:

```bash
influx query 'import "influxdata/influxdb/schema"
schema.measurements(bucket: "YOUR_BUCKET")
  |> filter(fn: (r) => r._value =~ /^(go_|influxdb_|storage_|http_|task_|qc_|service_|boltdb_)/)' \
  --org YOUR_ORG
```

## Background: Why This Script Exists

InfluxDB's delete predicate syntax does **not support**:
- ❌ Wildcards (`_measurement="go_*"`)
- ❌ Regex operators (`_measurement=~/^go_/`)
- ❌ OR operators

As stated in the [InfluxDB documentation](https://docs.influxdata.com/influxdb/v2/reference/syntax/delete-predicate/):
> Delete predicates do not support regular expressions.

This means you must delete each measurement individually. This script automates that tedious process.

## Security Notice

⚠️ **Warning**: This script will **permanently delete data**. Always:
- Test on a non-production bucket first
- Backup your data before running
- Double-check the `MEASUREMENTS` array
- Verify the time range (`START` and `STOP`)

## Troubleshooting

**Script reports failures:**
- Check that the InfluxDB CLI is installed and in your PATH
- Verify your token has delete permissions
- Ensure the bucket and org names are correct

**Token authentication issues:**
- If your InfluxDB instance doesn't require tokens, leave `TOKEN=""` empty
- If required, generate a token in the InfluxDB UI with delete permissions

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Created to solve the common problem of cleaning up accumulated InfluxDB scraper metrics that consume storage space over time.

## Acknowledgments

- InfluxDB Community for discussions on this limitation
- [Community thread](https://community.influxdata.com/t/how-to-delete-multiple-measurements/26839) that confirmed the regex limitation
