-- Test to ensure that payment_event_id is unique
select 
    payment_event_id
from {{ ref('stg_raw_payment_events') }}
group by payment_event_id
having count(*) > 1

