-- Test to ensure that payment_event_id is unique
select 
    payment_event_id
from {{ ref('stg_raw_payment_events') }}
group by payment_event_id
having count(*) > 1

union all

-- Test to ensure that the status is one of the accepted values
select 
    status as payment_event_id
from {{ ref('stg_raw_payment_events') }}
where status not in ('failed', 'captured', 'refunded', 'authorized')
