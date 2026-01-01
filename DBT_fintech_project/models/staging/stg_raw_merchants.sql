{{
    config(
        materialized='incremental',
        unique_key='merchant_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

-- For merchants without a timestamp, process all records and let merge handle updates/inserts
-- This is fine for slowly-changing reference data with low volume
select
    merchant_id,
    merchant_name,
    merchant_category,
    country
from {{ source('raw_merchants', 'RAW_MERCHANTS') }}
qualify row_number() over (
    partition by merchant_id 
    order by merchant_id
) = 1
