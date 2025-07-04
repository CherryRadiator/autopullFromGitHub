#!/bin/bash

# Путь к .env относительно текущего скрипта
ENV_PATH="$(dirname "$0")/.env"

# Проверка существования
if [ ! -f "$ENV_PATH" ]; then
  echo "[ERROR] .env not найден по пути: $ENV_PATH"
  exit 1
fi

# Загрузка переменных окружения
set -a
source "$ENV_PATH"
set +a

# Переход в директорию проекта
cd "$PATH_TO_REPO_DIR" || {
  echo "[ERROR] Не удалось перейти в $PATH_TO_REPO_DIR"
  exit 1
}

# Запуск скрипта деплоя
"$PATH_TO_DEPLOY_SCRIPT"
