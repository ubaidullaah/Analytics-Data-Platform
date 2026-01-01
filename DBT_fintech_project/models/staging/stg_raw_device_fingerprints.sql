{{
    config(
        materialized='incremental',
        unique_key=['user_id', 'device_id'],
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with raw_data as (
    select * from {{ source('raw_device_fingerprints', 'RAW_DEVICE_FINGERPRINTS') }}
    {% if is_incremental() %}
        -- Only process new records based on last_seen_ts
        where last_seen_ts > (select max(last_seen_ts) from {{ this }})
    {% endif %}
)

select
    user_id,
    device_id,
    first_seen_ts,
    last_seen_ts,
    ip_address
from raw_data
qualify {{ deduplicate(['user_id', 'device_id'], 'last_seen_ts desc, first_seen_ts asc') }}
