#!/bin/bash

source /home/path/to/your/directory/.env

cd "$PATH_TO_REPO_DIR" || {
  echo "[ERROR] Can't cd to $PATH_TO_REPO_DIR"
  exit 1
}

"$PATH_TO_DEPLOY_SCRIPT"
