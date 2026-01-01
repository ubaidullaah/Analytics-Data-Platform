{% macro deduplicate(partition_by, order_by='src_loaded_at desc') %}
  {#
    Macro to add deduplication logic using QUALIFY and ROW_NUMBER.
    Commonly used in staging models to handle duplicate records.
    
    Args:
        partition_by: Column(s) to partition by (string for single column, or list for multiple columns)
        order_by: Order by clause for row_number (default: 'src_loaded_at desc')
    
    Usage:
        qualify {{ deduplicate('payment_event_id') }}
        qualify {{ deduplicate('chargeback_id', 'src_loaded_at desc, resolved_ts desc nulls last') }}
        qualify {{ deduplicate(['user_id', 'device_id'], 'last_seen_ts desc, first_seen_ts asc') }}
  #}
  
  row_number() over (
    partition by {% if partition_by is iterable and partition_by is not string %}{{ partition_by | join(', ') }}{% else %}{{ partition_by }}{% endif %}
    order by {{ order_by }}
  ) = 1
{% endmacro %}

