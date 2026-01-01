# End-to-End Fintech Data Engineering Project

A comprehensive data engineering pipeline that orchestrates data ingestion, transformation, and analytics for fintech data using Apache Airflow, Snowflake, and DBT.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Data Flow](#data-flow)
- [Usage](#usage)
- [DAGs](#dags)
- [DBT Models](#dbt-models)
- [Database Schema](#database-schema)
- [Configuration](#configuration)
- [Contributing](#contributing)

## 🎯 Overview

This project implements a complete ETL/ELT pipeline for processing fintech data including:
- User information and KYC data
- Merchant details
- Payment events and transactions
- Chargeback records
- Foreign exchange rates
- Device fingerprinting data

The pipeline follows modern data engineering best practices with:
- **Orchestration**: Apache Airflow for workflow management
- **Data Warehouse**: Snowflake for scalable data storage
- **Transformation**: DBT for SQL-based transformations
- **Containerization**: Docker for easy deployment and development

## 🏗️ Architecture

```
┌─────────────┐
│   CSV Files │
│  (Data Dir) │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Apache Airflow │
│   (Orchestrator) │
└──────┬──────────┘
       │
       ├──────────────┐
       ▼              ▼
┌─────────────┐  ┌──────────┐
│  Snowflake  │  │   DBT    │
│   (Storage) │◄─┤(Transform)│
└─────────────┘  └──────────┘
       │
       ▼
┌─────────────┐
│   Analytics │
│    Layer    │
└─────────────┘
```

## 🛠️ Tech Stack

- **Apache Airflow 3.1.5**: Workflow orchestration and scheduling
- **Snowflake**: Cloud data warehouse
- **DBT (Data Build Tool)**: SQL-based data transformation
- **Docker & Docker Compose**: Containerization
- **PostgreSQL**: Airflow metadata database
- **Redis**: Celery message broker
- **Python**: DAG development

## 📁 Project Structure

```
End to End project/
├── Airflow/
│   ├── dags/                          # Airflow DAG definitions
│   │   ├── Snowflake_data_ingestion.py  # Data ingestion DAG
│   │   └── DBT_transformations.py       # DBT transformation DAG
│   ├── config/                        # Airflow configuration
│   ├── logs/                          # Airflow execution logs
│   ├── plugins/                       # Custom Airflow plugins
│   ├── docker-compose.yaml            # Docker Compose configuration
│   └── Dockerfile                     # Custom Airflow image with DBT
│
├── Snowflake/
│   └── migrations/                    # Database migration scripts
│       ├── V001__database_and_schemas.sql
│       ├── V002__file_formats.sql
│       ├── V003__stages.sql
│       ├── V004__audit_table.sql
│       └── V005__raw_tables.sql
│
├── DBT_fintech_project/               # DBT transformation project
│   ├── models/
│   │   ├── staging/                   # Staging layer models
│   │   └── marts/                     # Analytics/marts layer models
│   ├── tests/                         # Data quality tests
│   ├── macros/                        # DBT macros
│   └── dbt_project.yml                # DBT project configuration
│
└── Data Files/                        # Sample CSV data files
    ├── raw_users.csv
    ├── raw_merchants.csv
    ├── raw_payment_events_*.csv
    ├── raw_chargebacks_*.csv
    └── raw_fx_rates_*.csv
```

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker Desktop** (or Docker Engine + Docker Compose)
- **Snowflake Account** with appropriate permissions
- **Python 3.8+** (for local development)
- **DBT CLI** (optional, for local DBT development)
- **Git** (for version control)

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd "End to End project"
```

### 2. Configure Snowflake Connection

Create a `.env` file in the `Airflow/` directory with your Snowflake credentials:

```env
AIRFLOW_UID=50000
SNOWFLAKE_ACCOUNT=your_account
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=your_warehouse
SNOWFLAKE_DATABASE=FINTECH_DW
SNOWFLAKE_SCHEMA=RAW
```

### 3. Configure DBT Profile

Ensure your DBT profile is configured at `~/.dbt/profiles.yml`:

```yaml
fintech_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_account
      user: your_username
      password: your_password
      warehouse: your_warehouse
      database: FINTECH_DW
      schema: ANALYTICS
      threads: 4
```

### 4. Set Up Snowflake Database

Run the migration scripts in order:

```bash
# Connect to Snowflake and run migrations
# V001__database_and_schemas.sql
# V002__file_formats.sql
# V003__stages.sql
# V004__audit_table.sql
# V005__raw_tables.sql
```

### 5. Upload Data Files to Snowflake Stage

Upload your CSV files to the Snowflake stage:

```sql
PUT file:///path/to/Data Files/*.csv @FINTECH_DW.RAW.FINTECH_STAGE;
```

### 6. Start Airflow Services

Navigate to the Airflow directory and start the services:

```bash
cd Airflow
docker-compose up -d
```

### 7. Access Airflow UI

Open your browser and navigate to:
```
http://localhost:8080
```

Default credentials:
- Username: `airflow`
- Password: `airflow`

## 🔄 Data Flow

### 1. Data Ingestion (`fintech_raw_ingestion` DAG)

The ingestion DAG runs daily and loads data from CSV files in Snowflake stages into raw tables:

1. **Load Raw Users** → `RAW_USERS` table
2. **Load Raw Merchants** → `RAW_MERCHANTS` table
3. **Load Device Fingerprints** → `RAW_DEVICE_FINGERPRINTS` table
4. **Load Payment Events** → `RAW_PAYMENT_EVENTS` table (with date-based file naming)
5. **Load Chargebacks** → `RAW_CHARGEBACKS` table
6. **Load FX Rates** → `RAW_FX_RATES_DAILY` table

### 2. Data Transformation (`dbt_run` DAG)

The DBT DAG runs after ingestion and performs transformations:

1. **Staging Layer**: Cleans and standardizes raw data
   - `stg_raw_users`
   - `stg_raw_merchants`
   - `stg_raw_payment_events`
   - `stg_raw_chargebacks`
   - `stg_raw_device_fingerprints`

2. **Marts Layer**: Business logic and analytics
   - `mart_payment_kpis_daily`
   - `mart_chargeback_kpis_daily`
   - `mart_risk_signals_daily`

3. **Data Quality Tests**: Validates data integrity

## 📊 DAGs

### `fintech_raw_ingestion`

- **Schedule**: `@daily`
- **Catchup**: Enabled
- **Description**: Ingests raw CSV data from Snowflake stages into raw tables
- **Tasks**: Sequential loading of all raw data sources

### `dbt_run`

- **Schedule**: `@daily`
- **Catchup**: Disabled
- **Description**: Runs DBT transformations and tests
- **Tasks**:
  - `dbt_run`: Executes DBT models
  - `dbt_test`: Runs data quality tests

## 🗄️ Database Schema

### Raw Layer (`FINTECH_DW.RAW`)

- `RAW_USERS`: User information and KYC data
- `RAW_MERCHANTS`: Merchant details and categories
- `RAW_PAYMENT_EVENTS`: Payment transaction events
- `RAW_CHARGEBACKS`: Chargeback records
- `RAW_FX_RATES_DAILY`: Daily foreign exchange rates
- `RAW_DEVICE_FINGERPRINTS`: Device identification data

### Analytics Layer (`FINTECH_DW.ANALYTICS`)

- Staging models (prefixed with `stg_`)
- Mart models (prefixed with `mart_`)

## ⚙️ Configuration

### Airflow Configuration

- **Executor**: CeleryExecutor
- **Database**: PostgreSQL
- **Broker**: Redis
- **Web Server Port**: 8080
- **Logs**: Stored in `Airflow/logs/`

### DBT Configuration

- **Materialization Strategy**:
  - Staging: Incremental tables
  - Marts: Tables
- **Target**: Snowflake
- **Profile**: `fintech_project`

## 🧪 Testing

DBT tests are automatically run after model execution. Test files are located in:
- `DBT_fintech_project/tests/`

Run tests manually:
```bash
cd DBT_fintech_project
dbt test
```

## 📝 Development

### Adding New DAGs

1. Create a new Python file in `Airflow/dags/`
2. Define your DAG following Airflow best practices
3. The DAG will be automatically discovered by Airflow

### Adding New DBT Models

1. Create SQL files in `DBT_fintech_project/models/`
2. Organize by layer (staging, marts, intermediate)
3. Run `dbt run` to execute

### Modifying Database Schema

1. Create new migration files in `Snowflake/migrations/`
2. Follow naming convention: `V###__description.sql`
3. Run migrations in order

## 🔍 Monitoring

- **Airflow UI**: Monitor DAG runs, task logs, and execution history
- **Snowflake**: Query execution history and warehouse usage
- **DBT**: Check run results in `DBT_fintech_project/target/run_results.json`

## 🐛 Troubleshooting

### Airflow Issues

- Check logs: `Airflow/logs/`
- Verify Docker containers: `docker-compose ps`
- Restart services: `docker-compose restart`

### Snowflake Connection Issues

- Verify credentials in Airflow connections
- Check network connectivity
- Ensure warehouse is running

### DBT Issues

- Verify DBT profile configuration
- Check model compilation: `dbt compile`
- Review error logs in `DBT_fintech_project/logs/`

## 📚 Resources

- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Snowflake Documentation](https://docs.snowflake.com/)
- [DBT Documentation](https://docs.getdbt.com/)
- [Docker Documentation](https://docs.docker.com/)

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📄 License

[Specify your license here]

## 👤 Author

[Your Name/Organization]

---

**Note**: This is a development setup. For production deployments, ensure proper security configurations, secrets management, and resource allocation.

