# Implementation Plan: Arranque único de script de dotfiles configurável

**Branch**: `007-dotfiles-bootstrap-once` | **Date**: 2026-04-06 | **Spec**: [/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/spec.md](/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/spec.md)  
**Input**: Feature specification from `/specs/007-dotfiles-bootstrap-once/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Permitir que o desenvolvedor defina no `.env` o **nome de um ficheiro** de script que reside no clone de dotfiles montado em **`/home/dev/dotfiles`**, e que esse script seja executado **no máximo uma vez com sucesso** por ambiente persistente (estado gravado de forma explícita), **no arranque** (não no build da imagem), para preparar tmux/zsh/nvim ou equivalente. Abordagem: variável de ambiente injectada via [`docker-compose.yml`](/home/owrasor/Code/owrasor/sandbox/docker-compose.yml); script de orquestração na imagem (Bash) que valida caminho, usa **marcador persistido** no bind mount do **workspace** (caminho convencionado + entrada em [`.gitignore`](/home/owrasor/Code/owrasor/sandbox/.gitignore)), **flock** para concorrência, e invocação desde **`/etc/zsh/zshenv`** (carregado em qualquer `zsh`, com saída imediata se desactivado ou já concluído). Documentação em [`docs/sandbox.md`](/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md) e [`.env.example`](/home/owrasor/Code/owrasor/sandbox/.env.example).

## Technical Context

**Language/Version**: Shell **Bash** (script de bootstrap na imagem); **Zsh** como shell de sessão do serviço `dev`  
**Primary Dependencies**: **Docker Compose v2** (`env_file: .env`); montagem existente `DOTFILES_HOST` → `/home/dev/dotfiles`; imagem **Ubuntu 24.04**  
**Storage**: Ficheiro de estado (marcador) no volume do **workspace**; opcional ficheiro de lock no mesmo directório  
**Testing**: Smoke manual: `docker compose build dev`, `docker compose run --rm --no-deps` com `.env` de teste; verificar ordem (marcador só após exit 0); repetir arranque sem reexecução; casos variável vazia / ficheiro ausente / script com `exit 1`  
**Target Platform**: Contentor **Linux** (serviço `dev`)  
**Project Type**: Infraestrutura de desenvolvimento (Docker + shell + documentação)  
**Performance Goals**: N/A (caminho feliz: uma verificação de ficheiro + retorno imediato após conclusão)  
**Constraints**: Não executar ficheiros fora de `/home/dev/dotfiles`; não marcar sucesso se o script falhar; não depender do build da imagem para conteúdo do `.env` ou dotfiles do host; preservar mounts e entrypoint actuais (`gosu dev`)  
**Scale/Scope**: Um script de sistema na imagem, um snippet `zshenv`, variáveis Compose, documentação e possível entrada `.gitignore`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro [/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md](/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md) permanece como **modelo** (sem princípios ratificados). **Estado do gate**: **PASS** — alteração localizada ao contentor de desenvolvimento; sem segredos novos obrigatórios; risco limitado a execução de script **definido pelo utilizador** no seu próprio mount de dotfiles.

**Re-check pós-Phase 1**: **PASS** — `contracts/` fixam variáveis e comandos observáveis; `data-model.md` formaliza estado e validações sem expandir escopo além da spec.

## Project Structure

### Documentation (this feature)

```text
specs/007-dotfiles-bootstrap-once/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
docker/Dockerfile                    # COPY script de bootstrap; instalar snippet zshenv (ou equivalente)
docker/sandbox-dotfiles-bootstrap.sh # Lógica: validar nome, realpath, flock, executar, gravar marcador só em sucesso
docker/zshenv-sandbox-bootstrap.snippet # Conteúdo mínimo incluído em /etc/zsh/zshenv (ou ficheiro sourced)
docker-compose.yml                   # Passar variável(ies) de ambiente ao serviço dev (se não herdadas só de env_file)
.env.example                         # Documentar variável opcional do nome do script
docs/sandbox.md                      # Fluxo, segurança (path), como repor o “uma vez”
.gitignore                           # Ignorar directório de estado sob workspace (ex.: workspace/.sandbox/ ou padrão acordado)
```

**Structure Decision**: Sem código em `src/`; alterações concentradas em **Docker**, **Compose**, **documentação** e **gitignore** para o marcador persistido no workspace.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(Não aplicável — nenhuma violação identificada.)*

## Phase 2 (fora deste comando)

A desagregação em tarefas implementáveis fica para **`/speckit.tasks`** (`tasks.md`).
