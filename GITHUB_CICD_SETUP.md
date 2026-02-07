# GitHub CI/CD Setup Guide

Полное руководство по настройке автоматического развертывания через GitHub Actions.

## 📋 Предварительные требования

- [x] AWS аккаунт настроен
- [x] Инфраструктура развернута вручную хотя бы один раз
- [x] GitHub аккаунт
- [ ] GitHub репозитории созданы
- [ ] AWS credentials добавлены в GitHub Secrets

## 🚀 Шаг 1: Создание GitHub репозиториев

### Вариант A: Один монорепозиторий (Рекомендуется)

```bash
# Инициализировать Git
git init

# Добавить все файлы
git add .

# Первый коммит
git commit -m "Initial commit: Full-stack AWS application"

# Создать репозиторий на GitHub
# Перейдите на https://github.com/new
# Создайте репозиторий с именем "my-project"

# Добавить remote
git remote add origin https://github.com/YOUR_USERNAME/my-project.git

# Push
git branch -M main
git push -u origin main

# Создать beta ветку
git checkout -b beta
git push -u origin beta
```

### Вариант B: Отдельные репозитории

Если вы хотите разделить проекты:

```bash
# Infrastructure
cd my-project-infrastructure
git init
git add .
git commit -m "Initial commit: Infrastructure"
git remote add origin https://github.com/YOUR_USERNAME/my-project-infrastructure.git
git push -u origin main

# API
cd ../my-project-api
git init
git add .
git commit -m "Initial commit: API"
git remote add origin https://github.com/YOUR_USERNAME/my-project-api.git
git push -u origin main

# Web
cd ../my-project-web
git init
git add .
git commit -m "Initial commit: Web"
git remote add origin https://github.com/YOUR_USERNAME/my-project-web.git
git push -u origin main
```

## 🔐 Шаг 2: Настройка GitHub Secrets

### 2.1 Создание новых AWS ключей (ВАЖНО!)

⚠️ **НЕ используйте ключи, которые были опубликованы в чате!**

```bash
# Создать нового IAM пользователя для CI/CD
aws iam create-user --user-name github-actions-user

# Прикрепить политику (для разработки - AdministratorAccess)
aws iam attach-user-policy \
  --user-name github-actions-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Создать ключи доступа
aws iam create-access-key --user-name github-actions-user
```

Сохраните `AccessKeyId` и `SecretAccessKey`!

### 2.2 Добавление Secrets в GitHub

1. Перейдите в ваш репозиторий на GitHub
2. Settings → Secrets and variables → Actions
3. Нажмите "New repository secret"
4. Добавьте следующие секреты:

| Name | Value |
|------|-------|
| `AWS_ACCESS_KEY_ID` | Ваш новый Access Key ID |
| `AWS_SECRET_ACCESS_KEY` | Ваш новый Secret Access Key |

### 2.3 Проверка секретов

Секреты должны быть видны в:
`Settings → Secrets and variables → Actions → Repository secrets`

## 📁 Шаг 3: Структура Workflows

Созданные workflows:

### 1. `deploy-infrastructure.yml`
- **Триггер**: Push в `main` или `beta` ветки (изменения в `my-project-infrastructure/`)
- **Действия**:
  - Тестирует инфраструктуру
  - Деплоит CDK стеки
  - Выводит информацию о развертывании

### 2. `deploy-api.yml`
- **Триггер**: Push в `main` или `beta` ветки (изменения в `my-project-api/`)
- **Действия**:
  - Тестирует API
  - Собирает Lambda функции
  - Обновляет Lambda код

### 3. `deploy-web.yml`
- **Триггер**: Push в `main` или `beta` ветки (изменения в `my-project-web/`)
- **Действия**:
  - Тестирует фронтенд
  - Собирает Gatsby сайт
  - Деплоит в S3
  - Настраивает static website hosting

### 4. `pr-checks.yml`
- **Триггер**: Pull Request в `main` или `beta`
- **Действия**:
  - Запускает все тесты
  - Проверяет сборку
  - Не деплоит

## 🌿 Шаг 4: Стратегия веток

### Main (Production)
- Автоматически деплоится в **production**
- Требует review перед merge
- Защищена от прямых push

### Beta (Staging)
- Автоматически деплоится в **beta**
- Для тестирования перед production
- Можно делать прямые push

### Feature branches
- Создаются от `beta`
- Запускают только тесты (PR checks)
- Merge в `beta` через Pull Request

## 🔄 Шаг 5: Workflow развертывания

### Типичный процесс разработки:

```bash
# 1. Создать feature ветку
git checkout beta
git pull
git checkout -b feature/new-feature

# 2. Внести изменения
# ... редактировать код ...

# 3. Коммит и push
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# 4. Создать Pull Request на GitHub
# Beta ← feature/new-feature
# GitHub Actions запустит тесты

# 5. После review - merge в beta
# Автоматически задеплоится в beta окружение

# 6. Протестировать в beta
# Проверить https://beta-my-project-web.s3-website-us-west-2.amazonaws.com

# 7. Создать PR в main для production
# Main ← beta
# После merge - автоматически задеплоится в production
```

## 🧪 Шаг 6: Тестирование CI/CD

### 6.1 Тест Infrastructure

```bash
# Внести небольшое изменение
cd my-project-infrastructure
echo "# Test change" >> README.md

# Коммит и push
git add .
git commit -m "Test infrastructure CI/CD"
git push origin beta

# Проверить GitHub Actions
# https://github.com/YOUR_USERNAME/my-project/actions
```

### 6.2 Тест API

```bash
# Изменить Lambda функцию
cd my-project-api/src/handlers
# Отредактировать hello.ts

git add .
git commit -m "Update hello handler"
git push origin beta
```

### 6.3 Тест Web

```bash
# Изменить фронтенд
cd my-project-web/src/pages
# Отредактировать index.tsx

git add .
git commit -m "Update homepage"
git push origin beta
```

## 📊 Шаг 7: Мониторинг развертываний

### GitHub Actions UI

1. Перейдите в `Actions` tab в вашем репозитории
2. Выберите workflow
3. Просмотрите логи каждого шага
4. Проверьте Summary для информации о развертывании

### AWS Console

- **CloudFormation**: Проверить статус стеков
- **Lambda**: Проверить обновления функций
- **S3**: Проверить загруженные файлы
- **CloudWatch**: Просмотреть логи

## 🔧 Шаг 8: Настройка защиты веток

### Защита main ветки:

1. Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Включить:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators

### Защита beta ветки:

1. Settings → Branches → Add rule
2. Branch name pattern: `beta`
3. Включить:
   - ✅ Require status checks to pass before merging

## 🚨 Troubleshooting

### Проблема: Workflow не запускается

**Решение:**
- Проверьте, что файлы в `.github/workflows/`
- Проверьте синтаксис YAML
- Проверьте, что изменения в правильных путях

### Проблема: AWS credentials ошибка

**Решение:**
```bash
# Проверить секреты в GitHub
# Settings → Secrets and variables → Actions

# Проверить права IAM пользователя
aws iam get-user --user-name github-actions-user
aws iam list-attached-user-policies --user-name github-actions-user
```

### Проблема: CDK deploy fails

**Решение:**
```bash
# Проверить, что CDK bootstrap выполнен
aws cloudformation describe-stacks --stack-name CDKToolkit

# Если нет - выполнить bootstrap
cdk bootstrap aws://YOUR_ACCOUNT_ID/us-west-2
```

### Проблема: Lambda update fails

**Решение:**
- Проверить, что функция существует
- Проверить размер zip файла (< 50MB)
- Проверить права IAM

## 📈 Шаг 9: Улучшения (Опционально)

### 9.1 Добавить уведомления в Slack

```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 9.2 Добавить кэширование

```yaml
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### 9.3 Добавить manual approval для production

```yaml
- name: Manual approval
  uses: trstringer/manual-approval@v1
  if: github.ref == 'refs/heads/main'
  with:
    secret: ${{ github.TOKEN }}
    approvers: YOUR_GITHUB_USERNAME
```

## ✅ Checklist финальной проверки

- [ ] GitHub репозиторий создан
- [ ] AWS Secrets добавлены в GitHub
- [ ] Workflows файлы закоммичены
- [ ] Beta ветка создана
- [ ] Защита веток настроена
- [ ] Тестовый push выполнен
- [ ] Workflow успешно выполнился
- [ ] Изменения видны в AWS
- [ ] Документация обновлена

## 🎉 Готово!

Теперь ваш CI/CD pipeline настроен! Каждый push в `beta` или `main` будет автоматически деплоить изменения в AWS.

### Полезные команды:

```bash
# Просмотр статуса workflow
gh run list

# Просмотр логов последнего run
gh run view --log

# Повторный запуск failed workflow
gh run rerun <run-id>
```

## 📚 Дополнительные ресурсы

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS CDK CI/CD](https://docs.aws.amazon.com/cdk/v2/guide/cdk_pipeline.html)
- [GitHub Actions for AWS](https://github.com/aws-actions)
