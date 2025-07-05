#!/bin/bash

# Путь к .env относительно текущего скрипта
ENV_PATH="./.env"

PATH_TO_CURRENT_DIR=$(pwd)

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
  exit 2
}

cd "$PATH_TO_CURRENT_DIR"

# Запуск скрипта деплоя
"$PATH_TO_CURRENT_DIR/deploy.sh"
