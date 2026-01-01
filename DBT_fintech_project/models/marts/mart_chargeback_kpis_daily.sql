{{
    config(
        materialized='incremental',
        unique_key=['payment_id', 'chargeback_date'],
        on_schema_change='append_new_columns'
    )
}}

with chargeback_data as (
    select
        payment_id,
        date(opened_ts) as chargeback_date,
        count(chargeback_id) as chargeback_count,
        sum(case when outcome = 'lost' then 1 else 0 end) as lost_chargeback_count,
        sum(case when outcome = 'won' then 1 else 0 end) as won_chargeback_count,
        min(opened_ts) as first_chargeback_ts,
        max(resolved_ts) as last_resolved_ts
    from {{ ref('stg_raw_chargebacks') }}
    {% if is_incremental() %}
        -- Only process new/updated chargebacks for incremental runs
        where (
            select max(chargeback_date) from {{ this }}
        ) is null
        or date(opened_ts) > (
            select max(chargeback_date) from {{ this }}
        )
        or date(coalesce(resolved_ts, opened_ts)) > (
            select max(chargeback_date) from {{ this }}
        )
    {% endif %}
    group by payment_id, date(opened_ts)
)

select * from chargeback_data
