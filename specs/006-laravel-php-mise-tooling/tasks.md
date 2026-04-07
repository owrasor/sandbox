---
description: "Task list for feature 006 — Laravel PHP tooling na imagem dev"
---

# Tasks: Suporte Laravel no runtime PHP do contentor

**Input**: Design documents from `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/`  
**Prerequisites**: [plan.md](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/plan.md), [spec.md](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/spec.md), [research.md](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/research.md), [data-model.md](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/data-model.md), [contracts/](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/), [quickstart.md](/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/quickstart.md)

**Tests**: Não solicitados na especificação — sem tarefas de teste automático; validação manual via `quickstart.md`.

**Organization**: Fases por user story (P1 → P3) após fundações na imagem Docker.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Pode executar em paralelo (ficheiros diferentes, sem dependência de tarefas incompletas da mesma fase)
- **[Story]**: [US1], [US2], [US3] nas fases de user story
- Caminhos absolutos ou relativos ao repo conforme abaixo

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Alinhar critérios de aceitação e leitura dos contratos antes de alterar a imagem.

- [x] T001 Confirmar critérios em `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/spec.md` e lista técnica em `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/laravel-php-extensions.md` e `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/cli-version-check.md`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Alterações na imagem que desbloqueiam Composer global / diagnóstico limpo; **nenhuma user story está completa** sem rebuild válido após esta fase.

**⚠️ CRITICAL**: Concluir T002–T003 antes de validar US2/US3 de ponta a ponta.

- [x] T002 Adicionar pacote `unzip` à lista `apt-get install` em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` (suporte a `composer diagnose` / extracção de pacotes)
- [x] T003 Adicionar `ENV COMPOSER_HOME=/usr/local/share/composer` e `RUN mkdir -p "${COMPOSER_HOME}" && chown root:root …` (ou permissões equivalentes só-leitura para `dev` consumir globals) em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` **antes** de `USER dev`, alinhado a `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/research.md`

**Checkpoint**: `docker compose build dev` sem erros; fundação pronta para tarefas por story.

---

## Phase 3: User Story 1 - Runtime PHP pronto para aplicações Laravel (Priority: P1) 🎯 MVP

**Goal**: Verificação repetível de que o PHP 8.4 (mise) cumpre requisitos Laravel 12.x e documentação no inventário.

**Independent Test**: Dentro do contentor, `php -m` / script de verificação conforme `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/laravel-php-extensions.md` sem extensões em falta.

- [x] T004 [P] [US1] Criar script executável `/home/owrasor/Code/owrasor/sandbox/docker/verify-php-laravel-extensions.sh` que implemente a verificação `php -r '…'` (ou equivalente) descrita em `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/laravel-php-extensions.md` e falhe com exit ≠ 0 se faltar extensão
- [x] T005 [US1] Copiar e marcar executável o script em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` (`COPY docker/verify-php-laravel-extensions.sh …`, `RUN chmod +x …` e invocação opcional no build para falhar cedo se regressão)
- [x] T006 [P] [US1] Actualizar `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md` (linha `php-runtime` ou notas) referindo conformidade com requisitos Laravel 12.x e comando/script de verificação

**Checkpoint**: US1 verificável só com imagem + docs; não exige `laravel` instalado.

---

## Phase 4: User Story 2 - Composer disponível e alinhado ao PHP do projecto (Priority: P2)

**Goal**: Composer no PATH do mise, PHP 8.4 efectivo, documentação explícita e diagnose sem bloqueios evitáveis.

**Independent Test**: `command -v composer`, `composer --version`, `composer diagnose` na shell de login conforme `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/cli-version-check.md`.

- [x] T007 [US2] Acrescentar entrada (ou subsecção) para **Composer** em `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md` com canal (`mise` / prefixo PHP), comando de auditoria e nota sobre `unzip`
- [x] T008 [P] [US2] Actualizar `/home/owrasor/Code/owrasor/sandbox/docs/sandbox.md` para mencionar Composer no stack do contentor `dev` e referência ao inventário quando aplicável

**Checkpoint**: US2 validável sem executar `laravel new`.

---

## Phase 5: User Story 3 - Criar novos projectos Laravel pela linha de comando (Priority: P3)

**Goal**: Comando `laravel` global no PATH via Composer global + symlink.

**Independent Test**: `command -v laravel` e `laravel --version` (ou `laravel list`) conforme `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/contracts/cli-version-check.md`.

- [x] T009 [US3] Adicionar `RUN` em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` (como root, com `PATH` incluindo `…/mise/installs/php/8.4/bin`) executando `composer global require laravel/installer` com `COMPOSER_HOME=/usr/local/share/composer`
- [x] T010 [US3] Adicionar `RUN ln -sf /usr/local/share/composer/vendor/bin/laravel /usr/local/bin/laravel` (ajustar caminho se `vendor/bin` diferir) em `/home/owrasor/Code/owrasor/sandbox/docker/Dockerfile` para exposição global do binário
- [x] T011 [US3] Acrescentar entrada **Laravel Installer** (`laravel`) em `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md` (fornecedor Packagist / `laravel/installer`, compliance, nota de rede para `laravel new`)

**Checkpoint**: US3 completo; opcionalmente teste com rede em `/tmp` segundo `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/quickstart.md`.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validação final, alinhamento de docs e README.

- [x] T012 Executar os passos de `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/quickstart.md` após `docker compose build dev` na raiz `/home/owrasor/Code/owrasor/sandbox` e corrigir falhas antes de merge
- [x] T013 [P] Rever e actualizar `/home/owrasor/Code/owrasor/sandbox/specs/006-laravel-php-mise-tooling/quickstart.md` se caminhos de script ou comandos divergirem da implementação final
- [x] T014 [P] Actualizar a tabela / parágrafo do serviço **dev** em `/home/owrasor/Code/owrasor/sandbox/README.md` para incluir **Composer** e **`laravel`** (Laravel Installer) quando a imagem os expuser

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: Sem dependências externas.
- **Phase 2 (Foundational)**: Depende de Phase 1 (entendimento); bloqueia validação integral de US2/US3 até `Dockerfile` aplicado e rebuild.
- **Phase 3 (US1)**: Pode seguir Phase 2 para rebuild; T005 depende de T004 (ficheiro do script existe).
- **Phase 4 (US2)**: Depende de Phase 2 para `unzip`/imagem; independente de US3.
- **Phase 5 (US3)**: Depende de **T003** (`COMPOSER_HOME`) e T002–T003 concluídos no `Dockerfile`.
- **Phase 6 (Polish)**: Depende de todas as stories pretendidas estarem implementadas.

### User Story Dependencies

- **US1**: Após Phase 2; sem dependência de US2/US3.
- **US2**: Após Phase 2; sem dependência de US3 (Composer já no prefixo mise).
- **US3**: Após Phase 2 (especialmente T003); não bloqueia US1/US2.

### Within Each User Story

- US1: T004 → T005 (script antes de COPY no Dockerfile); T006 em paralelo com T004 se recursos distintos.
- US3: T009 antes de T010 (instalar antes do symlink).

### Parallel Opportunities

- **T004 [P]** e **T006 [P]** (US1): script novo vs edição do inventário — ficheiros diferentes após alinhar texto do inventário com o nome do script.
- **T007** e **T008 [P]** (US2): inventário vs `docs/sandbox.md` — ficheiros diferentes.
- **T013 [P]** e **T014 [P]** (Polish): `quickstart.md` da feature vs `README.md` na raiz.

---

## Parallel Example: User Story 1

```bash
# Após Phase 2, em paralelo (dois contribuidores):
# Task T004: criar /home/owrasor/Code/owrasor/sandbox/docker/verify-php-laravel-extensions.sh
# Task T006: editar /home/owrasor/Code/owrasor/sandbox/docs/dev-environment/capability-inventory.md

# Em seguida, sequencial:
# Task T005: integrar script em /home/owrasor/Code/owrasor/sandbox/docker/Dockerfile
```

## Parallel Example: User Story 2

```bash
# Task T007: capability-inventory.md (entrada Composer)
# Task T008: docs/sandbox.md — podem ser feitos em paralelo
```

---

## Implementation Strategy

### MVP First (User Story 1 apenas)

1. Phase 1 + Phase 2  
2. Phase 3 (US1) — script + Dockerfile + inventário PHP/Laravel  
3. **Parar** e validar extensões no contentor (critério independente da spec)

### Incremental Delivery

1. Setup + Foundational → rebuild  
2. + US1 → verificação PHP/Laravel  
3. + US2 → documentação Composer + diagnose limpo  
4. + US3 → `laravel` global + inventário  
5. Polish → quickstart + README

### Parallel Team Strategy

- Após Phase 2: desenvolvedor A em US1 (T004–T006), B em US2 (T007–T008) — atenção a conflitos se ambos editarem `capability-inventory.md`; serializar commits nesse ficheiro.

---

## Notes

- Manter **um único** PHP via mise no PATH de login; não adicionar metapacote `php8.4-*` do Ubuntu sem decisão documentada.
- Se `composer global require` falhar por rede no CI, documentar necessidade de rede no build em `/home/owrasor/Code/owrasor/sandbox/docs/dev-environment/` ou comentário no `Dockerfile`.
- Formato de cada tarefa: `- [ ] Tnnn …` com caminho de ficheiro explícito na descrição.
