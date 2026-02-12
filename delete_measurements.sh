#!/bin/bash
 
# InfluxDB Configuration
BUCKET="test"
ORG="home"
TOKEN=""   # Leave empty if no token is used
START="1970-01-01T00:00:00Z"
STOP="2030-01-01T00:00:00Z"
 
# List of all measurements to delete
MEASUREMENTS=(
"boltdb_reads_total"
"boltdb_writes_total"
"go_gc_duration_seconds"
"go_goroutines"
"go_info"
"go_memstats_alloc_bytes"
"go_memstats_alloc_bytes_total"
"go_memstats_buck_hash_sys_bytes"
"go_memstats_frees_total"
"go_memstats_gc_sys_bytes"
"go_memstats_heap_alloc_bytes"
"go_memstats_heap_idle_bytes"
"go_memstats_heap_inuse_bytes"
"go_memstats_heap_objects"
"go_memstats_heap_released_bytes"
"go_memstats_heap_sys_bytes"
"go_memstats_last_gc_time_seconds"
"go_memstats_lookups_total"
"go_memstats_mallocs_total"
"go_memstats_mcache_inuse_bytes"
"go_memstats_mcache_sys_bytes"
"go_memstats_mspan_inuse_bytes"
"go_memstats_mspan_sys_bytes"
"go_memstats_next_gc_bytes"
"go_memstats_other_sys_bytes"
"go_memstats_stack_inuse_bytes"
"go_memstats_stack_sys_bytes"
"go_memstats_sys_bytes"
"go_threads"
"service_token_call_total"
"service_token_duration"
"http_api_request_duration_seconds"
"http_api_requests_total"
"http_query_request_bytes"
"http_query_request_count"
"http_query_response_bytes"
"influxdb_buckets_total"
"influxdb_dashboards_total"
"influxdb_info"
"influxdb_organizations_total"
"influxdb_remotes_total"
"influxdb_replications_total"
"influxdb_scrapers_total"
"influxdb_telegrafs_total"
"influxdb_tokens_total"
"influxdb_uptime_seconds"
"influxdb_users_total"
"qc_all_active"
"qc_all_duration_seconds"
"qc_compiling_active"
"qc_compiling_duration_seconds"
"qc_executing_active"
"qc_executing_duration_seconds"
"qc_memory_unused_bytes"
"qc_queueing_active"
"qc_queueing_duration_seconds"
"qc_requests_total"
"query_influxdb_source_read_request_duration_seconds"
"service_bucket_new_call_total"
"service_bucket_new_duration"
"service_bucket_new_error_total"
"service_onboard_new_call_total"
"service_onboard_new_duration"
"service_org_call_total"
"service_org_duration"
"service_org_new_call_total"
"service_org_new_duration"
"service_org_new_error_total"
"service_password_new_call_total"
"service_password_new_duration"
"service_session_call_total"
"service_session_duration"
"service_session_error_total"
"service_urm_new_call_total"
"service_urm_new_duration"
"service_user_new_call_total"
"service_user_new_duration"
"storage_bucket_measurement_num"
"storage_bucket_series_num"
"storage_cache_disk_bytes"
"storage_cache_inuse_bytes"
"storage_cache_latest_snapshot"
"storage_cache_writes_dropped"
"storage_cache_writes_err"
"storage_cache_writes_total"
"storage_compactions_queued"
"storage_retention_check_duration"
"storage_shard_disk_size"
"storage_shard_fields_created"
"storage_shard_series"
"storage_shard_write_count"
"storage_shard_write_dropped_sum"
"storage_shard_write_err_count"
"storage_shard_write_err_sum"
"storage_shard_write_sum"
"storage_tsm_files_disk_bytes"
"storage_tsm_files_total"
"storage_wal_size"
"storage_wal_writes"
"storage_wal_writes_err"
"storage_writer_dropped_points"
"storage_writer_err_points"
"storage_writer_ok_points"
"storage_writer_req_points"
"storage_writer_timeouts"
"task_executor_promise_queue_usage"
"task_executor_total_runs_active"
"task_executor_workers_busy"
"task_scheduler_current_execution"
"task_scheduler_execute_delta"
"task_scheduler_schedule_delay"
"task_scheduler_total_execute_failure"
"task_scheduler_total_execution_calls"
"task_scheduler_total_release_calls"
"task_scheduler_total_schedule_calls"
"task_scheduler_total_schedule_fails"
)
 
echo "Starting deletion process for ${#MEASUREMENTS[@]} measurements..."
echo "Bucket: $BUCKET"
echo "Organization: $ORG"
echo ""
 
SUCCESS=0
FAILED=0
 
# Base arguments for influx CLI
INFLUX_ARGS=(delete --bucket "$BUCKET" --org "$ORG" --start "$START" --stop "$STOP")
 
# Only append token if not empty
if [[ -n "$TOKEN" ]]; then
    INFLUX_ARGS+=(--token "$TOKEN")
fi
 
# Iterate through all measurements
for measurement in "${MEASUREMENTS[@]}"; do
    echo -n "Deleting '$measurement'... "
    
    if influx "${INFLUX_ARGS[@]}" \
        --predicate "_measurement=\"$measurement\"" 2>/dev/null; then
        echo "✓"
        ((SUCCESS++))
    else
        echo "✗"
        ((FAILED++))
    fi
done
 
echo ""
echo "Done!"
echo "Successfully deleted: $SUCCESS"
echo "Failed: $FAILED"