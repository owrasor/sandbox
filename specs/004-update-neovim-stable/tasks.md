---
description: "Task list for Neovim estável oficial na imagem dev (004-update-neovim-stable)"
---

# Tasks: Neovim estável oficial na imagem dev

**Input**: Design documents from `/home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/`  
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md  

**Tests**: Não solicitados na spec — validação por comandos documentados em `contracts/version-check.md` e `quickstart.md`.

**Organization**: Fases por user story (P1 → P2), com infra partilhada na Fase 2.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode correr em paralelo (ficheiros diferentes, sem dependência de tarefas incompletas do mesmo ficheiro)
- **[Story]**: US1, US2 (mapeamento da spec)
- Caminhos absolutos nas descrições

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Alinhar execução com artefactos da feature antes de editar a imagem.

- [x] T001 Read-only review of acceptance commands and pin decision in /home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/contracts/version-check.md and /home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/research.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Alterações na imagem Docker que **bloqueiam** qualquer verificação de versão e toda a documentação dependente.

**⚠️ CRITICAL**: Nenhuma história de utilizador está completa até a imagem construir e expor `nvim` correctamente.

- [x] T002 Remove the `neovim` package from the `apt-get install` list in /home/owrasor/Code/owrasor/sandbox/docker/Dockerfile
- [x] T003 Add `ARG NEOVIM_VERSION=v0.12.1` and a `RUN` that downloads `https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz`, extracts to `/opt/nvim-linux-x86_64`, and removes the archive in /home/owrasor/Code/owrasor/sandbox/docker/Dockerfile
- [x] T004 Prepend `/opt/nvim-linux-x86_64/bin` to `PATH` for login shells via `/etc/profile.d/` and ensure zsh login loads it (mirror the existing mise pattern) in /home/owrasor/Code/owrasor/sandbox/docker/Dockerfile

**Checkpoint**: Dockerfile pronto para build — avançar para validação US1.

---

## Phase 3: User Story 1 - Ambiente com editor estável atual (Priority: P1) 🎯 MVP

**Goal**: Ambiente dev padrão passa a usar Neovim estável upstream (tarball oficial), com `nvim` resolvido para `/opt/nvim-linux-x86_64/bin/nvim`.

**Independent Test**: A partir da raiz do repo, `docker compose build dev` seguido de `docker compose run --rm dev bash -lc 'command -v nvim && nvim --version | head -1'` cumpre /home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/contracts/version-check.md.

### Implementation for User Story 1

- [x] T005 [US1] Run `docker compose build dev` from /home/owrasor/Code/owrasor/sandbox and resolve any build failures tied to Neovim installation steps
- [x] T006 [US1] Run `docker compose run --rm dev bash -lc 'command -v nvim && nvim --version | head -1'` from /home/owrasor/Code/owrasor/sandbox and confirm output matches /home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/contracts/version-check.md
- [x] T007 [US1] Run `docker compose run --rm dev bash -lc 'nvim --headless +q'` from /home/owrasor/Code/owrasor/sandbox and confirm exit code 0

**Checkpoint**: US1 verificável sem depender de updates a `docs/`.

---

## Phase 4: User Story 2 - Verificação objetiva pela equipe (Priority: P2)

**Goal**: Documentação e inventário reflectem canal upstream, versão pinada e removem a excepção P1 antiga; qualquer pessoa replica a verificação em ≤ 5 minutos usando o repo.

**Independent Test**: Um mantenedor segue apenas ficheiros em `docs/dev-environment/` + README + `contracts/version-check.md` e confirma paridade com a versão observada no contentor, sem passos não documentados.

### Implementation for User Story 2

- [x] T008 [P] [US2] Update the `nvim-editor` capability row (supplier, version, exception status) in /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md
- [x] T009 [P] [US2] Update Neovim platform evaluation and exception-closure guidance in /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/platform-evaluation.md
- [x] T010 [P] [US2] Align the Neovim policy row with upstream tarball channel in /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/freshness-policy.md
- [x] T011 [P] [US2] Adjust expected `nvim --version` wording in audit examples in /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audit-template.md
- [x] T012 [US2] Refresh observed `nvim` version output and checklist bullets in /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/2026-Q2-01.md using the same verify commands as T006–T007
- [x] T013 [P] [US2] Update the dev stack table Neovim description in /home/owrasor/Code/owrasor/sandbox/README.md
- [x] T014 [P] [US2] Scan /home/owrasor/Code/owrasor/sandbox/docs/sandbox.md for stale Neovim version or install claims and update to match the new image behavior

**Checkpoint**: US1 + US2 completos — imagem e documentação coerentes.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Fechos transversais e validação final do quickstart da feature.

- [x] T015 [P] Search under /home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/ and /home/owrasor/Code/owrasor/sandbox/docs/ for remaining `0.9.5` / apt-only Neovim claims; update files only where still inaccurate after T008–T014
- [x] T016 Execute every command sequence in /home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/quickstart.md from /home/owrasor/Code/owrasor/sandbox and fix any doc or Dockerfile mismatch discovered

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** → **Phase 2** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5**
- **US2** depende de **US1**: T008–T014 devem reflectir a versão real observada após T006–T007 (T012 explicitamente).

### User Story Dependencies

- **US1 (P1)**: Depende apenas de Phase 2 (Dockerfile). Não depende de US2.
- **US2 (P2)**: Depende de US1 para valores observados e comandos de verificação estáveis.

### Within Each User Story

- **US1**: T005 antes de T006 e T007 (build antes de run).
- **US2**: T008–T011 e T013–T014 podem avançar em paralelo **após** existir output confirmado de T006; **T012** deve incorporar esse output (idealmente após T006–T007).

### Parallel Opportunities

- **US2**: T008, T009, T010, T011, T013, T014 em paralelo entre si (ficheiros distintos), com T012 a fechar o relatório de auditoria.
- **Polish**: T015 [P] independente de outros ficheiros; T016 por último.

---

## Parallel Example: User Story 2

```text
# Após T006–T007 concluídos, em paralelo (subagentes / devs diferentes):
Task T008 → /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md
Task T009 → /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/platform-evaluation.md
Task T010 → /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/freshness-policy.md
Task T011 → /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audit-template.md
Task T013 → /home/owrasor/Code/owrasor/sandbox/README.md
Task T014 → /home/owrasor/Code/owrasor/sandbox/docs/sandbox.md

# Depois, sequencial:
Task T012 → /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/2026-Q2-01.md
```

---

## Parallel Example: User Story 1

```text
# Sequencial (mesmo contentor / mesma pipeline):
Task T005 → docker compose build dev
Task T006 → docker compose run --rm dev bash -lc 'command -v nvim && nvim --version | head -1'
Task T007 → docker compose run --rm dev bash -lc 'nvim --headless +q'
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Completar Phase 1 e Phase 2 (Dockerfile).  
2. Completar Phase 3 (T005–T007).  
3. **Parar e validar** US1 com `contracts/version-check.md`.  
4. Opcional: demo interna “imagem rebuild + nvim stable”.

### Incremental Delivery

1. Phase 1–3 → **MVP** (editor estável na imagem).  
2. Phase 4 → documentação e inventário alinhados (US2).  
3. Phase 5 → varredura residual + quickstart.

### Parallel Team Strategy

- Dev A: Phase 2 (Dockerfile T002–T004) + US1 (T005–T007).  
- Após T006–T007: Dev B/C em paralelo nos ficheiros `docs/` (T008–T011, T013–T014); um dev fecha T012.  
- Dev A: T015–T016.

---

## Notes

- Pin `NEOVIM_VERSION` em Dockerfile; ao bump futuro, actualizar T012, inventário e contrato na mesma entrega.  
- Não introduzir segundo `nvim` no `PATH` (requisito do contract).  
- Commits pequenos por fase ou por tarefa lógica.
