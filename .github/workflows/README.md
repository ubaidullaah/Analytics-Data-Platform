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
- **Runs against TEST schema** (industry best practice)
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
- **Pre-deployment:** Runs DBT tests against **STAGING** schema (industry best practice)
- **Deployment:** Deploys to production (customize deployment commands)
- **Production:** DBT models run via Airflow DAG in ANALYTICS schema (scheduled)

## Industry Best Practices for DBT Testing

### ✅ Recommended Approach (What We Implement)

1. **CI Tests → TEST Schema**
   - Isolated test environment
   - Safe for experimentation
   - No risk to production data

2. **Pre-Deployment Tests → STAGING Schema**
   - Validates against realistic data
   - Final check before production
   - Catches issues early

3. **Production Runs → ANALYTICS Schema**
   - Handled by Airflow (scheduled)
   - Not run in CI/CD
   - Production data integrity maintained

### ❌ What We DON'T Do (Anti-Patterns)

- ❌ **Never test directly against production in CI/CD**
  - Risk of data corruption
  - Performance impact on production
  - Can block deployments unnecessarily

- ❌ **Never run full DBT runs in CI**
  - Too slow/expensive
  - Unnecessary for validation

### 📊 Environment Strategy

```
┌─────────────┐
│   CI/CD     │
│             │
│  TEST Schema│ ← Fast, isolated tests
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Deployment │
│             │
│ STAGING     │ ← Pre-production validation
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Production │
│             │
│ ANALYTICS   │ ← Airflow runs DBT (scheduled)
└─────────────┘
```

## Setting Up Test Environment

### Option 1: Snowflake Zero-Copy Cloning (Recommended - No Data Insertion!)

**Best approach** - Uses Snowflake's zero-copy cloning (no storage cost, instant):

```sql
-- Clone the entire RAW schema (zero storage cost)
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.TEST_RAW 
  CLONE FINTECH_DW.RAW;

-- Clone ANALYTICS schema for testing
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.TEST 
  CLONE FINTECH_DW.ANALYTICS;

-- Or clone specific tables
CREATE TABLE FINTECH_DW.TEST_RAW.RAW_USERS 
  CLONE FINTECH_DW.RAW.RAW_USERS;
```

**Benefits:**
- ✅ **No data insertion needed** - instant clone
- ✅ **Zero storage cost** - only metadata stored
- ✅ **Always up-to-date** - can refresh before tests
- ✅ **Industry standard** - used by most companies

### Option 2: Subset of Production Data

If cloning isn't available, use a small subset:

```sql
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.TEST_RAW;
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.TEST;

-- Copy sample data (last 30 days, for example)
CREATE TABLE FINTECH_DW.TEST_RAW.RAW_USERS AS
SELECT * FROM FINTECH_DW.RAW.RAW_USERS 
WHERE created_at >= DATEADD(day, -30, CURRENT_DATE());
```

### Option 3: Skip CI Tests (Simplest)

If you don't want to set up test environment:
- DBT tests in CI will be skipped (non-blocking)
- Only syntax validation runs (no connection needed)
- Tests run only in staging before deployment

**Update DBT profile to use cloned schemas:**

```yaml
# In your DBT profile or via secrets
test:
  schema: TEST
  # Sources will need to point to TEST_RAW schema
```

## Required Secrets

### For DBT Testing (Optional)

**Test Environment (CI):**
- `SNOWFLAKE_ACCOUNT` - Snowflake account
- `SNOWFLAKE_USER` - Snowflake username  
- `SNOWFLAKE_PASSWORD` - Snowflake password
- `SNOWFLAKE_WAREHOUSE` - Snowflake warehouse
- `SNOWFLAKE_DATABASE` - Database name (default: FINTECH_DW)
- `SNOWFLAKE_TEST_SCHEMA` - Test schema (default: TEST)

**Staging Environment (Deployment):**
- `SNOWFLAKE_STAGING_SCHEMA` - Staging schema (default: STAGING)
- (Uses same account/user/password/warehouse as test)

**Note:** Workflows will skip DBT tests if secrets are not configured.

## Setup Instructions

### Quick Setup with Cloning (Recommended)

```sql
-- 1. Clone RAW schema for test sources
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.TEST_RAW 
  CLONE FINTECH_DW.RAW;

-- 2. Create empty TEST schema for DBT models
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.TEST;

-- 3. Update DBT sources.yml to use TEST_RAW in test environment
-- (or use dbt's source override feature)
```

### Alternative: Use Staging for Both

If you only want one test environment:

```sql
-- Use STAGING for both CI and pre-deployment tests
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.STAGING_RAW 
  CLONE FINTECH_DW.RAW;
CREATE SCHEMA IF NOT EXISTS FINTECH_DW.STAGING;
```

Then set both `SNOWFLAKE_TEST_SCHEMA` and `SNOWFLAKE_STAGING_SCHEMA` to `STAGING`.

## Usage

### Trigger DBT Tests in CI
Add `[run-dbt-tests]` to your commit message:
```bash
git commit -m "Update DBT models [run-dbt-tests]"
```

### Manual Deployment
Go to Actions → Deploy → Run workflow

## Why This Approach?

### ✅ Benefits
- **Safety**: No risk to production data
- **Speed**: Fast CI with isolated test environment
- **Reliability**: Staging validation before production
- **Cost-effective**: Zero-copy cloning = no storage cost
- **Industry Standard**: Follows dbt Labs recommendations

### 📚 References
- [dbt Labs: Modern Deployment Strategies](https://www.getdbt.com/blog/modern-deployment-strategies-for-analytics-workflows)
- [Snowflake Zero-Copy Cloning](https://docs.snowflake.com/en/user-guide/object-clone)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
