---
description: "Task list for Angie reverse proxy (.test + HTTPS)"
---

# Tasks: Angie — proxy reverso para `*.test` com HTTPS

**Input**: Design documents from `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/`  
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`

**Tests**: Não incluídos — a especificação não pede TDD nem suite automatizada; validação manual via `quickstart.md`, `curl` e `angie -t`.

**Organization**: Fases por infra partilhada → user stories P1→P3 → polish.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode correr em paralelo (ficheiros distintos, sem dependência de tarefas incompletas no mesmo ficheiro)
- **[Story]**: `[US1]`…`[US3]` apenas nas fases de user story
- Caminhos absolutos onde ajuda à execução por um agente

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Estrutura de pastas e política de segredos antes de qualquer serviço novo.

- [X] T001 Create directories `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/` and `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/sites/` (virtual hosts `.test`) per `plan.md`
- [X] T002 [P] Add `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/certs/README.md` documenting expected certificate/key basenames, mkcert commands, and that PEM files must not be committed
- [X] T003 [P] Append ignore rules for `docker/angie/certs/*.pem`, `docker/angie/certs/*-key.pem`, and optionally `docker/angie/certs/` to `/home/owrasor/Code/owrasor/development_enviroment/.gitignore`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Serviço Compose e config global mínima para o contentor Angie arrancar e aceitar includes — **bloqueia todas as user stories**.

**⚠️ CRITICAL**: Nenhum trabalho US1/US2/US3 até esta fase estar completa.

- [X] T004 Add pinned `angie` service (`docker.angie.software/angie:<TAG>`), `sandbox` network, host ports `80:80` and `443:443`, and read-only volume mounts for config and certs to `/home/owrasor/Code/owrasor/development_enviroment/docker-compose.yml` per `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/contracts/compose-angie-service.md` and official Angie Docker documentation
- [X] T005 Create `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/angie.conf` with `http` (or image-required top-level) and `include` of `sites/*.conf` using paths that match the mounted directories inside the container image
- [X] T006 Add `depends_on: [dev]` to the `angie` service in `/home/owrasor/Code/owrasor/development_enviroment/docker-compose.yml` if startup ordering should guarantee `dev` exists before proxy traffic is tested

**Checkpoint**: `docker compose config` válido; contentor Angie sobe com config vazia ou só includes sem `server` ainda, conforme política da imagem (se a imagem exigir pelo menos um `server`, completar T007 logo na sequência antes de marcar fundação fechada).

---

## Phase 3: User Story 1 — Hostname `.test` → serviço certo (Priority: P1) 🎯 MVP

**Goal**: Pedidos a `https://<app>.test` (ou HTTP conforme política) encaminham para upstream na rede Docker (ex. `dev:5173`).

**Independent Test**: Com hosts/DNS local e certs gerados, `curl -k https://exemplo.test/` devolve corpo do upstream; ver `spec.md` cenário 1.

### Implementation for User Story 1

- [X] T007 [US1] Create `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/sites/example-app.test.conf` with `server_name`, `listen 443 ssl`, `ssl_certificate` and `ssl_certificate_key` pointing to PEM paths inside the container mount, and `location /` with `proxy_pass http://dev:5173` (adjust port to match app)
- [X] T008 [US1] Add complementary `listen 80` behavior in `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/sites/example-app.test.conf` (redirect to HTTPS or explicit HTTP policy per `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/spec.md`)
- [X] T009 [US1] Update `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/quickstart.md` with concrete `/etc/hosts` example for `example-app.test`, `curl -k https://example-app.test/` check, and prerequisite that certs exist under `docker/angie/certs/`

**Checkpoint**: US1 verificável isoladamente com app a escutar no upstream escolhido.

---

## Phase 4: User Story 2 — TLS local confiável no browser (Priority: P2)

**Goal**: HTTPS sem avisos após confiar na CA local (mkcert); cabeçalhos de proxy corretos para apps.

**Independent Test**: Browser abre `https://*.test` sem erro de certificado após `quickstart.md`; handshake na 443.

### Implementation for User Story 2

- [X] T010 [P] [US2] Add `proxy_set_header Host $host`, `X-Forwarded-For $proxy_add_x_forwarded_for`, and `X-Forwarded-Proto $scheme` to the `location` block in `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/sites/example-app.test.conf`
- [X] T011 [US2] Expand `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/quickstart.md` with mkcert `-install`, wildcard `*.test` generation, renaming/mapping PEM filenames to match `ssl_certificate` paths, and browser-trust verification steps
- [X] T012 [US2] Document upstream-down (`502`/`504`) and TLS handshake failures in `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/quickstart.md` per edge cases in `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/spec.md` (after T011 on the same file)

**Checkpoint**: US2 verificável sem depender de alterações ao Compose além do já entregue na fundação.

---

## Phase 5: User Story 3 — Integração com stack Docker existente (Priority: P3)

**Goal**: Variáveis documentadas, `docs/sandbox.md` alinhado, portas do `dev` preservadas, stack reprodutível por outro developer.

**Independent Test**: `docker compose` sobe `angie` + `dev`; mapeamentos `3000`/`8080`/`5173` do `dev` intactos; outro developer segue docs.

### Implementation for User Story 3

- [X] T013 [P] [US3] Add `ANGIE_CERTS_HOST` (optional absolute host path) and short comments for Angie ports `80`/`443` to `/home/owrasor/Code/owrasor/development_enviroment/.env.example`
- [X] T014 [US3] Add section Angie + `.test` + HTTPS to `/home/owrasor/Code/owrasor/development_enviroment/docs/sandbox.md` linking to `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/quickstart.md` and documenting `docker compose up` including `angie`
- [X] T015 [P] [US3] Verify and preserve `dev` service published ports `3000`, `8080`, and `5173` in `/home/owrasor/Code/owrasor/development_enviroment/docker-compose.yml` while integrating `angie` (document any intentional change in `docs/sandbox.md`)

**Checkpoint**: US3 satisfeita com documentação e Compose consistentes com contratos.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validação final, contratos sincronizados, edge cases de operação.

- [X] T016 Run configuration syntax test for Angie (`angie -t` or equivalent per image) and document exact command in `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/quickstart.md`
- [X] T017 [P] Update `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/contracts/compose-angie-service.md` so image tag and volume mount paths match `/home/owrasor/Code/owrasor/development_enviroment/docker-compose.yml`
- [X] T018 [P] Update `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/contracts/angie-configuration.md` so include paths and file layout match `/home/owrasor/Code/owrasor/development_enviroment/docker/angie/angie.conf` and `docker/angie/sites/`
- [X] T019 Add host port conflict (`80`/`443`) and controlled `curl -k` debug guidance to `/home/owrasor/Code/owrasor/development_enviroment/docs/sandbox.md` or `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/quickstart.md` per edge cases in `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/spec.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Sem dependências — pode arrancar logo.
- **Phase 2 (Foundational)**: Depende da Phase 1 — **bloqueia US1–US3**.
- **Phase 3 (US1)**: Depende da Phase 2.
- **Phase 4 (US2)**: Depende da Phase 3 (ficheiro `example-app.test.conf` e quickstart base).
- **Phase 5 (US3)**: Pode começar após Phase 2 em paralelo teórico com US1/US2 **apenas** para `.env.example` e verificação de portas (T013, T015); **T014** convém após quickstart estável (recomendado: após Phase 4 para links corretos).
- **Phase 6 (Polish)**: Depende de todas as fases anteriores desejadas para o release.

### User Story Dependencies

- **US1 (P1)**: Após fundação; não depende de US2/US3.
- **US2 (P2)**: Depende de US1 (mesmo virtual host e quickstart).
- **US3 (P3)**: T013/T015 independentes do conteúdo TLS fino; T014 idealmente após US2.

### Within Each User Story

- US1: T007 antes de T008 (mesmo ficheiro `example-app.test.conf`); T009 após T007–T008.
- US2: T010–T012 podem distribuir-se por ficheiros diferentes em paralelo após T007–T008.

### Parallel Opportunities

- **Phase 1**: T002 e T003 em paralelo.
- **Phase 2**: T005 pode avançar em paralelo com preparação de T004 **se** dois agentes coordenarem paths de volume; na prática T004→T005 é sequencial seguro.
- **US2**: T010 em paralelo com T011 **se** forem agentes distintos; T012 após T011 (ambos em `quickstart.md`).
- **US3**: T013 e T015 em paralelo; T014 após estabilização do quickstart.
- **Polish**: T017 e T018 em paralelo.

---

## Parallel Example: User Story 2

```bash
# Após T007–T008 concluídos:
# Paralelo: T010 (docker/angie/sites/example-app.test.conf) com T011 (quickstart — secção mkcert)
# Série: T012 (quickstart — troubleshooting) após T011
```

---

## Parallel Example: User Story 3

```bash
# Em paralelo após Phase 2:
# Task T013 → .env.example
# Task T015 → rever docker-compose.yml (diff de portas dev)
# Task T014 → docs/sandbox.md (depois de quickstart final)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Completar Phase 1 e Phase 2.  
2. Completar Phase 3 (US1).  
3. **Parar e validar**: `curl -k` + hosts + app no upstream.  
4. Demo MVP.

### Incremental Delivery

1. Setup + Foundação → stack sobe.  
2. US1 → proxy HTTPS funcional (com certs locais).  
3. US2 → experiência de browser + headers + troubleshooting.  
4. US3 → onboarding repo + `.env.example` + sandbox.  
5. Polish → contratos e validação `angie -t`.

### Parallel Team Strategy

- Após Phase 2: developer A em US1 (T007–T009); developer B pode preparar T013/T015 (US3 parcial); developer C só deve editar `quickstart.md` após T007–T008 se coordenado.

---

## Notes

- Confirmar paths reais da imagem `docker.angie.software/angie` (documentação oficial) antes de fixar volumes definitivos em T004–T005.  
- Nunca commitar PEM/chaves privadas.  
- Cada checkbox é uma unidade de trabalho com caminho explícito para implementação por LLM.
