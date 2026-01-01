-- Test to ensure that merchant_id is not null
select 
    merchant_id
from {{ ref('stg_raw_merchants') }}
where merchant_id is null

union all

-- Test to ensure that merchant_id is unique
select 
    merchant_id
from {{ ref('stg_raw_merchants') }}
group by merchant_id
having count(*) > 1

