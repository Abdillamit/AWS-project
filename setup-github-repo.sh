#!/bin/bash

set -e

echo "=========================================="
echo "Setup GitHub Repository"
echo "=========================================="
echo ""

# Проверка git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Инициализация git репозитория..."
    git init
    echo "✓ Git репозиторий инициализирован"
else
    echo "✓ Git репозиторий уже существует"
fi

echo ""

# Добавить remote
echo "Добавление GitHub remote..."
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/Abdillamit/AWS-project.git
echo "✓ Remote добавлен"

echo ""

# Создать .gitignore если нет
if [ ! -f .gitignore ]; then
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
package-lock.json

# Build outputs
dist/
build/
.cache/
public/
cdk.out/

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# AWS
awscliv2.zip
aws/

# Logs
*.log
npm-debug.log*
coverage/

# Credentials (ВАЖНО!)
AWS_CICD_CREDENTIALS.txt
*.pem
*.key
EOF
    echo "✓ .gitignore создан"
fi

echo ""

# Добавить все файлы
echo "Добавление файлов..."
git add .
echo "✓ Файлы добавлены"

echo ""

# Commit
echo "Создание commit..."
git commit -m "Initial commit: Full-stack AWS application with CDK, Lambda, and Gatsby" || echo "Commit уже существует"
echo "✓ Commit создан"

echo ""

# Создать ветку main если нужно
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Переименование ветки в main..."
    git branch -M main
    echo "✓ Ветка переименована в main"
fi

echo ""

# Push в GitHub
echo "Push в GitHub..."
git push -u origin main
echo "✓ Код загружен в GitHub"

echo ""

# Создать ветку beta
echo "Создание ветки beta..."
git checkout -b beta 2>/dev/null || git checkout beta
git push -u origin beta
echo "✓ Ветка beta создана и загружена"

echo ""

# Вернуться на main
git checkout main

echo ""
echo "=========================================="
echo "✅ GitHub репозиторий настроен!"
echo "=========================================="
echo ""
echo "Репозиторий: https://github.com/Abdillamit/AWS-project"
echo ""
echo "Ветки:"
echo "  - main (production)"
echo "  - beta (development)"
echo ""
echo "Следующий шаг: Запустите ./deploy-pipelines.sh"
echo ""
