#!/bin/bash

set -e

echo "=========================================="
echo "Deploy AWS CodePipeline"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

GITHUB_USERNAME="Abdillamit"
GITHUB_REPO="AWS-project"

echo -e "${GREEN}✓ GitHub username: $GITHUB_USERNAME${NC}"
echo -e "${GREEN}✓ GitHub repo: $GITHUB_REPO${NC}"
echo ""

# Проверка GitHub Token в Secrets Manager
echo -e "${BLUE}Шаг 1: Проверка GitHub Token${NC}"
echo ""

if aws secretsmanager describe-secret --secret-id GithubToken --region us-west-2 &>/dev/null; then
    echo -e "${GREEN}✓ GitHub Token найден в Secrets Manager${NC}"
else
    echo -e "${YELLOW}⚠ GitHub Token не найден в Secrets Manager${NC}"
    echo ""
    echo "Создайте Personal Access Token на GitHub:"
    echo "1. Откройте: https://github.com/settings/tokens/new"
    echo "2. Название: 'AWS CodePipeline'"
    echo "3. Expiration: 90 days (или больше)"
    echo "4. Права: repo (full control of private repositories)"
    echo "5. Создайте token и скопируйте его"
    echo ""
    read -sp "Введите GitHub Token: " GITHUB_TOKEN
    echo ""
    
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${RED}Ошибка: GitHub Token обязателен${NC}"
        exit 1
    fi
    
    aws secretsmanager create-secret \
        --name GithubToken \
        --description "GitHub Personal Access Token for CodePipeline" \
        --secret-string "$GITHUB_TOKEN" \
        --region us-west-2
    
    echo -e "${GREEN}✓ GitHub Token сохранен в Secrets Manager${NC}"
fi

echo ""

# Build
echo -e "${BLUE}Шаг 2: Сборка проекта${NC}"
echo ""
cd my-project-infrastructure
npm run build
echo -e "${GREEN}✓ Проект собран${NC}"
echo ""

# Deploy Beta Pipeline
echo -e "${BLUE}Шаг 3: Развертывание Beta Pipeline${NC}"
echo ""
echo "Деплою betaMyServicePipelineStack..."
cdk deploy betaMyServicePipelineStack --require-approval never

echo ""
echo -e "${GREEN}✓ Beta Pipeline развернут${NC}"
echo ""

# Deploy Prod Pipeline
echo -e "${BLUE}Шаг 4: Развертывание Production Pipeline${NC}"
echo ""
read -p "Развернуть Production Pipeline? (y/n): " DEPLOY_PROD

if [[ "$DEPLOY_PROD" == "y" || "$DEPLOY_PROD" == "Y" ]]; then
    echo ""
    echo "Деплою MyServicePipelineStack..."
    cdk deploy MyServicePipelineStack --context stage=prod --require-approval never
    echo ""
    echo -e "${GREEN}✓ Production Pipeline развернут${NC}"
fi

cd ..

echo ""
echo "=========================================="
echo -e "${GREEN}✅ Pipelines развернуты успешно!${NC}"
echo "=========================================="
echo ""

# Get pipeline URLs
BETA_PIPELINE_URL=$(aws cloudformation describe-stacks \
    --stack-name betaMyServicePipelineStack \
    --query 'Stacks[0].Outputs[?OutputKey==`PipelineUrl`].OutputValue' \
    --output text 2>/dev/null || echo "N/A")

if [[ "$DEPLOY_PROD" == "y" || "$DEPLOY_PROD" == "Y" ]]; then
    PROD_PIPELINE_URL=$(aws cloudformation describe-stacks \
        --stack-name MyServicePipelineStack \
        --query 'Stacks[0].Outputs[?OutputKey==`PipelineUrl`].OutputValue' \
        --output text 2>/dev/null || echo "N/A")
fi

echo "📋 Pipeline URLs:"
echo ""
echo "Beta Pipeline:"
echo "  $BETA_PIPELINE_URL"
echo ""

if [[ "$DEPLOY_PROD" == "y" || "$DEPLOY_PROD" == "Y" ]]; then
    echo "Production Pipeline:"
    echo "  $PROD_PIPELINE_URL"
    echo ""
fi

echo "🚀 Следующие шаги:"
echo ""
echo "1. Откройте AWS Console → CodePipeline"
echo "2. Вы увидите pipelines:"
echo "   - betaMyProject-Pipeline (для beta окружения)"
if [[ "$DEPLOY_PROD" == "y" || "$DEPLOY_PROD" == "Y" ]]; then
    echo "   - MyProject-Pipeline (для production окружения)"
fi
echo ""
echo "3. Создайте ветки в GitHub:"
echo "   git checkout -b beta"
echo "   git push origin beta"
echo "   git checkout main"
echo "   git push origin main"
echo ""
echo "4. Просмотр pipeline в консоли:"
echo "   https://console.aws.amazon.com/codesuite/codepipeline/pipelines"
echo ""
echo "5. Push код в GitHub для запуска pipeline:"
echo "   git push origin beta    # Запустит beta pipeline"
echo "   git push origin main    # Запустит production pipeline"
echo ""
