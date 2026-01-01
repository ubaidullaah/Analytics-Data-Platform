from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

# Define the DAG
default_args = {
    'owner': 'airflow',
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
    'catchup': False,
}

dag = DAG(
    'dbt_run',
    default_args=default_args,
    description='Run dbt models locally with Airflow',
    schedule='@daily',  # Runs daily
    catchup=False,
)

# Task to run dbt models locally
run_dbt = BashOperator(
    task_id='dbt_run',
    bash_command='cd $MY_DBT_PROJECT &&  dbt clean && dbt run', # Change directory to mounted dbt project and run dbt
    dag=dag,
)

# Task to run dbt tests locally
run_dbt_tests = BashOperator(
    task_id='dbt_test',
    bash_command='cd $MY_DBT_PROJECT && dbt test',  # Change directory and run dbt tests
    dag=dag,
)

run_dbt >> run_dbt_tests
