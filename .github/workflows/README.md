# CI/CD Workflows Documentation

This directory contains GitHub Actions workflows for continuous integration and deployment of the Fintech Data Engineering project.

## Workflows Overview

### 1. CI - Code Quality & Testing (`ci.yml`)
**Triggers:** Push/PR to `main` or `develop` branches

**Jobs:**
- **lint-python**: Runs Black, isort, Flake8, and Pylint on Python code
- **validate-airflow-dags**: Validates Airflow DAG syntax and structure
- **lint-sql**: Lints SQL files using SQLFluff
- **test-dbt-compile**: Compiles DBT models to check for syntax errors
- **check-yaml**: Validates YAML configuration files
- **check-dockerfile**: Validates Dockerfile syntax using Hadolint
- **security-scan**: Runs Trivy vulnerability scanner
- **summary**: Provides a summary of all CI checks

### 2. DBT - Test & Validate (`dbt-ci.yml`)
**Triggers:** 
- Push/PR to `main` or `develop` when DBT files change
- Manual workflow dispatch

**Jobs:**
- **dbt-test**: Compiles, validates, and tests DBT models
- **dbt-lint**: Lints DBT SQL models using SQLFluff

### 3. Docker Build & Test (`docker-build.yml`)
**Triggers:**
- Push/PR to `main` or `develop` when Docker files change
- Manual workflow dispatch

**Jobs:**
- **build-and-test**: Builds Docker image, tests it, and scans for vulnerabilities
- **test-docker-compose**: Validates docker-compose.yaml configuration

### 4. Security Scanning (`security-scan.yml`)
**Triggers:**
- Push/PR to `main` or `develop`
- Weekly schedule (Mondays at 00:00 UTC)
- Manual workflow dispatch

**Jobs:**
- **dependency-scan**: Scans Python dependencies for vulnerabilities
- **code-scan**: Runs Bandit security linter on Python code
- **secret-scan**: Scans for exposed secrets using Gitleaks and TruffleHog
- **container-scan**: Scans Docker images for vulnerabilities

### 5. Deploy (`deploy.yml`)
**Triggers:**
- Push to `main` branch
- Manual workflow dispatch with environment selection

**Jobs:**
- **pre-deployment-checks**: Determines deployment environment
- **run-tests**: Runs all CI checks before deployment
- **build-production-image**: Builds production-ready Docker image
- **deploy-staging**: Deploys to staging environment
- **deploy-production**: Deploys to production environment
- **rollback**: Handles rollback on deployment failure

## Required Secrets

Configure the following secrets in your GitHub repository settings:

### For DBT Testing (Optional - uses test values if not set)
- `SNOWFLAKE_ACCOUNT`: Snowflake account identifier
- `SNOWFLAKE_USER`: Snowflake username
- `SNOWFLAKE_PASSWORD`: Snowflake password
- `SNOWFLAKE_WAREHOUSE`: Snowflake warehouse name
- `SNOWFLAKE_DATABASE`: Snowflake database name
- `SNOWFLAKE_SCHEMA`: Snowflake schema name

### For Deployment
- Configure environment-specific secrets in GitHub Environments:
  - `staging`: Staging environment secrets
  - `production`: Production environment secrets

## Environment Protection Rules

It's recommended to set up protection rules for production deployments:

1. Go to Settings → Environments → Production
2. Enable "Required reviewers" (at least 1)
3. Enable "Wait timer" (optional, e.g., 5 minutes)
4. Add deployment branches restriction (only `main`)

## Workflow Best Practices

### Branch Strategy
- `develop`: Development branch (runs CI checks)
- `main`: Production branch (runs CI + CD)

### Pull Request Process
1. Create feature branch from `develop`
2. Make changes and push
3. CI workflows run automatically
4. Create PR to `develop` or `main`
5. All CI checks must pass before merge
6. Code review required

### Deployment Process
1. Merge to `main` triggers automatic deployment to production
2. Manual deployments can be triggered via workflow dispatch
3. Staging deployments can be tested before production

## Monitoring Workflows

### View Workflow Runs
- Go to Actions tab in GitHub
- Filter by workflow name
- View logs and artifacts

### Workflow Artifacts
- DBT artifacts: Available for 7 days
- Security scan results: Available for 30 days
- Docker images: Stored in GitHub Container Registry

## Troubleshooting

### Common Issues

1. **DBT compilation fails**
   - Check DBT profile configuration
   - Verify Snowflake credentials (if using real connection)
   - Review DBT model syntax

2. **Docker build fails**
   - Check Dockerfile syntax
   - Verify base image availability
   - Review build logs for specific errors

3. **Security scans fail**
   - Review vulnerability reports
   - Update dependencies if needed
   - Check for false positives

4. **Deployment fails**
   - Check environment secrets
   - Verify deployment permissions
   - Review deployment logs

## Customization

### Adding New Checks
1. Create a new job in the appropriate workflow
2. Add it to the `needs` list of dependent jobs
3. Update the summary job if needed

### Modifying Deployment
1. Edit `deploy.yml`
2. Update deployment commands in deploy jobs
3. Add environment-specific configurations

### Adding New Environments
1. Add environment to `deploy.yml` workflow
2. Create GitHub Environment with secrets
3. Add deployment job for new environment

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Airflow Documentation](https://airflow.apache.org/docs/)
- [DBT Documentation](https://docs.getdbt.com/)
- [Docker Documentation](https://docs.docker.com/)

