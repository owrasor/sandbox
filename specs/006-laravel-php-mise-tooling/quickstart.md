# Quickstart: validar PHP/Laravel/Composer no contentor `dev` (006-laravel-php-mise-tooling)

## Pré-requisitos

- Docker e Docker Compose v2  
- Raiz do repositório em `/home/owrasor/Code/owrasor/sandbox` (ou equivalente)  
- Arquitectura **x86_64** (alinhada à imagem actual)

## 1. Build

```bash
cd /home/owrasor/Code/owrasor/sandbox
docker compose build dev
```

## 2. PHP e extensões (Laravel 12.x — requisitos mínimos)

```bash
docker compose run --rm dev bash -lc 'php -v && php -m'
```

Verificação automática (também corrida no build da imagem):

```bash
docker compose run --rm dev bash -lc '/usr/local/bin/verify-php-laravel-extensions.sh'
```

Compare com a lista do contrato: [contracts/laravel-php-extensions.md](./contracts/laravel-php-extensions.md).

## 3. Composer

```bash
docker compose run --rm dev bash -lc 'command -v composer && composer --version && composer diagnose'
```

Esperado: Composer resolve para o PHP 8.4 do mise; diagnose sem falhas críticas de plataforma (após inclusão de `unzip` na imagem, se aplicável).

## 4. Laravel Installer

```bash
docker compose run --rm dev bash -lc 'command -v laravel && laravel --version'
```

Esperado: exit code **0** e versão do instalador impressa.

## 5. Smoke opcional com rede (criação de projecto)

Requer rede para Packagist / repositórios Laravel:

```bash
docker compose run --rm dev bash -lc 'cd /tmp && rm -rf laravel-smoke-test && laravel new laravel-smoke-test --no-interaction'
```

Limpar `/tmp/laravel-smoke-test` após o teste se não for necessário.

## Referências

- Contratos: [contracts/](./contracts/)  
- Decisões: [research.md](./research.md)  
- Spec: [spec.md](./spec.md)
