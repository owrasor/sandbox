#!/usr/bin/env bash
# Verifica extensões PHP mínimas para Laravel 12.x (Server Requirements).
# Contrato: specs/006-laravel-php-mise-tooling/contracts/laravel-php-extensions.md
set -euo pipefail
php -r '
$need = ["ctype","curl","dom","fileinfo","filter","hash","mbstring","openssl","pdo","session","tokenizer","xml"];
$bad = false;
foreach ($need as $e) {
    if (!extension_loaded($e)) {
        fwrite(STDERR, "MISSING extension: {$e}\n");
        $bad = true;
    }
}
exit($bad ? 1 : 0);
'
