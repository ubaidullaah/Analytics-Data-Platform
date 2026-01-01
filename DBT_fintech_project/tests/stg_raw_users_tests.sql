-- Test to ensure that user_id is not null
select 
    user_id
from {{ ref('stg_raw_users') }}
where user_id is null

union all

-- Test to ensure that user_id is unique (after deduplication)
select 
    user_id
from {{ ref('stg_raw_users') }}
group by user_id
having count(*) > 1