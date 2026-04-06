---
description: "Task list for 003-current-stable-packages (governação do ambiente dev)"
---

# Tasks: Ambiente de desenvolvimento com pacotes estáveis recentes

**Input**: Design documents from `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Não solicitados na spec — sem tarefas de teste automatizado.

**Organization**: Fases por user story (P1 → P2 → P3) após setup e fundação documental.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode correr em paralelo (ficheiros diferentes, sem dependência de conteúdo incompleto da outra tarefa)
- **[Story]**: Apenas nas fases de User Story ([US1], [US2], [US3])
- Caminhos relativos à raiz do repositório: `/home/owrasor/Code/owrasor/sandbox/`

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Criar estrutura de documentação acordada no `plan.md`

- [x] T001 Create directory `docs/dev-environment/` at repository root `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/`
- [x] T002 Create index file `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/README.md` describing purpose, owners, and links to policy, inventory, evaluation, audits, and spec feature folder `specs/003-current-stable-packages/` (after T001)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Scaffolds que todas as user stories dependem para não duplicar estrutura

**⚠️ CRITICAL**: Nenhuma user story deve preencher conteúdo normativo antes disto

- [x] T003 Create `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/freshness-policy.md` with all mandatory **section headings** from `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/contracts/freshness-policy.md` (placeholder body permitted)

**Checkpoint**: Fundação documental pronta — US1 pode preencher política e inventário

---

## Phase 3: User Story 1 - Ferramentas alinhadas com versões estáveis recentes (Priority: P1) 🎯 MVP

**Goal**: Política de frescura completa, inventário priorizado, primeiro registo de auditoria e conformidade P1 verificável (FR-001, FR-002, FR-003, FR-005, SC-001, SC-002)

**Independent Test**: Executar passos em `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/quickstart.md` secções 1–2; ≥90% itens P1 `ok` ou excepção documentada

### Implementation for User Story 1

- [x] T004 [US1] Complete mandatory sections in `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/freshness-policy.md` with concrete SLAs (≥3 numeric metrics/prazos), exception workflow, and audit cadence per `research.md` and `contracts/freshness-policy.md`
- [x] T005 [P] [US1] Create `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audit-template.md` mirroring fields from `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/data-model.md` entity `audit-record`
- [x] T006 [US1] Create `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md` per `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/contracts/capability-inventory.md` including rows for tools installed in `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` and mise pins (php, node) with criticidade P1/P2/P3 and owners
- [x] T007 [US1] Create directory `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/` and first audit file `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/2026-Q2-01.md` populated from `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audit-template.md` with inventory snapshot date and compliance summary
- [x] T008 [US1] Update `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md` and `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/2026-Q2-01.md` with observed versions from `docker compose build dev` and `docker compose run --rm dev bash -lc 'php -v; node -v; nvim --version | head -1'` run from `/home/owrasor/Code/owrasor/sandbox/`, recording supplier latest-stable references for each P1 row

**Checkpoint**: US1 entregue — política + inventário + primeira auditoria verificável

---

## Phase 4: User Story 2 - Decisão informada sobre a plataforma base (Priority: P2)

**Goal**: Relatório de avaliação da plataforma base com opções, riscos e recomendação (FR-004, SC-003)

**Independent Test**: Leitor identifica recomendação `manter` / `migrar` / `adiar`, riscos por opção, e duas assinaturas (autor + revisor) em `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/platform-evaluation.md`

### Implementation for User Story 2

- [x] T009 [US2] Author `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/platform-evaluation.md` satisfying `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/contracts/platform-evaluation.md`, incorporating decisions from `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/research.md` (LTS+mise vs rolling)
- [x] T010 [US2] Add completed author and reviewer identification (names or handles) and dates to metadata section in `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/platform-evaluation.md` for SC-003

**Checkpoint**: US2 entregue — avaliação revista por par

---

## Phase 5: User Story 3 - Equilíbrio entre frescura e previsibilidade (Priority: P3)

**Goal**: Procedimento explícito de linha de base reprodutível e anúncio de migrações incompatíveis (FR-006, acceptance scenarios US3)

**Independent Test**: Secção consultável em política ou doc dedicado descreve como referenciar baseline para incidentes e como publicar notas de migração antes de mudanças incompatíveis

### Implementation for User Story 3

- [x] T011 [US3] Add baseline reference workflow (image tag, git SHA, or inventory snapshot procedure) and incompatible-upgrade announcement checklist to `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/freshness-policy.md` (or create `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/baseline-procedure.md` and link it from `freshness-policy.md` if length warrants)

**Checkpoint**: US3 entregue — FR-006 documentado

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Descoberta, ligações transversais, validação final, inquérito SC-004

- [x] T012 [P] Add prominent link from `/home/owrasor/Code/owrasor/sandbox/README.md` to `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/README.md`
- [x] T013 [P] Add short section or bullet in `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` pointing to `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/freshness-policy.md` for container freshness governance
- [x] T014 Reconcile `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md` channel and version columns with actual `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` and `/home/owrasor/Code/owrasor/sandbox/docker-compose.yml` after any drift; note discrepancies in `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/2026-Q2-01.md` if needed
- [x] T015 Run full validation from `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/quickstart.md` and patch documentation gaps in `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/` until all steps pass
- [x] T016 [P] Run team survey for SC-004 (Likert 1–5) and append median and response count to `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/README.md` or `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/audits/2026-Q2-01.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Sem dependências externas
- **Phase 2 (Foundational)**: Depende de Phase 1 (`docs/dev-environment/` existe)
- **Phase 3 (US1)**: Depende de Phase 2 (scaffold da política)
- **Phase 4 (US2)**: Depende de Phase 3 para dados reais no inventário/auditoria citados na avaliação (pode redigir em paralelo após T006 se se usarem placeholders explícitos — recomendado sequencial após T008)
- **Phase 5 (US3)**: Depende de T004 (política final) no mínimo
- **Phase 6 (Polish)**: Depende de US1–US3 desejados; T015 depende do resto

### User Story Dependencies

- **US1**: Após Foundational; sem dependência de US2/US3
- **US2**: Logicamente após US1 para inventário/auditoria concretos; texto inicial pode começar após T003 se necessário
- **US3**: Após política completa (T004)

### Within Each User Story

- US1: T004 → T006 → T007 → T008; T005 paralelo a T004
- US2: T009 → T010
- US3: T011 standalone após T004

### Parallel Opportunities

- **Phase 1**: T002 [P] após T001 (se README for independente — executar após diretório criado; T001 e T002 não [P] entre si se T002 precisa do diretório — manter ordem T001 then T002, ou T001 cria dir e T002 [P] na mesma “batch” após T001 commit)
- **US1**: T005 [P] em paralelo com T004
- **Polish**: T012, T013, T016 [P] entre si; T014 e T015 sequenciais recomendados

---

## Parallel Example: User Story 1

```text
Após T003 completo:
- Developer A: T004 (preenche freshness-policy.md)
- Developer B: T005 (audit-template.md)
Depois:
- Developer A: T006 → T007 → T008 (inventário + auditoria + versões medidas)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1 + Phase 2
2. Phase 3 (US1) até T008
3. **STOP**: validar com `quickstart.md` secções 1–2
4. Demo interna da política + inventário + primeira auditoria

### Incremental Delivery

1. Setup + Foundational → estrutura estável
2. US1 → MVP verificável (SC-001, SC-002)
3. US2 → decisão de plataforma registada (SC-003)
4. US3 → baseline e migrações (FR-006)
5. Polish → links, reconciliação Dockerfile, inquérito SC-004

### Parallel Team Strategy

- Após T003: uma pessoa em T004+T006+T007+T008, outra em T005; depois US2 e US3 em paralelo se equipa >1

---

## Notes

- T016 depende de canal humano (formulário); registar resultado no repo cumpre SC-004
- Se `platform-evaluation.md` recomendar migração rolling, abrir nova feature/implementação Docker — fora do âmbito mínimo desta lista salvo decisão explícita no relatório
