# Implementation Plan: Neovim estável oficial na imagem dev

**Branch**: `004-update-neovim-stable` | **Date**: 2026-04-06 | **Spec**: [/home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/spec.md](/home/owrasor/Code/owrasor/sandbox/specs/004-update-neovim-stable/spec.md)  
**Input**: Feature specification from `/specs/004-update-neovim-stable/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Alinhar o **Neovim** da imagem de desenvolvimento (`docker/Dockerfile`, Ubuntu 24.04) à **versão estável atual** publicada nos artefactos oficiais referenciados por [neovim.io/doc/install/](https://neovim.io/doc/install/) (GitHub **Releases → latest →** `nvim-linux-x86_64.tar.gz`). Em 2026-04-06 o tag **latest** corresponde a **v0.12.1**. A abordagem: deixar de depender do pacote `neovim` do Ubuntu (0.9.5, aquém do estável upstream) e instalar o tarball oficial em `/opt`, expondo `nvim` no `PATH` global da imagem; documentar a versão pinada e actualizar o inventário / avaliação de plataforma em `docs/dev-environment/`.

## Technical Context

**Language/Version**: Dockerfile (syntax OCI); shell **Bash** nos `RUN`; imagem base **Ubuntu 24.04**  
**Primary Dependencies**: **Neovim** estável via tarball oficial GitHub; **curl**, **ca-certificates**; **mise** (já na imagem) para PHP/Node — Neovim **não** depende do mise neste plano  
**Storage**: N/A (sem persistência de dados da aplicação; apenas camadas da imagem)  
**Testing**: Verificação manual / smoke: `docker compose build dev` e `docker compose run --rm dev bash -lc 'command -v nvim && nvim --version | head -1'`; alinhar com comandos já usados em `docs/dev-environment/`  
**Target Platform**: Contentor **Linux x86_64** (imagem dev do repositório)  
**Project Type**: Infraestrutura de desenvolvimento (Docker + documentação)  
**Performance Goals**: N/A para esta feature  
**Constraints**: Manter **XDG** / `~/.config/nvim` como hoje; build reprodutível (URL de release **pinada** por tag semântica em vez de `latest` no Dockerfile final, ou `ARG` + default explícito); arquitectura alvo **x86_64** (arm64 fora de escopo salvo follow-up)  
**Scale/Scope**: Uma imagem dev, documentação associada (`docs/`, `README` se necessário), possível actualização de auditoria/inventário

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro [/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md](/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md) está ainda como **modelo** (princípios por preencher, sem gates ratificados). **Estado do gate**: **PASS** — não há princípios obrigatórios conflitantes; a mudança é localizada, documentada e reversível.

**Re-check pós-Phase 1**: Mantém-se **PASS**; contratos limitam-se à verificação de versão na imagem (ver `contracts/`).

## Project Structure

### Documentation (this feature)

```text
specs/004-update-neovim-stable/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
docker/
├── Dockerfile           # Instalação Neovim: tarball oficial + PATH; remoção/neutralização do pacote apt antigo
├── entrypoint.sh        # Sem alteração esperada
└── install-ai-clis.sh   # Sem alteração esperada

docs/
├── sandbox.md                    # Referências a versão Neovim se mencionada explicitamente
└── dev-environment/
    ├── capability-inventory.md   # Actualizar linha nvim-editor (versão, canal, excepção)
    ├── platform-evaluation.md    # Fechar ou actualizar excepção Neovim
    ├── freshness-policy.md       # Se política referir canal Neovim
    ├── audit-template.md         # Comando de verificação (se versão mudar texto esperado)
    └── audits/
        └── 2026-Q2-01.md         # Opcional: nota de follow-up pós-implementação

README.md                # Tabela de stack dev: versão Neovim se listada

compose.yaml             # Sem alteração estrutural esperada (imagem `dev` já referenciada)
```

**Structure Decision**: A entrega concentra-se em **`docker/Dockerfile`** e **`docs/dev-environment/*`** (inventário, avaliação de plataforma, templates de auditoria). Não há código em `src/` para esta feature.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(Não aplicável — nenhuma violação identificada.)*
