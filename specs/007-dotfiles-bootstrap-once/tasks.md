---
description: "Task list for feature 007-dotfiles-bootstrap-once"
---

# Tasks: Arranque único de script de dotfiles configurável

**Input**: Design documents from `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/`  
**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: Não solicitados na spec — validação manual via `contracts/bootstrap-once.md` e [quickstart.md](./quickstart.md).

**Organization**: Fases por user story (P1→P3); a lógica partilhada vive na Phase 2 (foundational) num único script Bash.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Paralelizável (ficheiros distintos, sem dependência de tarefas incompletas do mesmo ramo)
- **[Story]**: [US1]…[US3] nas fases de história; omitido em Setup, Foundational e Polish

## Path Conventions

Alterações em `docker/`, raiz do repo (`.gitignore`, `.env.example`), `docker-compose.yml`, `docs/sandbox.md`, e specs desta feature — conforme [plan.md](./plan.md).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Ignorar estado local e documentar variável no modelo `.env`.

- [x] T001 [P] Adicionar padrão de ignorados para o directório de estado do bootstrap (ex.: `workspace/.sandbox/`) em `/home/owrasor/Code/owrasor/sandbox/.gitignore`
- [x] T002 [P] Documentar `DOTFILES_BOOTSTRAP_SCRIPT` (opcional, nome de ficheiro no topo de `/home/dev/dotfiles`) em `/home/owrasor/Code/owrasor/sandbox/.env.example`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Script de orquestração, hook Zsh e imagem — **bloqueia** documentação orientada a comportamento e validações manuais das user stories.

**⚠️ CRITICAL**: Nenhuma fase de user story pode concluir-se sem o contentor executar o hook e o script estarem instalados.

- [x] T003 Implementar em `/home/owrasor/Code/owrasor/sandbox/docker/sandbox-dotfiles-bootstrap.sh` a lógica completa alinhada a [data-model.md](./data-model.md) e [research.md](./research.md): saída imediata se `SANDBOX_DOTFILES_BOOTSTRAP_SKIP` estiver definido; saída imediata se variável `DOTFILES_BOOTSTRAP_SCRIPT` ausente ou vazia; saída imediata se marcador de sucesso existir; validação **basename** seguro (sem `/`, sem `..`); caminho canónico sob `/home/dev/dotfiles`; ramo **ficheiro inexistente** com mensagem em stderr, **sem** marcador de sucesso, exit 0 para não bloquear Zsh; `flock` em lockfile no mesmo estado que o marcador; executar script do utilizador com `bash`; gravar marcador **apenas** em exit 0; directório de estado sob `/home/dev/workspace/.sandbox/` com `mkdir -p`
- [x] T004 [P] Criar snippet Zsh em `/home/owrasor/Code/owrasor/sandbox/docker/zshenv-sandbox-bootstrap.snippet` que invoca `/usr/local/bin/sandbox-dotfiles-bootstrap.sh` de forma compatível com **qualquer** arranque de `zsh` (incl. não-interactivo), sem poluir ambientes que não sejam o contentor `dev` se possível (ex.: guarda mínima)
- [x] T005 Actualizar `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` para `COPY` de `sandbox-dotfiles-bootstrap.sh` para `/usr/local/bin/sandbox-dotfiles-bootstrap.sh`, permissões executáveis, e integrar `zshenv-sandbox-bootstrap.snippet` em `/etc/zsh/zshenv` (append ou `RUN` explícito) sem quebrar Neovim/mise/profile existentes
- [x] T006 [P] Rever `/home/owrasor/Code/owrasor/sandbox/docker-compose.yml` serviço `dev` e garantir que `DOTFILES_BOOTSTRAP_SCRIPT` (e opcional `SANDBOX_DOTFILES_BOOTSTRAP_SKIP`) chegam ao contentor via `env_file: .env`; acrescentar `environment:` só se `env_file` for insuficiente, com comentário YAML

**Checkpoint**: `docker compose build dev` produz imagem com script e hook; script satisfaz FR-001–FR-007 em código.

---

## Phase 3: User Story 1 - Configurar e executar um arranque pessoal uma única vez (Priority: P1) 🎯 MVP

**Goal**: Primeira sessão Zsh válida executa o script do utilizador uma vez e persiste sucesso; sessões seguintes com o mesmo workspace não reexecutam.

**Independent Test**: Variável definida no `.env`, ficheiro presente em dotfiles, sem marcador prévio → uma execução e marcador após sucesso; segundo arranque → sem nova execução (cenários **B1/B2** em [contracts/bootstrap-once.md](./contracts/bootstrap-once.md)).

- [x] T007 [US1] Documentar em `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` o fluxo P1: variável `DOTFILES_BOOTSTRAP_SCRIPT`, localização do script no mount `dotfiles`, caminho do marcador em `workspace/.sandbox/`, e como repor a “primeira vez” (apagar marcador)
- [x] T008 [US1] Executar validação manual dos cenários **B1** e **B2** descritos em `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/contracts/bootstrap-once.md` a partir da raiz do repo; se comandos ou caminhos divergirem, corrigir primeiro `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/quickstart.md`

**Checkpoint**: MVP da feature verificável com workspace persistente.

---

## Phase 4: User Story 2 - Desactivar ou omitir o arranque sem erros (Priority: P2)

**Goal**: Variável vazia/ausente ou ficheiro em falta não bloqueia a shell e não cria falso “já concluído”.

**Independent Test**: Cenários **B3** e **B4** em [contracts/bootstrap-once.md](./contracts/bootstrap-once.md).

- [x] T009 [P] [US2] Documentar em `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` comportamento para variável vazia/ausente e para ficheiro inexistente (stderr visível, shell disponível), alinhado a [contracts/env-variables.md](./contracts/env-variables.md)
- [x] T010 [US2] Executar validação manual dos cenários **B3** e **B4** em `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/contracts/bootstrap-once.md`; ajustar `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` ou `/home/owrasor/Code/owrasor/sandbox/docker/sandbox-dotfiles-bootstrap.sh` se o comportamento não coincidir com a spec

**Checkpoint**: US2 verificável independentemente de US1 (por cenários distintos no mesmo binário).

---

## Phase 5: User Story 3 - Falhas do script não corrompem o estado “uma vez” (Priority: P3)

**Goal**: Falha do script do utilizador não grava marcador de sucesso; após correcção, nova tentativa é possível.

**Independent Test**: Cenário **B5** em [contracts/bootstrap-once.md](./contracts/bootstrap-once.md).

- [x] T011 [P] [US3] Documentar em `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` retry após falha, exit codes, e expectativa de scripts não-interactivos (cf. Assumptions em [spec.md](./spec.md))
- [x] T012 [US3] Executar validação manual do cenário **B5** em `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/contracts/bootstrap-once.md`; confirmar ausência de marcador após `exit 1` e sucesso após correcção do script de teste

**Checkpoint**: US3 coberto por comportamento e documentação.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Consistência entre artefactos e guia rápido.

- [x] T013 [P] Actualizar `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/quickstart.md` com caminhos finais do marcador, nome exacto da variável, e comandos `docker compose` coincidentes com a implementação em `/home/owrasor/Code/owrasor/sandbox/docker/sandbox-dotfiles-bootstrap.sh`
- [x] T014 Incluir em `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` nota de segurança: apenas nomes seguros no topo de `dotfiles`, sem path traversal (cf. [research.md](./research.md) §4)
- [x] T015 Percorrer integralmente os passos finais de `/home/owrasor/Code/owrasor/sandbox/specs/007-dotfiles-bootstrap-once/quickstart.md` na máquina local e corrigir discrepâncias em `docs/sandbox.md` ou no script em `/home/owrasor/Code/owrasor/sandbox/docker/sandbox-dotfiles-bootstrap.sh` até o guia funcionar de ponta a ponta

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Sem dependências externas; T001 e T002 em paralelo.
- **Phase 2**: Depende da Phase 1 para `.gitignore` (evitar commit acidental de estado durante testes). **T003** e **T004** podem avançar em paralelo; **T005** depende de **T003** e **T004**; **T006** pode paralelizar com **T005** se a edição do Compose for só verificação/documentação, mas validar compose após **T005** antes de fechar a fase.
- **Phases 3–5**: Dependem da Phase 2 completa (imagem com hook + script).
- **Phase 6**: Depende das fases 3–5 desejadas (mínimo: Phase 3 para MVP documentado).

### User Story Dependencies

- **US1 (P1)**: Depende só da Phase 2 — sem dependência de US2/US3.
- **US2 (P2)**: Comportamento já no script da Phase 2; fase US2 = docs + validação B3/B4.
- **US3 (P3)**: Idem; fase US3 = docs + validação B5.
- Ordem recomendada: US1 → US2 → US3 (prioridade spec); US2/US3 podem sobrepor-se após build se os cenários manuais forem executados em sequência.

### Within Each User Story

- Documentação (`docs/sandbox.md`) antes ou em paralelo com validação manual que a confirme.
- Ajustes ao script em **T010**/**T015** só se a validação falhar.

### Parallel Opportunities

- **Phase 1**: T001 ∥ T002
- **Phase 2**: T003 ∥ T004; T006 ∥ T005 (com cautela — validar integração após ambos)
- **Phase 3–5**: T009 ∥ T007 (secções distintas do mesmo ficheiro — preferir secções separadas ou serializar edições em `docs/sandbox.md` para evitar conflitos); T011 paralelizável com T009 apenas se editores coordenarem merges em `docs/sandbox.md`
- **Phase 6**: T013 ∥ T014 (ficheiros diferentes)

---

## Parallel Example: User Story 1

Após Phase 2 completa:

```text
# Documentação (ficheiro único — serializar se necessário):
T007 → docs/sandbox.md secção P1

# Depois, validação que usa o mesmo repo:
T008 → executar B1/B2 conforme contracts/bootstrap-once.md
```

---

## Parallel Example: Phase 2 (core)

```text
T003 → docker/sandbox-dotfiles-bootstrap.sh
T004 → docker/zshenv-sandbox-bootstrap.snippet
# Em seguida, obrigatório:
T005 → docker/Dockerfile (depende de T003 + T004)
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1 (T001–T002)  
2. Phase 2 (T003–T006) — **crítico**  
3. Phase 3 (T007–T008) — documentar e validar B1/B2  
4. **Parar e validar**: fluxo “uma vez” funcional com workspace persistente  

### Incremental Delivery

1. Setup + Foundational → contentor com bootstrap funcional  
2. + US1 → docs + B1/B2  
3. + US2 → docs + B3/B4  
4. + US3 → docs + B5  
5. Polish → quickstart e notas de segurança alinhadas  

### Parallel Team Strategy

- Developer A: T003 (script)  
- Developer B: T004 (zshenv) + T001/T002  
- Integração: T005 por quem fechar Dockerfile após merge conceptual dos paths  

---

## Notes

- IDs sequenciais T001–T015; cada linha inclui checkbox, ID e caminhos absolutos onde aplicável.  
- Tarefas de “validação manual” referenciam explicitamente `specs/007-dotfiles-bootstrap-once/contracts/bootstrap-once.md`.  
- Não há tarefas de teste automatizado (não pedido na spec).  

---

## Task Summary

| Métrica | Valor |
|---------|--------|
| **Total de tarefas** | 15 |
| **Setup (Phase 1)** | 2 |
| **Foundational (Phase 2)** | 4 |
| **US1 (Phase 3)** | 2 |
| **US2 (Phase 4)** | 2 |
| **US3 (Phase 5)** | 2 |
| **Polish (Phase 6)** | 3 |
| **Marcadas [P]** | 8 oportunidades de paralelismo (com ressalvas em `docs/sandbox.md`) |

**MVP sugerido**: Phases 1–3 (T001–T008).  
**Formato**: Todas as tarefas usam `- [ ] Tnnn ...` com caminhos de ficheiro na descrição.
