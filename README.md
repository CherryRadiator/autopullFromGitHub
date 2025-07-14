# Автоматический деплой через GitHub Webhook

Этот проект позволяет автоматически обновлять код на сервере при каждом push в GitHub репозиторий с помощью webhook'ов.

## Структура проекта

```
public_html/
├── .env                    # Конфигурационный файл с переменными окружения
├── .gitignore             # Список игнорируемых файлов
├── deploy.php             # Основной скрипт обработки webhook'а
├── deploy.sh              # Скрипт выполнения деплоя
├── run_deploy.sh          # Wrapper скрипт для запуска деплоя
├── deploy_log.txt         # Лог файл деплоя
└── README.md              # Документация
```

## Пошаговая настройка
### Настройка сервера
Все что необходимо сделать, чтобы этот скрипт работал: скопировать эти команды и выполнить их в терминале в директории вашего проекта (пример для beget: /home/user/name/yourdomain/public_html)
```bash
git clone https://github.com/CherryRadiator/autopullFromGitHub.git
rm -rf autopullFromGitHub/.git
echo >> .gitignore
grep -qxF "autopullFromGitHub/deploy.sh" .gitignore || echo "autopullFromGitHub/" >> .gitignore
mv autopullFromGitHub/.env.example autopullFromGitHub/.env

```

### Настройка компьютера
Выполните эту команду в терминале в директории своего проекта на компьютере если у вас Unix терминал
```bash
echo -e "autopullFromGitHub/deploy.sh\nautopullFromGitHub/deploy.php\nautopullFromGitHub/run_deploy.sh\nautopullFromGitHub/.env\nautopullFromGitHub/deploy_log.txt" >> .gitignore

```

Если вы используете PowerShell
```ps
@"
autopullFromGitHub/deploy.sh
autopullFromGitHub/deploy.php
autopullFromGitHub/run_deploy.sh
autopullFromGitHub/.env
autopullFromGitHub/deploy_log.txt
"@ >> .gitignore


```

Если используете cmd
```cmd
echo autopullFromGitHub/deploy.sh >> .gitignore
echo autopullFromGitHub/deploy.php >> .gitignore
echo autopullFromGitHub/run_deploy.sh >> .gitignore
echo autopullFromGitHub/.env >> .gitignore
echo autopullFromGitHub/deploy_log.txt >> .gitignore

```

### Добавление персонального токена доступа
Если ваш репозиторий приватный, вам понадобиться персональный токен доступа (Personal fine-grained access token) 
Если у вас еще нет этого токена следуйте этим шагам:

1. Откройте GitHub: https://github.com
2. Откройте ваши настройки: нажмите на фото профиля в правом верхнем углу -> Settings
3. Откройте Developer Settings: прокрутите ниже -> нажмите на Developer Settings
4. Настроить персональный токен: нажмите "Personal access tokens" -> "Fine-grained tokens"
5. Сгенерируйте новый токен: нажмите "Generate new token" -> "Generate new token"
6. Настройте парматеры токена: Name (например repo-access), Expiration (как долго этот токен будет активен), Repository access ->Only select repositories -> (Выберите репозиторий, к которому будет доступ у этого приложения), Пролистайте вниз и выберите Contents -> Read-only, Пролистайте еще ниже и убедитесь, что пункт Metadata установлен в Read-only, пролистайте ниже и нажмите Generate token
7. Прокрутите вниз и нажмите Generate token
9. Скопируйте токен и сохраните в надежном месте, ведь больше он не появиться

### Настройка переменной .env
После этого вам нужно поменять значения в файле ".env" значения:

- your_secret_key_here -> Придумайте надёжный секретный ключ (например, случайная строка из 32+ символов)

- /home/path/to/your/directory/ -> путь к вашему проекту

- https://user_name:your_token@github.com/user_name/repository_name.git -> URL вашего репозитория; user_name - имя пользователя на гитхабе, your_token - персональный токен на GitHub, repository_name - имя репозитория

- master -> название ветки

пример переменной .env:
```bash
# Путь к директории с репозиторием (на beget это обычно public_html; он выглядит примерно так: /home/user/yourdomain/public_html) (чтобы узнать полный путь к директории репозитория можно использовать команду pwd из директории вашего public_html)
PATH_TO_REPO_DIR=/home/path/to/your/directory/

# GitHub Webhook секрет (он нам понадобиться позже для настроек webhook'а)
GITHUB_WEBHOOK_SECRET=your_secret_key_here

# URL вашего GitHub репозитория (рекомендуется использовать https доступ с токеном, если репозиторий приватный)
REMOTE_URL_REPO=https://user_name:your_token@github.com/user_name/repository_name.git

# Название ветки для деплоя
NAME_OF_BRANCH=master
```
### Создание webhook'а в GitHub

1. Откройте ваш репозиторий на GitHub
2. Перейдите в **Settings** → **Webhooks**
3. Нажмите **Add webhook**
4. Заполните поля:
   - **Payload URL**: `https://yourdomain.com/autopullFromGitHub/deploy.php` путь к вашему файлу "deploy.php" на сервере (замените yourdomain.com на ваш домен)
   - **Content type**: `application/json`
   - **Secret**: Тот самый секрет из файла .env -> "GITHUB_WEBHOOK_SECRET=your_secret_key_here"
   - **SSL verification**: Enable SSL verification
   - **Which events would you like to trigger this webhook?**: Выберите "Just the push event"
   - **Active**: Поставьте галочку
5. Нажмите **Add webhook**
