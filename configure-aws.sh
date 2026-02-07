#!/bin/bash

echo "=========================================="
echo "AWS CLI Configuration"
echo "=========================================="
echo ""
echo "⚠️  ВАЖНО: Ваши учетные данные будут сохранены локально"
echo "   и НЕ будут видны в истории команд"
echo ""

# Configure AWS CLI interactively
aws configure

echo ""
echo "=========================================="
echo "Проверка конфигурации..."
echo "=========================================="

# Test configuration
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo ""
    echo "✅ AWS CLI настроен успешно!"
    echo ""
    aws sts get-caller-identity
    echo ""
else
    echo ""
    echo "❌ Ошибка настройки AWS CLI"
    echo "Пожалуйста, проверьте ваши учетные данные"
    echo ""
    exit 1
fi
