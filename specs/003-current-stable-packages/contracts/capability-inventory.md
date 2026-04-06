# Contract: Inventário de capacidades

## Obrigatório por linha

| Campo | Descrição |
|-------|-----------|
| ID | Identificador estável |
| Nome | Legível |
| Criticidade | P1 / P2 / P3 |
| Dono | Pessoa ou equipa |
| Fornecedor / canal | Onde se lê a “última estável” (apt, mise, URL de releases, etc.) |
| Versão no ambiente padrão | Preenchido na auditoria |
| Última estável do fornecedor | Preenchido na auditoria |
| Estado | `ok` / `exception` / `pending` |
| Notas | Excepções, links PR, datas |

## Regras

- Todo item **P1** deve ter critério de conformidade ligado à política de frescura (prazo ou métrica).
- Itens instalados apenas por **apt** no `Dockerfile` devem declarar `channel: apt` e pacote Debian.
- Itens **mise** devem declarar pin exacto (ex. `node@22`, `php@8.4`) alinhado com `docker-dev-image` da feature 002 quando aplicável.

## Verificação

- Primeira auditoria: ≥90% dos P1 em `ok` ou `exception` documentada (SC-002).
