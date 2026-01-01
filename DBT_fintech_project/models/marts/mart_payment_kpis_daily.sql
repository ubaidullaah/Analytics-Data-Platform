{{
    config(
        materialized='incremental',
        unique_key=['user_id', 'event_date'],
        on_schema_change='append_new_columns'
    )
}}

with payment_data as (
    select
        user_id,
        date(event_ts) as event_date,
        sum(amount) as total_payment,
        count(payment_event_id) as payment_count,
        sum(case when status = 'failed' then 1 else 0 end) as failed_count,
        sum(case when status = 'captured' then 1 else 0 end) as captured_count,
        sum(case when status = 'captured' then amount else 0 end) as captured_amount,
        -- Calculate success rate (Snowflake doesn't have SAFE_DIVIDE)
        case 
            when count(payment_event_id) > 0 
            then (sum(case when status = 'captured' then 1 else 0 end)::float / count(payment_event_id)::float) * 100
            else 0 
        end as success_rate_pct
    from {{ ref('stg_raw_payment_events') }}
    {% if is_incremental() %}
        -- Only process new data for incremental runs
        -- If table is empty (max is NULL), process all records; otherwise filter for new ones
        where (select max(event_date) from {{ this }}) is null
           or date(event_ts) > (select max(event_date) from {{ this }})
    {% endif %}
    group by user_id, date(event_ts)
)

select * from payment_data
