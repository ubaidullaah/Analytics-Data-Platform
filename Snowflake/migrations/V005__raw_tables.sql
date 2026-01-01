CREATE OR REPLACE TABLE FINTECH_DW.RAW.RAW_USERS (
  user_id STRING,
  created_at TIMESTAMP_TZ,
  country STRING,
  kyc_level STRING,
  marketing_channel STRING
);

CREATE OR REPLACE TABLE FINTECH_DW.RAW.RAW_MERCHANTS (
  merchant_id STRING,
  merchant_name STRING,
  merchant_category STRING,
  country STRING
);

CREATE OR REPLACE TABLE FINTECH_DW.RAW.RAW_DEVICE_FINGERPRINTS (
  user_id STRING,
  device_id STRING,
  first_seen_ts TIMESTAMP_TZ,
  last_seen_ts TIMESTAMP_TZ,
  ip_address STRING
);

CREATE OR REPLACE TABLE FINTECH_DW.RAW.RAW_PAYMENT_EVENTS (
  payment_event_id STRING,
  payment_id STRING,
  user_id STRING,
  merchant_id STRING,
  amount NUMBER(18,2),
  currency STRING,
  event_ts TIMESTAMP_TZ,
  status STRING,
  failure_reason STRING,
  payment_method STRING,
  attempt_number NUMBER(9,0),
  src_file_name STRING,
  src_loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FINTECH_DW.RAW.RAW_CHARGEBACKS (
  chargeback_id STRING,
  payment_id STRING,
  opened_ts TIMESTAMP_TZ,
  resolved_ts TIMESTAMP_TZ,
  outcome STRING,
  src_file_name STRING,
  src_loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE FINTECH_DW.RAW.RAW_FX_RATES_DAILY (
  date DATE,
  currency STRING,
  rate_to_usd NUMBER(18,6),
  src_file_name STRING,
  src_loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);
