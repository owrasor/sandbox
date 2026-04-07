# Data model: 007-dotfiles-bootstrap-once

## Entidades

### 1. Configuração (`DOTFILES_BOOTSTRAP_SCRIPT`)

| Campo | Tipo | Regras |
|-------|------|--------|
| `value` | string opcional | Se ausente ou só espaços: **nenhuma** execução de bootstrap. Se presente: **apenas** um segmento de nome seguro (sem `/`, sem `..`); caracteres permitidos documentados no contrato (ex.: alfanumérico, `.`, `_`, `-`). |

**Relação**: Lê-se do ambiente do processo no contentor (Compose `env_file` + opcional `environment`).

---

### 2. Script de utilizador (ficheiro em dotfiles)

| Campo | Tipo | Regras |
|-------|------|--------|
| `resolved_path` | path absoluto | DEVE ser filho canónico de `/home/dev/dotfiles` após validação. |
| `executable` | boolean | Se não executável: tratar como falha (não marcar sucesso) e reportar. |

**Relação**: Conteúdo e efeitos laterais são responsabilidade do utilizador; o sistema só garante invocação e política de “uma vez”.

---

### 3. Estado de conclusão (marcador)

| Campo | Tipo | Regras |
|-------|------|--------|
| `marker_path` | path absoluto | Convencionado sob workspace montado (ex.: `/home/dev/workspace/.sandbox/dotfiles-bootstrap.done`). |
| `exists` | boolean | `true` **só** após o script do utilizador terminar com código de saída **0**. |
| `content` | texto opcional | Pode incluir timestamp ou versão de esquema para depuração (mínimo: ficheiro vazio ou uma linha). |

**Relação**: Um marcador por workspace persistido; apagar o ficheiro = “primeira vez” de novo (documentado para o utilizador).

---

### 4. Lock de concorrência

| Campo | Tipo | Regras |
|-------|------|--------|
| `lock_path` | path absoluto | Adjacente ao estado (ex.: `.../dotfiles-bootstrap.lock`). |
| `held` | boolean | Adquirido com `flock` antes da execução do script; libertado após tentativa. |

---

## Transições de estado (alto nível)

1. **Idle** — variável vazia ou marcador presente → nenhuma acção (excepto verificação barata).
2. **Eligible** — variável definida, marcador ausente, script resolvido e existente → adquirir lock → executar script.
3. **Success** — exit 0 → criar/atómico marcador → libertar lock.
4. **Failed** — exit ≠ 0 ou erro de validação → **não** criar marcador de sucesso → libertar lock → shell continua com diagnóstico.
5. **Missing script** — ficheiro inexistente → **não** sucesso; diagnóstico; próximo arranque pode corrigir.

## Validações cruzadas (spec)

| Requisito | Modelo |
|-----------|--------|
| FR-001 | `DOTFILES_BOOTSTRAP_SCRIPT` no `.env` → ambiente |
| FR-002 | `resolved_path` prefixado por `/home/dev/dotfiles` |
| FR-003 | `marker_path` + lock |
| FR-004 | valor vazio → transição não entra em Eligible |
| FR-005 | Missing script → não Success |
| FR-006 | Failed → marcador de sucesso não existe |
| FR-007 | gatilho no arranque via `zsh`, não no build |
