# Use the official Apache Airflow image as a base
FROM apache/airflow:3.1.5

# Switch to root user to install dbt
USER root

# Install dependencies
RUN apt-get update && apt-get install -y sudo python3-venv

# Create a virtual environment and install dbt
RUN python3 -m venv /opt/airflow/venv \
    && /opt/airflow/venv/bin/pip install --no-cache-dir dbt-snowflake

# Make sure the virtual environment is activated when airflow runs
ENV PATH="/opt/airflow/venv/bin:$PATH"

# Switch back to the airflow user
USER airflow