CREATE OR REPLACE TABLE FINTECH_DW.RAW.LOAD_AUDIT (
  source_table      STRING,
  file_name         STRING,
  loaded_at         TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  row_count_loaded  NUMBER
);
