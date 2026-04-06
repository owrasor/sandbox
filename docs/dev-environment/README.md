# Governação do ambiente de desenvolvimento (contentor `dev`)

Este diretório contém a **política**, o **inventário** e os **registos de auditoria** alinhados com a especificação [`specs/003-current-stable-packages/spec.md`](../../specs/003-current-stable-packages/spec.md).

## Documentos

| Documento | Finalidade |
|-----------|------------|
| [freshness-policy.md](./freshness-policy.md) | Política de frescura, SLAs, excepções, baseline e anúncios de migração |
| [capability-inventory.md](./capability-inventory.md) | Inventário priorizado de ferramentas e runtimes na imagem `dev` |
| [audit-template.md](./audit-template.md) | Modelo para novos registos em `audits/` |
| [platform-evaluation.md](./platform-evaluation.md) | Avaliação da plataforma base (LTS + mise vs rolling) |
| [audits/](./audits/) | Registos datados de auditorias / reverificações |

## Donos (RACI sugerido)

| Papel | Responsabilidade |
|-------|------------------|
| **Maintainer da imagem** | Atualizar `docker/Dockerfile`, pins mise, e sincronizar o inventário |
| **Revisor de política** | Aprovar alterações a `freshness-policy.md` e excepções P1 |
| **Cada developer** | Reportar bloqueios por obsolescência; responder ao inquérito periódico |

## Inquérito SC-004 (obsolescência percebida)

Escala 1–5: *«As versões das ferramentas no ambiente padrão permitem trabalhar sem bloqueios por obsolescência?»*

| Métrica | Valor (preencher após recolha) |
|---------|--------------------------------|
| **Mediana** | _TBD — executar formulário interno e actualizar_ |
| **N.º de respostas** | _TBD_ |
| **Data da medição** | _TBD_ |

> Actualizar esta tabela após a primeira rodagem do inquérito à equipa (objectivo SC-004: mediana ≥ 4).

## Ligações

- Plano de implementação: [`specs/003-current-stable-packages/plan.md`](../../specs/003-current-stable-packages/plan.md)
- Verificação pós-implementação: [`specs/003-current-stable-packages/quickstart.md`](../../specs/003-current-stable-packages/quickstart.md)
