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

### 1. Создание webhook'а в GitHub

1. Откройте илии создайте, если еще нет ваш репозиторий на GitHub
2. Перейдите в **Settings** → **Webhooks**
3. Нажмите **Add webhook**
4. Заполните поля:
   - **Payload URL**: `https://yourdomain.com/deploy.php` путь к вашему файлу "deploy.php" на сервере
   - **Content type**: `application/json`
   - **Secret**: Придумайте надёжный секретный ключ (например, случайная строка из 32+ символов)
   - **SSL verification**: Enable SSL verification
   - **Which events would you like to trigger this webhook?**: Выберите "Just the push event"
   - **Active**: Поставьте галочку
5. Нажмите **Add webhook**

### 2. Настройка файлов на сервере

#### 2.1 Создание .env файла

Создайте файл `.env` в корне вашего проекта со следующим содержимым:

```bash
# GitHub Webhook секрет (тот же, что указали в настройках webhook'а)
GITHUB_WEBHOOK_SECRET=your_secret_key_here

# Путь к скрипту run_deploy.sh
PATH_TO_RUN_DEPLOY=/home/path/to/your/directory/run_deploy.sh

# Путь к скрипту deploy.sh
PATH_TO_DEPLOY_SCRIPT=/home/path/to/your/directory/deploy.sh

# Путь к лог файлу
PATH_TO_LOG_FILE=/home/path/to/your/directory/deploy_log.txt

# Путь к директории с репозиторием (на beget это обычно public_html; он выглядит примерно так: /home/user/yourdomain/public_html) (чтобы узнать полный путь к директории репозитория можно использовать команду pwd из директории вашего public_html)
PATH_TO_REPO_DIR=/home/path/to/your/directory/

# URL вашего GitHub репозитория (рекомендуется использовать https доступ с токеном, если репозиторий приватный*)
REMOTE_URL_REPO=https://<user_name>:<your_token>@github.com/<user_name>/<repository_name>.git

# Название ветки для деплоя
NAME_OF_BRANCH=master
```
*для получения токена следуйте этим шагам:
1. Откройте GitHub: https://github.com
2. Откройте ваши настройки: нажмите на фото профиля в правом верхнем углу -> Settings
3. Откройте Developer Settings: прокрутите ниже -> нажмите на Developer Settings
4. Настроить персональный токен: нажмите "Personal access tokens" -> "Tokens (classic)"
5. Сгенерируйте новый токен: нажмите "Generate new token" -> "Generate new token (classic)"
6. Настройте парматеры токена: Note (например repo-access), Expiration (как долго этот токен будет активен), Scopes (как минимум выберите repo (полный контроль над репозиторием))
7. Прокрутите вниз и нажмите Generate token
8. Скопируйте токен и сохраните в надежном месте, ведь больше он не появиться

**Важно**: Замените следующие значения на свои:
- `your_secret_key_here` -> секретный ключ из настроек webhook'а
- `/home/path/to/your/directory/` -> путь к вашему проекту
- `/home/path/to/your/directory/run_deploy.sh` -> путь к файлу run_deploy.sh
- `/home/path/to/your/directory/deploy.sh` -> путь к файлу deploy.sh
- `/home/path/to/your/directory/deploy_log.txt` -> путь к файлу с логами
- `https://<user_name>:<your_token>@github.com/<user_name>/<repository_name>.git` -> URL вашего репозитория
- `master` -> название ветки (если используете не master)

#### 2.2 Создание лог файла

Создайте пустой файл для логов в директории вашего проекта:

```bash
touch deploy_log.txt
```

### 3. Установка прав доступа

Выполните следующие команды в директории с проектом:

```bash
# Права для конфигурационного файла и лог файла
chmod 664 .env deploy_log.txt

# Права для исполняемых скриптов
chmod +x deploy.sh run_deploy.sh
```

### 4. Проверка настроек

#### 4.1 Проверка путей

Убедитесь, что все пути в файле `.env` указаны правильно:

```bash
# Проверьте, что файлы существуют
ls -la deploy.php deploy.sh run_deploy.sh

# Проверьте права доступа
ls -la .env deploy_log.txt
```

#### 4.2 Тестирование webhook'а

1. Сделайте любой commit и push в ваш репозиторий
2. Проверьте логи в файле `deploy_log.txt`
3. Проверьте статус webhook'а в настройках GitHub (должен показать успешную доставку)

## Как это работает

1. **GitHub** отправляет POST-запрос на `deploy.php` при каждом push
2. **deploy.php** проверяет подпись запроса для безопасности
3. Если проверка прошла успешно, запускается `run_deploy.sh`
4. **run_deploy.sh** загружает переменные окружения и запускает `deploy.sh`
5. **deploy.sh** выполняет git pull и обновляет код на сервере
6. Все действия логируются в `deploy_log.txt`

## Безопасность

- Используется HMAC-SHA256 подпись для проверки подлинности запросов
- Секретный ключ хранится в `.env` файле (не забудьте добавить `.env` в `.gitignore`)
- Все пути проверяются на безопасность
- Выполняется валидация JSON payload'а

## Устранение проблем

### Webhook не срабатывает

1. Проверьте URL webhook'а в настройках GitHub
2. Убедитесь, что сервер доступен по указанному URL
3. Проверьте логи веб-сервера на наличие ошибок

### Ошибки в логах

1. Проверьте правильность путей в `.env` файле
2. Убедитесь, что у скриптов есть права на выполнение
3. Проверьте, что у веб-сервера есть права на запись в лог файл

### Проблемы с git

1. Убедитесь, что репозиторий публичный или настроен доступ по SSH
2. Проверьте правильность URL репозитория
3. Убедитесь, что указанная ветка существует

## Дополнительные возможности

### Уведомления

Вы можете добавить отправку уведомлений (email, Telegram, Slack) в скрипт `deploy.sh` для информирования об успешном или неуспешном деплое.

### Множественные окружения

Для работы с разными ветками (dev, staging, production) можно создать отдельные webhook'и и конфигурационные файлы.

## Поддержка

При возникновении проблем:
1. Проверьте логи в `deploy_log.txt`
2. Проверьте логи веб-сервера
3. Убедитесь в правильности всех путей и прав доступа
4. Проверьте статус webhook'а в GitHub
