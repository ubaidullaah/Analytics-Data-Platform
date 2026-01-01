-- Test to ensure that the status is one of the accepted values
select 
    distinct status
from {{ ref('stg_raw_payment_events') }}
where status not in ('failed', 'captured', 'refunded', 'authorized')

