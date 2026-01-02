-- Test to ensure that user_id is not null
select 
    user_id
from {{ ref('stg_raw_device_fingerprints') }}
where user_id is null

union all

-- Test to ensure that device_id is not null
select 
    device_id
from {{ ref('stg_raw_device_fingerprints') }}
where device_id is null

union all

-- Test to ensure that (user_id, device_id) combination is unique (after deduplication)
select 
    user_id || '|' || device_id as user_id
from {{ ref('stg_raw_device_fingerprints') }}
group by user_id, device_id
having count(*) > 1

