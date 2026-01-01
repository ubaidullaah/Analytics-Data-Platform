{{
    config(
        materialized='incremental',
        unique_key=['user_id', 'event_date'],
        on_schema_change='append_new_columns'
    )
}}

with risk_data as (
    select
        pe.user_id,
        date(pe.event_ts) as event_date,
        count(distinct df.device_id) as device_count,
        count(pe.payment_event_id) as total_attempts,
        max(pe.event_ts) as last_payment_attempt,
        count(distinct df.ip_address) as distinct_ip_count,
        -- Risk signals
        case 
            when count(distinct df.device_id) > 3 then true 
            else false 
        end as high_device_velocity,
        case 
            when count(pe.payment_event_id) > 10 then true 
            else false 
        end as high_attempt_velocity
    from {{ ref('stg_raw_payment_events') }} pe
    left join {{ ref('stg_raw_device_fingerprints') }} df 
        on pe.user_id = df.user_id
    {% if is_incremental() %}
        -- Only process new data for incremental runs
        -- If table is empty (max is NULL), process all records; otherwise filter for new ones
        where (select max(event_date) from {{ this }}) is null
           or date(pe.event_ts) > (select max(event_date) from {{ this }})
    {% endif %}
    group by pe.user_id, date(pe.event_ts)
)

select * from risk_data
