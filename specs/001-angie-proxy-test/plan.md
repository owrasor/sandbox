# Implementation Plan: Angie — proxy reverso para `*.test` com HTTPS

**Branch**: `001-angie-proxy-test` | **Date**: 2026-04-01 | **Spec**: `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/spec.md`  
**Input**: Feature specification from `/home/owrasor/Code/owrasor/development_enviroment/specs/001-angie-proxy-test/spec.md`

**Note**: Gerado pelo fluxo `/speckit.plan`. Ver `.specify/templates/plan-template.md` para o workflow.

## Summary

Adicionar um serviço **Angie** ao ambiente Docker deste repositório para fazer **proxy reverso** de hostnames `*.test` para upstreams na rede `sandbox` (por exemplo o contentor `dev`). **HTTPS** termina no Angie usando certificados locais (recomendado: **mkcert** wildcard no host, montados como volume). Resolução de nomes fica documentada (`/etc/hosts` ou **dnsmasq**). Configuração em ficheiros versionados sob `docker/angie/` (ou caminho equivalente), com segredos fora do Git.

## Technical Context

**Language/Version**: Configuração declarativa (Angie/Nginx-style); Docker Compose YAML; shell para validação/manual QA.  
**Primary Dependencies**: Imagem **Angie** (`docker.angie.software/angie`, tag fixa recomendada após `docker pull`/release notes), Docker Compose v2, opcionalmente **mkcert** no host.  
**Storage**: N/A (sem BD); ficheiros de config no repo; certificados e chaves apenas em volume local ignorado pelo Git.  
**Testing**: Validação de sintaxe `angie -t` (ou binário exposto pela imagem); `curl` HTTP/HTTPS; checklist em `quickstart.md`.  
**Target Platform**: Linux host com Docker (alinhado a `docs/sandbox.md`).  
**Project Type**: infraestrutura / dev-environment (Compose).  
**Performance Goals**: Tráfego de desenvolvimento local; sem SLO numérico — proxy deve introduzir overhead negligível vs. acesso direto à porta.  
**Constraints**: Portas **80/443** no host devem estar livres ou documentar mapeamento alternativo; browsers precisam de CA local confiável para HTTPS sem avisos.  
**Scale/Scope**: Poucos hostnames por máquina; um contentor Angie por stack Compose.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro `/home/owrasor/Code/owrasor/development_enviroment/.specify/memory/constitution.md` está **ainda como template** (princípios `[PRINCIPLE_N]` não ratificados). Não há violações mensuráveis contra princípios em vigor.

**Verificação ad hoc para esta feature** (até ratificação da constituição):

| Gate | Status |
|------|--------|
| Documentação operacional (`quickstart.md`) | Satisfeito (Phase 1) |
| Segredos/TLS fora do Git | Exigido em spec + contratos |
| Simplicidade: um serviço proxy, includes por site | Satisfeito no desenho |

**Pós-Phase 1**: Contratos e `data-model` alinham-se com FR/SC do spec; nenhuma complexidade extra sem justificação na secção Complexity (vazia).

## Project Structure

### Documentation (this feature)

```text
specs/001-angie-proxy-test/
├── plan.md              # Este ficheiro
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1
└── tasks.md             # Phase 2 (speckit.tasks — não criado por este plano)
```

### Source Code (repository root)

```text
docker/
├── Dockerfile                    # existente (dev)
├── angie/                        # NOVO: configuração do proxy
│   ├── angie.conf                # http global + include sites/*.conf
│   ├── sites/
│   │   ├── README.md             # como adicionar novos sites
│   │   └── *.conf                # virtual hosts .test (ex.: example-app.test.conf)
│   └── certs/                    # local only (gitignored PEM)
├── entrypoint.sh
└── install-ai-clis.sh

docker-compose.yml                # NOVO serviço angie + volumes + portas 80/443

docs/
└── sandbox.md                    # ATUALIZAR: secção Angie / *.test / HTTPS (opcional nesta iteração se quickstart cobrir)

.gitignore                        # ATUALIZAR: ignorar docker/angie/certs/ ou path acordado
```

**Structure Decision**: Toda a config Angie vive sob `docker/angie/` para colocalizar com o contexto de build existente em `docker/`, mantendo o Compose na raiz como hoje. Certificados gerados no host montam-se de `docker/angie/certs/` (gitignored) ou variável `ANGIE_CERTS_HOST` no `.env`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

Nenhuma violação a justificar.
