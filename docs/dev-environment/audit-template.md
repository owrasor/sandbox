# Modelo de registo de auditoria / reverificação

Copiar para `audits/AAAA-Qn-NN.md` e preencher. Campos alinhados com o modelo conceptual em `specs/003-current-stable-packages/data-model.md` (entidade `audit-record`).

## Metadados

| Campo | Valor |
|-------|-------|
| **audit_id** | ex. `2026-Q2-01` |
| **performed_at** | ISO date |
| **performer** | Nome ou handle |
| **sample** | «Inventário completo» ou lista de IDs auditados |

## Resultado

| Campo | Valor |
|-------|-------|
| **result_summary** | % itens P1 em conformidade; lista de falhas |
| **policy_version** | Referência à versão em `freshness-policy.md` |

## Itens verificados (resumo)

| ID inventário | Esperado / observado | compliance |
|---------------|----------------------|------------|
| … | … | ok / exception / pending |

## Acções correctivas

- [ ] …

## Notas

Comandos usados (exemplo):

```bash
docker compose build dev
docker run --rm --entrypoint bash sandbox-dev:latest -lc 'export PATH="/usr/local/share/mise/installs/node/22/bin:/usr/local/share/mise/installs/php/8.4/bin:${PATH}"; php -v; node -v; nvim --version | head -1'
```

(Ajustar se a tag da imagem ou o PATH mudarem.)
