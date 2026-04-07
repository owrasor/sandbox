# Contract: verificação de CLIs (Composer e Laravel Installer)

**Feature**: `006-laravel-php-mise-tooling`

## Composer

### Comandos

```bash
command -v composer
composer --version
php -r 'echo "PHP binary: ", PHP_BINARY, "\n";';
```

### Critérios de aceitação

1. `command -v composer` imprime um caminho não vazio (tipicamente sob `/usr/local/share/mise/installs/php/…/bin/composer`).
2. `composer --version` imprime linha com `Composer version` e exit code **0**.
3. O PHP usado pelo Composer (reportado em `composer diagnose` ou `PHP_BINARY` coerente) pertence à série **8.4** do mise.

## Laravel Installer

### Comandos

```bash
command -v laravel
laravel --version
```

### Critérios de aceitação

1. `command -v laravel` imprime um caminho não vazio (ex.: `/usr/local/bin/laravel`).
2. `laravel --version` (ou `laravel list` se `--version` não existir na versão instalada) retorna exit code **0** e output informativo.

## Notas

- Verificações **sem rede** suficientes para critérios acima; criação de projecto (`laravel new`) é teste opcional e depende de conectividade Packagist.
