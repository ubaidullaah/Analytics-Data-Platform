{{
    config(
        materialized='incremental',
        unique_key='payment_event_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with raw_data as (
    select * from {{ source('raw_payment_events', 'RAW_PAYMENT_EVENTS') }}
    {% if is_incremental() %}
        where src_loaded_at > (select max(src_loaded_at) from {{ this }})
    {% endif %}
)

select
    payment_event_id,
    payment_id,
    user_id,
    merchant_id,
    amount,
    currency,
    event_ts,
    status,
    failure_reason,
    payment_method,
    attempt_number,
    src_file_name,
    src_loaded_at
from raw_data
qualify {{ deduplicate('payment_event_id', 'src_loaded_at desc, event_ts desc') }}
