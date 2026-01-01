{{
    config(
        materialized='incremental',
        unique_key='chargeback_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with raw_data as (
    select * from {{ source('raw_chargebacks', 'RAW_CHARGEBACKS') }}
    {% if is_incremental() %}
        -- Only process new records based on src_loaded_at
        where src_loaded_at > (select max(src_loaded_at) from {{ this }})
    {% endif %}
)

select
    chargeback_id,
    payment_id,
    opened_ts,
    resolved_ts,
    outcome,
    src_file_name,
    src_loaded_at
from raw_data
qualify row_number() over (
    partition by chargeback_id 
    order by src_loaded_at desc, resolved_ts desc nulls last
) = 1
