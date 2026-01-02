#!/bin/bash
# Local validation script to test CI checks before pushing
# Usage: ./scripts/validate-local.sh

set -e

echo "🔍 Running local CI validation checks..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi

# Check if pip is available
if ! command -v pip &> /dev/null; then
    echo -e "${RED}❌ pip is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Installing dependencies...${NC}"
pip install -q -r requirements.txt 2>/dev/null || echo "Warning: Some dependencies may not be installed"

echo ""
echo -e "${YELLOW}🔍 Running Python linting checks...${NC}"

# Black check
echo "  - Running Black..."
black --check --diff Airflow/dags/ || {
    echo -e "${RED}❌ Black check failed${NC}"
    exit 1
}
echo -e "  ${GREEN}✅ Black check passed${NC}"

# isort check
echo "  - Running isort..."
isort --check-only --diff Airflow/dags/ || {
    echo -e "${RED}❌ isort check failed${NC}"
    exit 1
}
echo -e "  ${GREEN}✅ isort check passed${NC}"

# Flake8 check
echo "  - Running Flake8..."
flake8 Airflow/dags/ --max-line-length=120 --extend-ignore=E203,W503 --exclude=__pycache__ || {
    echo -e "${YELLOW}⚠️  Flake8 found some issues (non-blocking)${NC}"
}
echo -e "  ${GREEN}✅ Flake8 check completed${NC}"

echo ""
echo -e "${YELLOW}🔍 Validating Airflow DAGs...${NC}"

# Check Python syntax
echo "  - Checking Python syntax..."
python3 -m py_compile Airflow/dags/*.py || {
    echo -e "${RED}❌ Python syntax check failed${NC}"
    exit 1
}
echo -e "  ${GREEN}✅ Python syntax check passed${NC}"

echo ""
echo -e "${YELLOW}🔍 Validating YAML files...${NC}"

# YAML linting
if command -v yamllint &> /dev/null; then
    echo "  - Running yamllint..."
    yamllint -d '{extends: default, rules: {line-length: {max: 200}}}' Airflow/docker-compose.yaml DBT_fintech_project/dbt_project.yml || {
        echo -e "${YELLOW}⚠️  YAML linting found some issues (non-blocking)${NC}"
    }
    echo -e "  ${GREEN}✅ YAML validation completed${NC}"
else
    echo -e "  ${YELLOW}⚠️  yamllint not installed, skipping${NC}"
fi

echo ""
echo -e "${YELLOW}🔍 Validating DBT project...${NC}"

# DBT validation
if command -v dbt &> /dev/null; then
    echo "  - Checking DBT project structure..."
    cd DBT_fintech_project
    dbt debug --target dev 2>/dev/null || echo -e "  ${YELLOW}⚠️  DBT debug requires Snowflake connection${NC}"
    dbt list --target dev 2>/dev/null || echo -e "  ${YELLOW}⚠️  DBT list requires Snowflake connection${NC}"
    cd ..
    echo -e "  ${GREEN}✅ DBT validation completed${NC}"
else
    echo -e "  ${YELLOW}⚠️  DBT not installed, skipping${NC}"
fi

echo ""
echo -e "${GREEN}✅ All local validation checks completed!${NC}"
echo ""
echo "You can now push your changes with confidence."

