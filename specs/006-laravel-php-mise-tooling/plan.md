# Implementation Plan: Suporte Laravel no runtime PHP do contentor

**Branch**: `006-laravel-php-mise-tooling` | **Date**: 2026-04-06 | **Spec**: [/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/spec.md](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/spec.md)  
**Input**: Feature specification from `/specs/006-laravel-php-mise-tooling/spec.md`

**Note**: Este ficheiro é produzido pelo comando `/speckit.plan`. O fluxo de trabalho está descrito em `.specify/templates/plan-template.md`.

## Summary

Garantir que a imagem **dev** satisfaz os **requisitos oficiais de servidor do Laravel** (documentação **12.x** em 2026-04-06), que o **Composer** está acessível e alinhado ao **PHP 8.4** do **mise**, e que o **Laravel Installer** (`laravel`) está no **PATH** — seguindo o padrão actual de integração do PHP via mise no `docker/Dockerfile` (PATH em `/etc/profile.d` + `/etc/zsh/zprofile`).  

Pesquisa na imagem actual (`docker compose run --rm dev php -m`): as extensões mínimas listadas em [Laravel 12.x — Server Requirements](https://laravel.com/docs/12.x/deployment#server-requirements) já estão presentes; o **Composer** já existe em `/usr/local/share/mise/installs/php/8.4.x/bin/composer`; falta expor de forma explícita a **verificação repetível** (contrato + documentação), instalar o **comando `laravel`**, e tratar **ergonomia** (ex.: `unzip` para o `composer diagnose`). Actualizar **inventário** e **docs** de desenvolvimento.

## Technical Context

**Language/Version**: Dockerfile (OCI); **Bash** nos `RUN`; PHP **8.4.x** via **mise** (`mise install --system php@8.4`)  
**Primary Dependencies**: **Ubuntu 24.04**; bibliotecas `-dev` já listadas no Dockerfile para compilação/uso de extensões PHP; **Composer** (já junto ao prefixo PHP do mise); **Laravel Installer** via Composer global  
**Storage**: N/A (sem persistência de dados da aplicação; apenas camadas da imagem e caches opcionais do Composer em build)  
**Testing**: Smoke em contentor: `php -m`, `composer --version` / `composer diagnose`, `laravel --version`; opcionalmente `composer create-project` ou `laravel new` em directório temporário (rede necessária)  
**Target Platform**: Contentor **Linux x86_64** (imagem `dev`)  
**Project Type**: Infraestrutura de desenvolvimento (Docker + documentação + contratos de verificação)  
**Performance Goals**: N/A (alvo: onboarding; sem SLAs de latência)  
**Constraints**: Um único PHP «oficial» na shell de desenvolvimento — o do mise; não introduzir segundo PHP do Ubuntu sem justificação; builds reprodutíveis (pin de versões de ferramentas globais quando fizer sentido)  
**Scale/Scope**: Um serviço `dev`, ficheiros em `docker/`, `docs/dev-environment/`, `specs/006-laravel-php-mise-tooling/contracts/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro [/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md](/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md) permanece como **modelo** (sem princípios ratificados). **Estado do gate**: **PASS** — mudança localizada na imagem dev e documentação; sem conflito com princípios concretos.

**Re-check pós-Phase 1**: **PASS**; contratos limitam-se a comandos de verificação e listas de extensões (ver `contracts/`).

## Project Structure

### Documentation (this feature)

```text
specs/006-laravel-php-mise-tooling/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
docker/
├── Dockerfile           # unzip (apt) se necessário; Composer/Laravel installer global + symlinks em /usr/local/bin; manter PATH mise
├── entrypoint.sh        # Sem alteração estrutural esperada
└── install-ai-clis.sh   # Sem alteração esperada

docs/
├── sandbox.md                    # Referência a Laravel / Composer / `laravel` se aplicável
└── dev-environment/
    ├── capability-inventory.md   # Novas linhas ou actualização: composer, laravel-installer, extensões PHP para Laravel
    └── (outros)                  # Apenas se a política ou auditorias referirem PHP/Laravel

specs/006-laravel-php-mise-tooling/
├── contracts/*.md       # Contrato de verificação de extensões e CLIs
├── quickstart.md        # Passos de validação manual
└── research.md          # Decisões (fonte de verdade Laravel docs, Composer, installer)

compose.yaml             # Sem alteração estrutural esperada
```

**Structure Decision**: Entrega centrada em **`docker/Dockerfile`**, **documentação** (`docs/`) e **contratos** desta feature; sem código em `src/` da aplicação.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(Não aplicável — nenhuma violação identificada.)*
