# Data model: 006-laravel-php-mise-tooling

Esta feature não introduz base de dados nem API de produto. Os «dados» são **metadados de capacidade da imagem** e **artefactos documentais** no repositório.

## Entidade: `LaravelServerRequirementSet`

Conjunto verificável alinhado à documentação oficial do Laravel (major alvo).

| Campo | Tipo lógico | Regras / notas |
|--------|----------------|------------------|
| `doc_major` | integer | Ex.: `12` (Laravel 12.x). |
| `doc_uri` | URI | Ex.: `https://laravel.com/docs/12.x/deployment#server-requirements`. |
| `min_php_major_minor` | string | `8.2` na doc; ambiente alvo do repo: **8.4**. |
| `required_extensions` | set de string | Nomes canónicos para verificação via `php -m` / `extension_loaded` (ver contrato). |

**Validação**: Para cada elemento de `required_extensions`, o módulo ou capacidade correspondente deve estar presente no PHP activo na shell de desenvolvimento.

## Entidade: `PhpRuntimeCapability`

Estado do interpretador PHP gerido pelo mise na imagem `dev`.

| Campo | Tipo lógico | Regras |
|--------|----------------|--------|
| `channel` | enum | `mise-system` (`php@8.4`). |
| `install_prefix` | path | Prefixo sob `/usr/local/share/mise/installs/php/…`. |
| `default_cli_binary` | path | `php` no PATH de login (deve resolver para o prefixo mise). |
| `observed_modules` | set de string | Obtido por `php -m` (normalizado para minúsculas onde aplicável). |

**Relação**: `observed_modules` **deve ser superconjunto** (na prática) dos módulos necessários mapeados a partir de `LaravelServerRequirementSet.required_extensions`.

## Entidade: `GlobalPhpTool`

Ferramenta CLI global relacionada com PHP / Laravel.

| Campo | Tipo lógico | Regras |
|--------|----------------|--------|
| `tool_name` | string | `composer` \| `laravel`. |
| `invocation` | string | Comando esperado no PATH (`composer`, `laravel`). |
| `install_mechanism` | enum | `mise-php-shipped` (Composer) \| `composer-global` (Laravel installer). |
| `composer_home` | path opcional | Para `laravel`: ex. `/usr/local/share/composer`. |

**Validação**: `composer --version` e `laravel --version` (ou `--help`) retornam exit code 0; `composer diagnose` sem erros críticos de plataforma após melhorias opcionais (`unzip`).

## Entidade: `DevEnvironmentDocRecord`

Registo conceptual no inventário (`docs/dev-environment/capability-inventory.md`).

| Campo | Tipo lógico | Regras |
|--------|----------------|--------|
| `inventory_id` | string | Ex.: `composer`, `laravel-installer`, ou extensão da linha `php-runtime`. |
| `supplier` | string | `mise php@8.4` / `Composer` / `Packagist (laravel/installer)`. |
| `compliance` | enum | `ok` \| `pending` \| `exception` (legenda existente do inventário). |

## Transições de estado

1. **Antes**: PHP conforme com extensões, Composer presente no prefixo mise; **`laravel` ausente** do PATH global; possível aviso `unzip` no diagnose.  
2. **Depois**: Mesmo PHP; Composer documentado/verificado; **`laravel` disponível**; inventário e docs actualizados; verificações em `contracts/` passam.
