<?php

// Простая загрузка .env файла
$env_file = __DIR__ . '/.env';
if (file_exists($env_file)) {
    $lines = file($env_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            
            // Убираем кавычки из значений
            $value = trim($value, '"\'');
            
            if (!empty($key)) {
                $_ENV[$key] = $value;
            }
        }
    }
}

// Получаем секрет из .env
$webhook_secret = $_ENV['GITHUB_WEBHOOK_SECRET'] ?? '';

if (empty($webhook_secret)) {
    http_response_code(500);
    exit('Webhook secret not configured');
}

// Получаем данные запроса
$payload = file_get_contents('php://input');
$signature = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';

// Проверяем наличие подписи
if (empty($signature)) {
    http_response_code(401);
    exit('Missing signature');
}

// Вычисляем ожидаемую подпись
$expected_signature = 'sha256=' . hash_hmac('sha256', $payload, $webhook_secret);

// Сравниваем подписи безопасным способом
if (!hash_equals($expected_signature, $signature)) {
    http_response_code(401);
    exit('Invalid signature');
}

// Проверяем, что это POST запрос
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit('Only POST requests allowed');
}

// Дополнительная проверка: парсим JSON и проверяем событие (опционально)
$data = json_decode($payload, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    exit('Invalid JSON payload');
}

// Все проверки пройдены
echo "Webhook verified successfully\n";

// Получаем путь к скрипту деплоя
$run_deploy_path = $_ENV['PATH_TO_RUN_DEPLOY'] ?? __DIR__ . '/run_deploy.sh';

// Проверяем существование скрипта
if (!file_exists($run_deploy_path)) {
    http_response_code(500);
    exit('Deploy script not found: ' . $run_deploy_path);
}

// Безопасно выполняем скрипт
$safe_path = realpath($run_deploy_path);
if (!$safe_path) {
    http_response_code(500);
    exit('Invalid deploy script path');
}

echo "Running deploy script: " . $safe_path . "\n";

// Запускаем bash-скрипт
exec("chmod +x " . escapeshellarg($safe_path));
exec(escapeshellarg($safe_path) . " 2>&1", $output, $return_var);

// Выводим результат
echo "\n\nReturn code: $return_var\n";
echo "Output:\n";
print_r($output);

?>