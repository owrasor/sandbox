# Implementation Plan: Shell na home do desenvolvedor e privilégios elevados

**Branch**: `005-dev-shell-home-sudo` | **Date**: 2026-04-06 | **Spec**: [/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/spec.md](/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/spec.md)  
**Input**: Feature specification from `/specs/005-dev-shell-home-sudo/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Garantir que **`docker compose exec dev zsh`** (e o arranque interativo equivalente via Compose) inicia com **diretório de trabalho `/home/dev`**, alinhado ao pedido explícito no **Input** da spec, e que o utilizador **`dev`** possa **elevar privilégios com `sudo`** (política **NOPASSWD** no contentor de desenvolvimento, coerente com as Assumptions). Abordagem: (1) alterar `working_dir` do serviço `dev` em [`docker-compose.yml`](/home/owrasor/Code/owrasor/sandbox/docker-compose.yml) para `/home/dev` — é o que o Docker Compose usa como CWD por defeito em `exec`/`run`; (2) alinhar `WORKDIR` no [`docker/Dockerfile`](/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile) para o mesmo valor, evitando divergência em execuções sem Compose; (3) instalar **`sudo`** na imagem e ficheiro em **`/etc/sudoers.d/`** para `dev`; (4) actualizar [`docs/sandbox.md`](/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md) (e referências ao “diretório inicial”) com `cd workspace` onde o código estiver montado.

## Technical Context

**Language/Version**: Dockerfile (OCI); shell **Bash** nos `RUN`; imagem base **Ubuntu 24.04**  
**Primary Dependencies**: pacote **`sudo`** (distro); **Docker Compose v2** para semântica de `working_dir` / `exec`  
**Storage**: N/A (sem persistência de dados da aplicação; mounts existentes preservados)  
**Testing**: Smoke manual: `docker compose build dev`, `docker compose run --rm --no-deps dev zsh -lc 'pwd'`, `docker compose exec dev zsh -lc 'pwd'` (com stack `up`), `sudo -n true` como `dev`  
**Target Platform**: Contentor **Linux** (serviço `dev` do repositório)  
**Project Type**: Infraestrutura de desenvolvimento (Docker + documentação)  
**Performance Goals**: N/A  
**Constraints**: Não quebrar mounts (`/home/dev/workspace`, dotfiles, `.ssh`); entrypoint continua a correr como root só para alinhar UID/GID e depois **`gosu dev`**; sudo só **dentro** do contentor; imagem continua a ser ambiente de **dev interno**  
**Scale/Scope**: Um serviço Compose, uma imagem, actualização pontual de docs

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro [/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md](/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md) está ainda como **modelo** (sem princípios ratificados). **Estado do gate**: **PASS** — mudança localizada, reversível, documentada; risco de segurança limitado ao contentor de desenvolvimento e assumido na spec.

**Re-check pós-Phase 1**: **PASS** — contratos em `contracts/` descrevem verificações observáveis (`pwd`, `sudo`) sem expandir escopo.

## Project Structure

### Documentation (this feature)

```text
specs/005-dev-shell-home-sudo/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
docker-compose.yml       # working_dir do serviço dev → /home/dev
docker/Dockerfile        # WORKDIR /home/dev; instalar sudo; sudoers.d para utilizador dev
docs/sandbox.md          # Diretório inicial, fluxo exec zsh, nota sobre cd workspace; verificação sudo
docker/entrypoint.sh     # Sem alteração esperada (mantém gosu dev)
```

**Structure Decision**: Alterações concentradas em **Compose + Dockerfile + documentação**; sem código em `src/`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(Não aplicável — nenhuma violação identificada.)*
