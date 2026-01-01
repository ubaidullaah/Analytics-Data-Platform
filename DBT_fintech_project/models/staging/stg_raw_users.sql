{{
    config(
        materialized='incremental',
        unique_key='user_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

with raw_data as (
    select * from {{ source('raw_users', 'RAW_USERS') }}
    {% if is_incremental() %}
        -- Only process new records based on created_at
        where created_at > (select max(created_at) from {{ this }})
    {% endif %}
)

select
    user_id,
    created_at,
    country,
    kyc_level,
    marketing_channel
from raw_data
qualify row_number() over (
    partition by user_id 
    order by created_at desc
) = 1
