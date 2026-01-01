from airflow import DAG
from datetime import datetime, timedelta
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

with DAG(
    dag_id="fintech_raw_ingestion",
    start_date=datetime.now() - timedelta(days=1),
    schedule="@daily",
    catchup=True,
) as dag:

    load_raw_users = SQLExecuteQueryOperator(
        task_id="load_raw_users",
        conn_id="snowflake_default",
        sql="""
        COPY INTO FINTECH_DW.RAW.RAW_USERS
        FROM @FINTECH_DW.RAW.FINTECH_STAGE/raw_users.csv
        FILE_FORMAT = (FORMAT_NAME = FINTECH_DW.RAW.CSV_FF);
        """,
    )

    # -------------------------
    # Load RAW_MERCHANTS
    # -------------------------
    load_raw_merchants = SQLExecuteQueryOperator(
        task_id="load_raw_merchants",
        conn_id="snowflake_default",
        sql="""
        COPY INTO FINTECH_DW.RAW.RAW_MERCHANTS
        FROM @FINTECH_DW.RAW.FINTECH_STAGE/raw_merchants.csv
        FILE_FORMAT = (FORMAT_NAME = FINTECH_DW.RAW.CSV_FF);
        """,
    )

    # -------------------------
    # Load RAW_DEVICE_FINGERPRINTS
    # -------------------------
    load_raw_device_fingerprints = SQLExecuteQueryOperator(
        task_id="load_raw_device_fingerprints",
        conn_id="snowflake_default",
        sql="""
        COPY INTO FINTECH_DW.RAW.RAW_DEVICE_FINGERPRINTS
        FROM @FINTECH_DW.RAW.FINTECH_STAGE/raw_device_fingerprints.csv
        FILE_FORMAT = (FORMAT_NAME = FINTECH_DW.RAW.CSV_FF);
        """,
    )

    # -------------------------
    # Load RAW_PAYMENT_EVENTS (example with dated file)
    # -------------------------
    load_raw_payment_events = SQLExecuteQueryOperator(
        task_id="load_raw_payment_events",
        conn_id="snowflake_default",
        sql="""
        INSERT INTO FINTECH_DW.RAW.RAW_PAYMENT_EVENTS (
          payment_event_id,
          payment_id,
          user_id,
          merchant_id,
          amount,
          currency,
          event_ts,
          status,
          failure_reason,
          payment_method,
          attempt_number,
          src_file_name
        )
        SELECT
          t.$1,
          t.$2,
          t.$3,
          t.$4,
          t.$5::NUMBER(18,2),
          t.$6,
          t.$7::TIMESTAMP_TZ,
          t.$8,
          NULLIF(t.$9,''),
          t.$10,
          t.$11::NUMBER,
          'raw_payment_events_{{ ds }}.csv'
        FROM @FINTECH_DW.RAW.FINTECH_STAGE/raw_payment_events_{{ ds }}.csv t;
        """,
    )

    # -------------------------
    # Load RAW_CHARGEBACKS
    # -------------------------
    load_raw_chargebacks = SQLExecuteQueryOperator(
        task_id="load_raw_chargebacks",
        conn_id="snowflake_default",
        sql="""
        INSERT INTO FINTECH_DW.RAW.RAW_CHARGEBACKS (
          chargeback_id,
          payment_id,
          opened_ts,
          resolved_ts,
          outcome,
          src_file_name
        )
        SELECT
          t.$1,
          t.$2,
          t.$3::TIMESTAMP_TZ,
          NULLIF(t.$4,'')::TIMESTAMP_TZ,
          t.$5,
          'raw_chargebacks_{{ ds }}.csv'
        FROM @FINTECH_DW.RAW.FINTECH_STAGE/raw_chargebacks_{{ ds }}.csv t;
        """,
    )

    # -------------------------
    # Load RAW_FX_RATES_DAILY
    # -------------------------
    load_raw_fx_rates = SQLExecuteQueryOperator(
        task_id="load_raw_fx_rates_daily",
        conn_id="snowflake_default",
        sql="""
        INSERT INTO FINTECH_DW.RAW.RAW_FX_RATES_DAILY (
          date,
          currency,
          rate_to_usd,
          src_file_name
        )
        SELECT
          t.$1::DATE,
          t.$2,
          t.$3::NUMBER(18,6),
          'raw_fx_rates_{{ ds }}.csv'
        FROM @FINTECH_DW.RAW.FINTECH_STAGE/raw_fx_rates_{{ ds }}.csv t;
        """,
    )

    # -------------------------
    # Task dependencies
    # -------------------------
    (
        load_raw_users
        >> load_raw_merchants
        >> load_raw_device_fingerprints
        >> load_raw_payment_events
        >> load_raw_chargebacks
        >> load_raw_fx_rates
    )
