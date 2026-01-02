# CI/CD Setup Guide

This guide will help you set up and configure the CI/CD pipeline for this project.

## Prerequisites

1. GitHub repository with Actions enabled
2. Admin access to repository settings
3. Access to deployment environments (if applicable)

## Initial Setup

### 1. Enable GitHub Actions

GitHub Actions should be enabled by default. Verify in:
- Repository Settings → Actions → General
- Ensure "Allow all actions and reusable workflows" is selected

### 2. Configure Repository Secrets

Go to **Settings → Secrets and variables → Actions → New repository secret**

#### Required Secrets for DBT (Optional - workflows use test values if not set)
- `SNOWFLAKE_ACCOUNT`: Your Snowflake account identifier
- `SNOWFLAKE_USER`: Snowflake username
- `SNOWFLAKE_PASSWORD`: Snowflake password
- `SNOWFLAKE_WAREHOUSE`: Snowflake warehouse name
- `SNOWFLAKE_DATABASE`: Snowflake database name (default: FINTECH_DW)
- `SNOWFLAKE_SCHEMA`: Snowflake schema name (default: ANALYTICS)

### 3. Configure GitHub Environments

For deployment workflows, set up environments:

1. Go to **Settings → Environments**
2. Create environments: `staging` and `production`

#### Staging Environment
- **Environment name**: `staging`
- **Deployment branches**: `develop` (optional)
- **Environment secrets**: Add staging-specific secrets if needed

#### Production Environment
- **Environment name**: `production`
- **Deployment branches**: `main` only
- **Required reviewers**: Enable and add at least 1 reviewer
- **Wait timer**: Optional (recommended: 5 minutes)
- **Environment secrets**: Add production-specific secrets

### 4. Configure GitHub Container Registry

The Docker build workflow automatically pushes to GitHub Container Registry (ghcr.io).

1. Go to **Settings → Actions → General**
2. Under "Workflow permissions", select "Read and write permissions"
3. Enable "Allow GitHub Actions to create and approve pull requests"

### 5. Enable Dependabot (Optional)

Dependabot is configured via `.github/dependabot.yml`. To enable:

1. Go to **Settings → Code security and analysis**
2. Enable "Dependabot alerts"
3. Enable "Dependabot security updates"

## Workflow Configuration

### Branch Protection Rules

Set up branch protection for `main`:

1. Go to **Settings → Branches**
2. Add rule for `main` branch:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1 reviewer)
   - ✅ Require status checks to pass before merging
     - Select: `CI - Code Quality & Testing`
     - Select: `DBT - Test & Validate`
     - Select: `Docker Build & Test`
   - ✅ Require branches to be up to date before merging
   - ✅ Do not allow bypassing the above settings

### Workflow Permissions

All workflows use the default `GITHUB_TOKEN`. For production deployments, consider:

1. Creating a Personal Access Token (PAT) or GitHub App
2. Storing it as a repository secret
3. Using it in workflows that need elevated permissions

## Testing the Setup

### 1. Test CI Workflow

Create a test branch and push:

```bash
git checkout -b test-ci-setup
git push origin test-ci-setup
```

Create a PR to `develop` or `main` and verify:
- ✅ All CI checks run
- ✅ No errors in workflow logs
- ✅ Status checks appear on PR

### 2. Test DBT Workflow

Modify a DBT file and push:

```bash
# Make a small change to a DBT model
echo "-- Test comment" >> DBT_fintech_project/models/staging/stg_raw_users.sql
git add .
git commit -m "test: trigger DBT workflow"
git push
```

Verify the DBT workflow runs.

### 3. Test Docker Build

Modify Dockerfile and push:

```bash
# Make a small change
echo "# Test comment" >> Airflow/Dockerfile
git add .
git commit -m "test: trigger Docker build"
git push
```

Verify the Docker build workflow runs and image is pushed to ghcr.io.

### 4. Test Security Scanning

The security scan runs automatically on push/PR. Verify:
- ✅ Trivy scans complete
- ✅ Security alerts appear in Security tab (if vulnerabilities found)

## Deployment Configuration

### Staging Deployment

Staging deployments can be triggered:
- Automatically on push to `main` (if configured)
- Manually via workflow dispatch

### Production Deployment

Production deployments:
- Automatically trigger on push to `main`
- Require manual approval (if environment protection enabled)
- Can be triggered manually via workflow dispatch

### Customizing Deployment

Edit `.github/workflows/deploy.yml` to add your deployment commands:

```yaml
- name: Deploy to production
  run: |
    # Add your deployment commands here
    # Example: kubectl, terraform, ansible, etc.
```

## Monitoring and Maintenance

### Viewing Workflow Runs

1. Go to **Actions** tab
2. Select workflow from left sidebar
3. Click on a run to see details
4. Download artifacts if needed

### Workflow Status Badge

Add to your README.md:

```markdown
![CI](https://github.com/your-org/your-repo/workflows/CI%20-%20Code%20Quality%20%26%20Testing/badge.svg)
```

### Regular Maintenance

1. **Weekly**: Review security scan results
2. **Monthly**: Review and update dependencies
3. **Quarterly**: Review and optimize workflow performance

## Troubleshooting

### Workflows Not Running

1. Check Actions are enabled: **Settings → Actions → General**
2. Verify workflow files are in `.github/workflows/`
3. Check workflow syntax: **Actions → Workflow → View workflow file**

### CI Checks Failing

1. Review workflow logs for specific errors
2. Test locally with the same tools (black, flake8, etc.)
3. Check Python version compatibility

### Docker Build Failing

1. Test Dockerfile locally: `docker build -t test ./Airflow`
2. Check base image availability
3. Review build logs for specific errors

### Deployment Failing

1. Verify environment secrets are set
2. Check deployment permissions
3. Review deployment logs
4. Test deployment commands manually

### DBT Tests Failing

1. Verify DBT profile configuration
2. Check Snowflake connection (if using real credentials)
3. Test DBT commands locally
4. Review DBT compilation errors

## Best Practices

1. **Never commit secrets**: Use GitHub Secrets
2. **Review PRs carefully**: All checks must pass
3. **Test locally first**: Run linters and tests before pushing
4. **Monitor workflows**: Check for failures regularly
5. **Keep dependencies updated**: Use Dependabot
6. **Document changes**: Update workflows documentation

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

## Support

For issues or questions:
1. Check workflow logs
2. Review this documentation
3. Check GitHub Actions status page
4. Create an issue in the repository

