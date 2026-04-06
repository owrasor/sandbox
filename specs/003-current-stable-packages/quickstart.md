# Quickstart — 003-current-stable-packages

Passos para **verificar** que a governação está implementada após `/speckit.implement` (ou revisão manual).

## Pré-requisitos

- Branch `003-current-stable-packages` (ou main com merge).
- Acesso ao repositório e, para fumo técnico, Docker com Compose.

## 1. Documentação presente

Confirmar existência (ou equivalente acordado) em `docs/dev-environment/`:

- `freshness-policy.md` — cumpre [contracts/freshness-policy.md](./contracts/freshness-policy.md).
- `capability-inventory.md` — cumpre [contracts/capability-inventory.md](./contracts/capability-inventory.md).
- `platform-evaluation.md` — cumpre [contracts/platform-evaluation.md](./contracts/platform-evaluation.md).
- `audit-template.md` — modelo copy-paste para registos trimestrais (opcional mas recomendado).

## 2. Primeira auditoria (manual)

1. Abrir o inventário e a política.
2. Para cada item **P1**, anotar versão dentro do contentor vs última estável do fornecedor (comando ou página de release).
3. Marcar `ok`, `exception` (com aprovador + data revisão) ou `pending`.
4. Calcular percentagem de P1 conformes; objectivo **≥90%** ou excepções assinadas (SC-002).

**Comandos úteis (exemplo)**:

```bash
docker compose build dev
docker compose run --rm dev bash -lc 'php -v; node -v; nvim --version | head -1'
```

(Ajustar conforme inventário final.)

## 3. Avaliação de plataforma

1. Abrir `platform-evaluation.md`.
2. Confirmar **duas assinaturas** (autor + revisor) e recomendação explícita (SC-003).

## 4. Inquérito (SC-004)

1. Enviar formulário interno com pergunta Likert 1–5 sobre obsolescência / bloqueios.
2. Registar **mediana ≥ 4** e número de respostas no próximo registo de auditoria ou nota no README da pasta `docs/dev-environment/`.

## 5. Ligações

- `README.md` do repo deve apontar para `docs/dev-environment/README.md`.
- `docs/sandbox.md` deve mencionar a política de frescura numa linha ou secção curta.
