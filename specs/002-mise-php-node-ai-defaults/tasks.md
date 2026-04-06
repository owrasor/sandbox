---
description: "Task list for feature 002-mise-php-node-ai-defaults (mise, PHP 8.4, Node 22, CLIs de IA)"
---

# Tasks: Runtimes e CLIs de IA por defeito no contentor de desenvolvimento

**Input**: Design documents from `/home/owrasor/Code/owrasor/sandbox/specs/002-mise-php-node-ai-defaults/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: A spec não exige TDD; validação = smoke manual em [quickstart.md](./quickstart.md).

**Organization**: Fases por infra partilhada (Setup + Foundational) e depois uma fase por user story (P1→P3).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode executar em paralelo (ficheiros diferentes, sem dependência de tarefas incompletas do mesmo ficheiro)
- **[Story]**: [US1], [US2], [US3] conforme [spec.md](./spec.md)
- Cada descrição inclui caminho absoluto ou relativo ao repo onde a alteração ocorre

## Path Conventions (este repo)

- Imagem e scripts: `docker/Dockerfile`, `docker/entrypoint.sh`, `docker/install-ai-clis.sh`
- Orquestração: `docker-compose.yml`, `.env.example`
- Documentação: `README.md`, `docs/sandbox.md`
- Feature specs: `specs/002-mise-php-node-ai-defaults/*`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Alinhar implementação futura com contratos e pesquisa já fechados.

- [X] T001 Review `specs/002-mise-php-node-ai-defaults/contracts/compose-dev-service.md` and `specs/002-mise-php-node-ai-defaults/contracts/docker-dev-image.md` against `docker-compose.yml` and `docker/Dockerfile`
- [X] T002 [P] Map each decision in `specs/002-mise-php-node-ai-defaults/research.md` to a concrete edit target in `docker/Dockerfile` and `docker/install-ai-clis.sh` (checklist interno; sem mudança de comportamento até Phase 2)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Infra mínima **mise + PHP 8.4 + Node 22** na imagem, visível em shell de login como `dev`.

**⚠️ CRITICAL**: Nenhuma user story está completa até mise/runtimes estarem operacionais no contentor.

- [X] T003 Install mise using the official non-interactive installer and required prerequisites in `docker/Dockerfile`
- [X] T004 Add Ubuntu packages required for mise-managed PHP builds (headers/libs) in `docker/Dockerfile`
- [X] T005 Run `mise install --system php@8.4 node@22` (or equivalent accepted registry versions) during build in `docker/Dockerfile`
- [X] T006 Ensure system-wide/login-shell PATH exposes `mise`, `php`, and `node` for user `dev` without relying on host dotfiles in `docker/Dockerfile`
- [X] T007 Confirm `docker/Dockerfile` still uses `docker/entrypoint.sh` as `ENTRYPOINT` and does not require recursive `chown` changes in `docker/entrypoint.sh`

**Checkpoint**: `docker compose build dev` succeeds with network; `docker compose run --rm dev zsh -l -c 'command -v mise php node'` finds all three.

---

## Phase 3: User Story 1 — Runtimes PHP e Node prontos ao entrar no contentor (Priority: P1) 🎯 MVP

**Goal**: PHP 8.4 e Node 22 por defeito na primeira sessão, sem instalação manual no contentor.

**Independent Test**: Comandos de smoke de runtimes em `specs/002-mise-php-node-ai-defaults/quickstart.md` passam após build limpo.

### Implementation for User Story 1

- [X] T008 [US1] Execute runtime smoke (`php -v`, `node -v`) as documented in `specs/002-mise-php-node-ai-defaults/quickstart.md` using `docker compose run --rm dev` and fix `docker/Dockerfile` if majors diverge from `specs/002-mise-php-node-ai-defaults/contracts/tool-versions.md`
- [X] T009 [US1] Update `specs/002-mise-php-node-ai-defaults/quickstart.md` with exact commands/paths discovered during T008 if they differ from placeholders

**Checkpoint**: User Story 1 verificável só com imagem `dev` + quickstart (sem CLIs ainda se US3 pendente).

---

## Phase 4: User Story 2 — Gestão de versões integrada no ambiente (Priority: P2)

**Goal**: `mise` utilizável de forma previsível para futuras versões/alinhamentos.

**Independent Test**: `mise --version` e `mise ls` funcionam como utilizador `dev` em `zsh -l`.

### Implementation for User Story 2

- [X] T010 [US2] Extend `specs/002-mise-php-node-ai-defaults/quickstart.md` with mise visibility checks (`mise --version`, `mise ls`) consistent with `specs/002-mise-php-node-ai-defaults/contracts/tool-versions.md`
- [X] T011 [US2] Document mise usage, system-wide installs, and common pitfalls (PATH, host dotfiles) in `docs/sandbox.md`

**Checkpoint**: Novo developer segue `docs/sandbox.md` + quickstart para validar mise sem suporte ad hoc.

---

## Phase 5: User Story 3 — Clientes de IA disponíveis sem passo extra no `.env` (Priority: P3)

**Goal**: CLIs de IA instaladas no fluxo padrão de build/imagem sem flag opcional no `.env` dedicada a activar a instalação.

**Independent Test**: Com `.env` mínimo a partir de `.env.example`, após build, comandos de presença das CLIs em `specs/002-mise-php-node-ai-defaults/quickstart.md` passam.

### Implementation for User Story 3

- [X] T012 [US3] Refactor `docker/install-ai-clis.sh` to skip NodeSource setup when an existing `node` on `PATH` already satisfies major 22 (per `specs/002-mise-php-node-ai-defaults/research.md`)
- [X] T013 [US3] Always run `docker/install-ai-clis.sh` during image build and remove `INSTALL_AI_CLIS` conditional gating in `docker/Dockerfile`
- [X] T014 [US3] Remove `INSTALL_AI_CLIS` build-arg wiring (or make it a no-op documented as deprecated) in `docker-compose.yml` to satisfy `specs/002-mise-php-node-ai-defaults/contracts/compose-dev-service.md`
- [X] T015 [P] [US3] Update `INSTALL_AI_CLIS` section in `.env.example` to reflect always-on install (remove toggle or mark deprecated with migration note)
- [X] T016 [US3] Update `README.md` tables (Compose services, quickstart) so AI CLIs and runtimes reflect defaults without `.env` activation step

**Checkpoint**: Build padrão inclui CLIs; nenhum passo documentado obriga editar `.env` só para permitir a sua instalação.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Consistência documental, contratos, validação final.

- [X] T017 [P] Reconcile long-form sandbox guide sections (mise, CLIs, build times) with final behavior in `docs/sandbox.md` and `docker/Dockerfile`
- [X] T018 [P] Update `specs/002-mise-php-node-ai-defaults/contracts/docker-dev-image.md` and `specs/002-mise-php-node-ai-defaults/contracts/compose-dev-service.md` if implementation details diverged from the draft contracts
- [X] T019 Run end-to-end steps in `specs/002-mise-php-node-ai-defaults/quickstart.md` (build + runtimes + mise + CLIs) and capture any follow-up fixes in `README.md` or `docs/sandbox.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Sem dependências externas além do repo.
- **Phase 2 (Foundational)**: Depende de Phase 1 (revisão mental/contratos); **bloqueia** todas as user stories.
- **Phase 3 (US1)**: Depende de Phase 2.
- **Phase 4 (US2)**: Depende de Phase 2; pode iniciar após T006–T007 (mise no PATH) e idealmente após T008 confirma runtimes.
- **Phase 5 (US3)**: Depende de Phase 2 (**Node 22** do mise disponível no build) e de T012–T013 ordenados; T014–T016 documentam/rematem o contrato Compose/env/README.
- **Phase 6 (Polish)**: Depende das fases de stories pretendidas (mínimo US1–US3 para fechar a spec completa).

### User Story Dependencies

- **US1**: Depende só da fundação (mise + runtimes).
- **US2**: Depende da fundação; reforça documentação/verificação de mise (parcialmente overlap com US1, mas testável via `mise` alone).
- **US3**: Depende da fundação + Node do mise; **não** deve reintroduzir Node paralelo via NodeSource salvo fallback explícito em `docker/install-ai-clis.sh`.

### Within Each User Story

- US3: **T012 antes de T013** (script estável antes de fixar `RUN` incondicional no `docker/Dockerfile`).
- US3: T015 e T016 podem correr em paralelo após T014 estar definido (ficheiros distintos).

### Parallel Opportunities

- **Phase 1**: T002 [P] pode ser feito em paralelo com T001 (leituras diferentes).
- **Phase 6**: T017 [P] e T018 [P] em paralelo (ficheiros distintos).
- **US3**: T015 [P] em paralelo com T016 após T014 concluído.

---

## Parallel Example: User Story 3

```bash
# Após T014 concluído, em paralelo:
# Task T015 → editar .env.example
# Task T016 → editar README.md
```

---

## Parallel Example: User Story 1 + US2 (documentação)

```bash
# Após T008 passar, em paralelo:
# Task T009 → quickstart.md (ajustes de comando)
# Task T010 → quickstart.md (secção mise) — coordenar merge se ambos tocarem nas mesmas linhas; idealmente mesmo autor ou PR único
```

---

## Implementation Strategy

### MVP First (User Story 1 apenas)

1. Completar Phase 1 e Phase 2 (T001–T007).
2. Completar Phase 3 (T008–T009) e validar quickstart de runtimes.
3. **Parar e validar**: PHP 8.4 + Node 22 + mise no PATH; CLIs de IA podem ainda depender do estado antigo do Compose até Phase 5.

### Incremental Delivery

1. Fundação (T001–T007) → imagem com mise e runtimes.
2. US1 (T008–T009) → critérios P1 fechados.
3. US2 (T010–T011) → operadores sabem usar mise no sandbox.
4. US3 (T012–T016) → remove fricção `.env` / alinha README.
5. Polish (T017–T019) → contratos + guias + smoke final.

### Parallel Team Strategy

- Dev A: Phase 2 `docker/Dockerfile` (T003–T006).
- Dev B: Phase 1 revisões + rascunho doc `docs/sandbox.md` (só merge após T006).
- Após T007: Dev C: US3 `docker/install-ai-clis.sh` (T012) enquanto Dev A prepara T013.

---

## Notes

- IDs sequenciais T001–T019; cada item de tarefa usa `- [X]` / `- [ ]` + ID + caminho explícito (concluídas marcadas `[X]`).
- Evitar editar `docker/entrypoint.sh` salvo necessidade comprovada (risco em bind mounts).
- Builds requerem rede; documentar falhas em `docs/sandbox.md` quando aplicável (Edge Cases da spec).

---

## Task Summary

| Phase | Task IDs | Count |
|-------|----------|------:|
| Setup | T001–T002 | 2 |
| Foundational | T003–T007 | 5 |
| US1 (P1) | T008–T009 | 2 |
| US2 (P2) | T010–T011 | 2 |
| US3 (P3) | T012–T016 | 5 |
| Polish | T017–T019 | 3 |
| **Total** | T001–T019 | **19** |

| User Story | Tasks | Count |
|------------|-------|------:|
| US1 | T008–T009 | 2 |
| US2 | T010–T011 | 2 |
| US3 | T012–T016 | 5 |

**Format validation**: Todas as linhas de tarefa seguem `- [X] Tnnn ...` com caminho de ficheiro na descrição; `[P]` apenas em T002, T015, T017, T018; labels `[US1]`/`[US2]`/`[US3]` apenas nas fases de user story.
