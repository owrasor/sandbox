# Data model — 003-current-stable-packages

Modelo **conceptual** dos artefactos de governação (não é esquema SQL). Campos sugeridos para consistência entre documentos e scripts de verificação.

## Entity: Política de frescura (`freshness-policy`)

| Campo | Tipo | Regras |
|-------|------|--------|
| `version` | semver ou data | Incrementar quando regras mudarem |
| `definition_stable` | texto | O que conta como “estável” por tipo de ferramenta (distro vs upstream vs mise) |
| `sla_days_critical` | inteiro | Prazo máximo (dias) entre release estável do fornecedor e adoção no ambiente padrão, para itens criticidade `P1` |
| `sla_days_normal` | inteiro | Idem para `P2`/`P3` |
| `audit_cadence` | enum | ex. `monthly` / `quarterly` |
| `exception_process` | texto | Quem aprova, duração máxima da excepção, registo obrigatório |
| `baseline_policy` | texto | Como pinar/referenciar imagem ou lockfile para suporte (ligação FR-006) |

**Relações**: referenciada por todos os itens do inventário e por cada registo de auditoria.

---

## Entity: Item de inventário (`capability-inventory` row)

| Campo | Tipo | Regras |
|-------|------|--------|
| `id` | string curta | Único, estável (ex. `nvim`, `php-runtime`) |
| `name` | texto | Nome legível |
| `criticality` | enum | `P1` \| `P2` \| `P3` |
| `owner` | texto | Responsável pela actualização |
| `supplier` | texto | Onde a versão estável é publicada |
| `channel` | texto | ex. `apt`, `mise`, `upstream tarball` |
| `version_observed` | texto | Versão na última auditoria |
| `version_supplier_latest_stable` | texto | Referência verificada na data da auditoria |
| `compliance` | enum | `ok` \| `exception` \| `pending` |
| `exception_id` | opcional | Liga a registo de excepção se `compliance=exception` |
| `last_verified_at` | ISO date | |

**Relações**: N–1 para Política (implícito); N–1 para Registo de auditoria quando preenchido durante auditoria.

---

## Entity: Avaliação de plataforma base (`platform-evaluation`)

| Campo | Tipo | Regras |
|-------|------|--------|
| `date` | ISO date | Data da conclusão |
| `author` | texto | |
| `reviewer` | texto | Mínimo um par (SC-003) |
| `criteria` | lista | Ex.: frescura, suporte, segurança, tempo de build, curva de aprendizagem |
| `current_platform_summary` | texto | Descrição do estado actual (sem obrigar nome comercial se política interna o exigir) |
| `options_considered` | lista | Inclui “manter base fixa + mise” e “migrar para rolling” entre outras |
| `risks` | lista | Por opção |
| `recommendation` | enum | `keep` \| `migrate` \| `defer` |
| `next_steps` | lista | Acções concretas e donos |

---

## Entity: Registo de auditoria (`audit-record`)

| Campo | Tipo | Regras |
|-------|------|--------|
| `audit_id` | string | ex. `2026-Q2-01` |
| `performed_at` | ISO date | |
| `performer` | texto | |
| `sample` | referência | Subconjunto ou “inventário completo” |
| `result_summary` | texto | % conformidade, lista de falhas |
| `actions` | lista | Correctivas abertas |

**Transições**: `planned` → `in_progress` → `closed` (opcional para gestão de tarefas externa).

---

## Validação cruzada (FRs)

- **FR-001**: Política deve conter pelo menos **três** métricas/prazos explícitos (alinhado SC-001).
- **FR-002**: Inventário com colunas mínimas: criticidade, dono, canal, última verificação.
- **FR-005**: Cada registo de auditoria referencia cadência definida na política.
