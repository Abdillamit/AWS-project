# 🚀 GitHub CI/CD - Быстрый старт

## Шаг 1: Создать репозиторий на GitHub

1. Перейдите на https://github.com/new
2. Название: `my-project`
3. Описание: `Full-stack AWS application with CI/CD`
4. Visibility: Private (рекомендуется)
5. **НЕ** добавляйте README, .gitignore, или license
6. Нажмите "Create repository"

## Шаг 2: Push кода в GitHub

```bash
# Добавить remote (замените YOUR_USERNAME на ваш username)
git remote add origin https://github.com/YOUR_USERNAME/my-project.git

# Push в main
git push -u origin main

# Создать и push beta ветку
git checkout -b beta
git push -u origin beta

# Вернуться в main
git checkout main
```

## Шаг 3: Создать новые AWS ключи для CI/CD

⚠️ **ВАЖНО**: Создайте НОВЫЕ ключи, не используйте старые!

```bash
# Создать IAM пользователя
aws iam create-user --user-name github-actions-user

# Дать права администратора (для разработки)
aws iam attach-user-policy \
  --user-name github-actions-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Создать ключи
aws iam create-access-key --user-name github-actions-user
```

**Сохраните вывод!** Вам понадобятся:
- `AccessKeyId`
- `SecretAccessKey`

## Шаг 4: Добавить Secrets в GitHub

1. Откройте ваш репозиторий на GitHub
2. Перейдите: **Settings** → **Secrets and variables** → **Actions**
3. Нажмите **"New repository secret"**
4. Добавьте два секрета:

### Секрет 1:
- Name: `AWS_ACCESS_KEY_ID`
- Secret: `<ваш AccessKeyId из шага 3>`
- Нажмите "Add secret"

### Секрет 2:
- Name: `AWS_SECRET_ACCESS_KEY`
- Secret: `<ваш SecretAccessKey из шага 3>`
- Нажмите "Add secret"

## Шаг 5: Тест CI/CD

### Тест 1: Infrastructure

```bash
# Внести изменение
echo "# CI/CD Test" >> my-project-infrastructure/README.md

# Коммит и push
git add .
git commit -m "Test: Infrastructure CI/CD"
git push origin beta
```

### Проверка:
1. Откройте https://github.com/YOUR_USERNAME/my-project/actions
2. Вы должны увидеть workflow "Deploy Infrastructure" запущенным
3. Дождитесь завершения (зеленая галочка ✅)

### Тест 2: API

```bash
# Изменить сообщение в Lambda
# Отредактируйте my-project-api/src/handlers/hello.ts
# Измените "Hello from Lambda!" на "Hello from CI/CD!"

git add .
git commit -m "Test: API CI/CD"
git push origin beta
```

### Проверка:
1. Workflow "Deploy API" должен запуститься
2. После завершения, протестируйте API:

```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: da2-367r3wth5zbpbncwc2s7h3v454" \
  -d '{"query":"{ hello { message } }"}' \
  https://p3nmtl3odjgljb7zmglbwew3tq.appsync-api.us-west-2.amazonaws.com/graphql
```

### Тест 3: Web

```bash
# Изменить заголовок
# Отредактируйте my-project-web/src/pages/index.tsx
# Измените "Welcome to My Project" на "Welcome to CI/CD Project"

git add .
git commit -m "Test: Web CI/CD"
git push origin beta
```

### Проверка:
1. Workflow "Deploy Web" должен запуститься
2. После завершения, откройте:
   `http://beta-my-project-web.s3-website-us-west-2.amazonaws.com`

## ✅ Готово!

Теперь каждый push в `beta` или `main` будет автоматически деплоить изменения!

## 🌿 Workflow разработки

```bash
# 1. Создать feature ветку
git checkout beta
git checkout -b feature/my-feature

# 2. Внести изменения
# ... редактировать код ...

# 3. Коммит
git add .
git commit -m "Add my feature"

# 4. Push
git push origin feature/my-feature

# 5. Создать Pull Request на GitHub
# Beta ← feature/my-feature

# 6. После merge в beta - автоматический деплой в beta

# 7. Протестировать в beta

# 8. Создать PR в main для production
# Main ← beta

# 9. После merge в main - автоматический деплой в production
```

## 📊 Просмотр логов

### В GitHub:
1. Actions tab
2. Выберите workflow run
3. Кликните на job
4. Просмотрите логи каждого шага

### В AWS:
```bash
# Lambda логи
aws logs tail /aws/lambda/betaMyProject-Hello --follow

# CloudFormation события
aws cloudformation describe-stack-events \
  --stack-name betaMyServiceAPIStack \
  --max-items 10
```

## 🚨 Troubleshooting

### Workflow не запускается?
- Проверьте, что файлы в `.github/workflows/`
- Проверьте синтаксис YAML на https://www.yamllint.com/

### AWS credentials ошибка?
- Проверьте секреты: Settings → Secrets and variables → Actions
- Убедитесь, что имена точно `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY`

### Deploy fails?
- Проверьте логи в Actions tab
- Проверьте CloudFormation в AWS Console
- Убедитесь, что CDK bootstrap выполнен

## 📚 Дополнительная информация

Полное руководство: `GITHUB_CICD_SETUP.md`

## 🎉 Поздравляем!

Ваш CI/CD pipeline настроен и работает! 🚀
