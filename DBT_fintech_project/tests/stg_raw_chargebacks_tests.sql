-- Test to ensure that chargeback_id is not null
select 
    chargeback_id
from {{ ref('stg_raw_chargebacks') }}
where chargeback_id is null

union all

-- Test to ensure that chargeback_id is unique (after deduplication)
select 
    chargeback_id
from {{ ref('stg_raw_chargebacks') }}
group by chargeback_id
having count(*) > 1

