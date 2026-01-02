# CI/CD Workflows

## Workflows Overview

### 1. CI (`ci.yml`)
**Runs on:** Push/PR to `main` or `develop`

**What it does:**
- ✅ Validates Python syntax
- ✅ Validates Airflow DAGs load correctly
- ✅ Validates DBT project structure (YAML)
- ✅ Installs DBT packages (`dbt deps`)
- ✅ Parses DBT models (syntax check, no connection needed)

**DBT Test Job (Optional):**
- Runs DBT tests if:
  - It's a pull request, OR
  - Commit message contains `[run-dbt-tests]`
- Requires Snowflake test environment secrets
- Skips if secrets not configured

### 2. Docker Build (`docker-build.yml`)
**Runs on:** Push to `main` when Dockerfile changes

**What it does:**
- Builds and pushes Docker image to GitHub Container Registry
- Image includes DBT (installed in Dockerfile)

### 3. Deploy (`deploy.yml`)
**Runs on:** Push to `main` or manual trigger

**What it does:**
- **Pre-deployment:** Runs DBT tests against staging environment
- **Deployment:** Deploys to production (customize deployment commands)
- DBT models run via Airflow after deployment

## DBT Best Practices Implemented

### ✅ In CI (Fast, No Connection Required)
1. **Syntax Validation** - `dbt parse` validates SQL syntax
2. **Package Validation** - `dbt deps` ensures packages are valid
3. **Project Structure** - Validates `dbt_project.yml`

### ✅ In CI (Optional, Requires Test DB)
4. **DBT Tests** - Run data quality tests against test environment
   - Only runs on PRs or when explicitly requested
   - Requires Snowflake test credentials

### ✅ In Deployment
5. **Pre-deployment Tests** - Run DBT tests against staging
6. **Production Runs** - Handled by Airflow DAG (scheduled)

## Required Secrets

### For DBT Testing (Optional)
- `SNOWFLAKE_ACCOUNT` - Snowflake account
- `SNOWFLAKE_USER` - Snowflake username  
- `SNOWFLAKE_PASSWORD` - Snowflake password
- `SNOWFLAKE_WAREHOUSE` - Snowflake warehouse
- `SNOWFLAKE_DATABASE` - Database name (default: FINTECH_DW)
- `SNOWFLAKE_TEST_SCHEMA` - Test schema (default: TEST)
- `SNOWFLAKE_STAGING_SCHEMA` - Staging schema (default: STAGING)

**Note:** Workflows will skip DBT tests if secrets are not configured.

## Industry Best Practices

### ✅ What We Do
- **Fast CI checks** - Syntax validation without connection
- **Optional test runs** - Only when needed/requested
- **Staging validation** - Test before production
- **Separation of concerns** - CI validates, Airflow runs

### ✅ What We Don't Do (By Design)
- ❌ Full DBT run in CI (too slow/expensive)
- ❌ Production DBT runs in CI/CD (handled by Airflow)
- ❌ Blocking on test DB availability (optional)

## Usage

### Trigger DBT Tests in CI
Add `[run-dbt-tests]` to your commit message:
```bash
git commit -m "Update DBT models [run-dbt-tests]"
```

### Manual Deployment
Go to Actions → Deploy → Run workflow

## Customization

Edit the workflows to match your deployment process:
- Update deployment commands in `deploy.yml`
- Adjust DBT test conditions in `ci.yml`
- Modify environment schemas as needed
