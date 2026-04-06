---
description: "Task list for 005-dev-shell-home-sudo (shell na home + sudo)"
---

# Tasks: Shell na home do desenvolvedor e privilégios elevados

**Input**: Design documents from `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Não solicitados na spec — sem tarefas de teste automatizado; validação manual via `contracts/` e `quickstart.md`.

**Organization**: Fases por user story (P1 → P2), mais polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode correr em paralelo (ficheiros distintos, sem dependência de tarefas incompletas do mesmo lote)
- **[USn]**: User story da `spec.md`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Contexto e linha de base antes de alterar a imagem

- [x] T001 Rever `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/shell-session.md`, `contracts/sudo-policy.md` e `quickstart.md` em `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Garantir build reprodutível antes das mudanças; nenhuma história de utilizador começa sem este checkpoint

**⚠️ CRITICAL**: Completar Phase 2 antes de aplicar patches ao `Dockerfile` / Compose desta feature

- [x] T002 Executar `docker compose build dev` na raiz `/home/owrasor/Code/owrasor/sandbox` e confirmar conclusão com sucesso (baseline pré-mudança)

**Checkpoint**: Build baseline OK — pode iniciar Phase 3

---

## Phase 3: User Story 1 - Sessão interativa começa na pasta pessoal (Priority: P1) 🎯 MVP

**Goal**: `docker compose exec dev zsh` (e `run`) iniciam com CWD `/home/dev`; montagem do código inalterada em `/home/dev/workspace`.

**Independent Test**: Contrato C1/C2 em `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/contracts/shell-session.md` — `pwd` deve imprimir `/home/dev`.

### Implementation for User Story 1

- [x] T003 [P] [US1] Definir `working_dir: /home/dev` no serviço `dev` em `/home/owrasor/Code/owrasor/sandbox/docker-compose.yml`
- [x] T004 [P] [US1] Alterar `WORKDIR` de `/home/dev/workspace` para `/home/dev` em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile`
- [x] T005 [US1] Actualizar menções ao diretório inicial do compose (incluir `cd workspace` para o código montado) em `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md`
- [x] T006 [US1] Rebuild e validar C1 e C2: executar na raiz `/home/owrasor/Code/owrasor/sandbox` os comandos documentados em `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/contracts/shell-session.md` e confirmar saída `/home/dev`

**Checkpoint**: User Story 1 verificável de forma independente (home + doc + contrato shell)

---

## Phase 4: User Story 2 - Tarefas de manutenção com privilégios elevados (Priority: P2)

**Goal**: Utilizador `dev` com `sudo` NOPASSWD dentro do contentor (ver `research.md`).

**Independent Test**: Contrato S1–S3 em `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/contracts/sudo-policy.md`.

### Implementation for User Story 2

- [x] T007 [US2] Adicionar instalação do pacote `sudo` e ficheiro em `/etc/sudoers.d/` com `dev ALL=(ALL) NOPASSWD:ALL` (perm `0440`) via `RUN` em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile`, conforme decisões em `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/research.md`
- [x] T008 [US2] Documentar fluxo de verificação de `sudo` (comandos ou ligação ao quickstart) em `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md`
- [x] T009 [US2] Rebuild e validar S1–S3 na raiz `/home/owrasor/Code/owrasor/sandbox` conforme `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/contracts/sudo-policy.md`

**Checkpoint**: User Stories 1 e 2 verificáveis independentemente (sudo não altera CWD acordado)

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: FR-003/FR-004 e consistência documental

- [x] T010 [P] Pesquisar e corrigir menções desactualizadas ao diretório inicial `/home/dev/workspace` em `/home/owrasor/Code/owrasor/sandbox/README.md` e ficheiros sob `/home/owrasor/Code/owrasor/sandbox/docs/` (excluir referências legítimas ao caminho de mount)
- [x] T011 Executar na raiz `/home/owrasor/Code/owrasor/sandbox` todas as secções de `/home/owrasor/Code/owrasor/sandbox/specs/005-dev-shell-home-sudo/quickstart.md` e corrigir gaps se algum passo falhar

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1** → **Phase 2** → **Phase 3 (US1)** → **Phase 4 (US2)** → **Phase 5**
- **US2** edita o mesmo ficheiro `docker/Dockerfile` que **US1** (T004): concluir T003–T006 antes de T007 para reduzir conflitos de merge e validar US1 isoladamente.

### User Story Dependencies

- **US1 (P1)**: Depende apenas de Phase 2; **MVP** = Phases 1–3 concluídas.
- **US2 (P2)**: Depende de Phase 2; recomenda-se aplicar **depois** de US1 no `Dockerfile` (T007 após T004). Funcionalmente o sudo poderia ser implementado primeiro, mas a ordem acima prioriza o MVP e evita diffs concorrentes no mesmo `RUN`.

### Parallel Opportunities

- **T003 [P] [US1]** e **T004 [P] [US1]** — ficheiros diferentes (`docker-compose.yml` vs `docker/Dockerfile`); ambos devem estar merged antes de **T006** (build único).
- **T010 [P]** — pode ser feito em paralelo com **T008** ou **T009** se recursos humanos distintos e após existirem menções estáveis em `docs/sandbox.md` (coordenar para não editar o mesmo parágrafo em simultâneo).

---

## Parallel Example: User Story 1

```bash
# Após T002, lançar em paralelo (dois contribuidores ou dois commits antes do build):
# T003: editar /home/owrasor/Code/owrasor/sandbox/docker-compose.yml
# T004: editar /home/owrasor/Code/owrasor/sandbox/docker/Dockerfile

# Depois, sequencial:
# T005 → docker compose build dev → T006 (contrato shell-session)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 + Phase 2  
2. Phase 3 (T003–T006)  
3. **Parar e validar**: contrato `contracts/shell-session.md` e critérios de US1 na `spec.md`

### Incremental Delivery

1. MVP (US1) → demo “entro na home”  
2. US2 (T007–T009) → demo “instalo pacote com sudo”  
3. Polish (T010–T011) → documentação e regressões cruzadas

### Parallel Team Strategy

- Após T002: Developer A em T003, Developer B em T004 → integrar → T005/T006 por uma pessoa.  
- US2: uma pessoa no `Dockerfile` (T007) para evitar conflitos.

---

## Notes

- Cada tarefa inclui caminho absoluto ou raiz do repo explícita para execução de comandos.  
- Sem `[US*]` em Setup, Foundational e Polish, conforme regras do gerador.  
- `docker/entrypoint.sh` não requer alteração para esta feature (ver `plan.md`).
