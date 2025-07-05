#!/bin/bash

ENV_FILE="$PATH_TO_REPO_DIR/autopullFromGitHub/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "[ERROR] .env файл не найден по пути: $ENV_FILE"
  exit 3
fi

LOG="$PATH_TO_REPO_DIR/autopullFromGitHub/deploy_log.txt"
REPO_DIR="$PATH_TO_REPO_DIR"
REMOTE_URL="$REMOTE_URL_REPO"
BRANCH="$NAME_OF_BRANCH"

echo "===== DEPLOY START: $(date) =====" >> "$LOG"

cd "$REPO_DIR" || {
  echo "[ERROR] Can't cd into $REPO_DIR" >> "$LOG"
  exit 4
}

# Очистка всех файлов и папок, кроме .env и autopullFromGitHub/
echo "[CLEAN] Cleaning working directory (excluding .env and autopullFromGitHub)..." >> "$LOG"
find "$REPO_DIR" -mindepth 1 \
  ! -name '.env' \
  ! -name 'autopullFromGitHub' \
  ! -path "$REPO_DIR/autopullFromGitHub/*" \
  -exec rm -rf {} + >> "$LOG" 2>&1

# Инициализация git
git -c safe.directory="$REPO_DIR" init >> "$LOG" 2>&1
echo "[INFO] Git init done" >> "$LOG"

git -c safe.directory="$REPO_DIR" remote add origin "$REMOTE_URL" >> "$LOG" 2>&1
if [ $? -ne 0 ]; then
  echo "[ERROR] Failed to add remote origin" >> "$LOG"
  exit 5
fi
echo "[INFO] Remote added" >> "$LOG"

# Настройка rebase и получение кода
git -c safe.directory="$REPO_DIR" config pull.rebase true

echo "[deploy] Обновляем код из репозитория с rebase..." >> "$LOG"
git -c safe.directory="$REPO_DIR" pull --rebase origin "$BRANCH" >> "$LOG" 2>&1
if [ $? -ne 0 ]; then
  echo "[ERROR] Git pull --rebase failed" >> "$LOG"
  exit 7
fi

echo "[INFO] Git pull complete" >> "$LOG"
echo "===== DEPLOY END: $(date) =====" >> "$LOG"
