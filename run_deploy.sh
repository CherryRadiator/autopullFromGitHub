#!/bin/bash
cd /home/i/injener/test.smartesthome.ru/public_html || exit
source .env
"$PATH_TO_DEPLOY_SCRIPT"
