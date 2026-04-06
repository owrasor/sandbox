# Implementation Plan: Runtimes e CLIs de IA por defeito no contentor de desenvolvimento

**Branch**: `002-mise-php-node-ai-defaults` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/home/owrasor/Code/owrasor/sandbox/specs/002-mise-php-node-ai-defaults/spec.md`

**Note**: Plano gerado pelo fluxo `/speckit.plan`.

## Summary

Disponibilizar **mise** na imagem `dev`, instalar **PHP 8.4** e **Node 22** como runtimes de sistema (visíveis para o utilizador `dev` em shell de login), eliminar a dependência de uma flag no `.env` para instalar as **CLIs de IA** no fluxo padrão, e alinhar **documentação** (README, `docs/sandbox.md`, `.env.example`) ao novo comportamento. A abordagem técnica segue o cookbook oficial do mise para Docker (`mise install --system`) e refactor mínimo de `install-ai-clis.sh` para usar o Node já fornecido pelo mise em vez do instalador NodeSource quando adequado.

## Technical Context

**Language/Version**: Shell (Bash) para scripts de arranque/instalação; imagem base **Ubuntu 24.04**; runtimes alvo **PHP 8.4.x** e **Node 22.x** via **mise**.  
**Primary Dependencies**: [mise](https://mise.jdx.dev/) (instalação oficial `mise.run`); plugins/registry mise para `php` e `node`; **npm** (via Node do mise) para pacotes globais das CLIs; instaladores externos existentes (Claude, Cursor) mantidos onde aplicável.  
**Storage**: N/A (sem persistência de dados da feature; apenas camadas da imagem Docker).  
**Testing**: Verificação manual / smoke: `docker compose build`, `docker compose run --rm dev` + comandos listados em `quickstart.md`; opcional script em `tests/` se já existir convenção no repositório (actualmente o projecto privilegia validação documentada).  
**Target Platform**: Contentor **Linux amd64** (arquitectura padrão do Compose local; documentar se arm64 for suportado pelo utilizador).  
**Project Type**: Infraestrutura de desenvolvimento (Dockerfile + Docker Compose + scripts).  
**Performance Goals**: Primeira build pode ser mais lenta (mise + runtimes + npm global); sem alvo numérico na spec — documentar expectativa qualitativa.  
**Constraints**: Manter **entrypoint** com alinhamento `USER_ID`/`GROUP_ID`; não alterar donos recursivos em bind mounts; builds **requerem rede** para registry mise/npm/instaladores.  
**Scale/Scope**: Um serviço `dev` e documentação associada; sem alteração obrigatória a `angie`/`ngrok`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro `/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md` está ainda como **template não ratificado** (sem princípios vinculativos preenchidos). Gates aplicáveis ao repositório **sandbox**:

| Gate | Status |
|------|--------|
| Configuração **declarativa** (Compose, Angie) preservada onde não tocada | Pass |
| **Sem segredos** commitados; `.env` continua fora do Git para tokens | Pass |
| **Documentação** de arranque actualizada com o novo comportamento (FR-005) | Pass (entregue em Phase 1 `quickstart.md` + docs raiz na implementação) |
| **Compatibilidade** com bind mounts e utilizador `dev` | Pass (mise em sistema; sem `chown` recursivo no entrypoint) |

**Pós-Phase 1**: Contratos em `contracts/` descrevem superfícies Compose/Dockerfile; nenhuma violação adicional.

## Project Structure

### Documentation (this feature)

```text
specs/002-mise-php-node-ai-defaults/
├── plan.md              # Este ficheiro
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1
└── tasks.md             # Phase 2 (/speckit.tasks — não criado aqui)
```

### Source Code (repository root)

```text
docker/
├── Dockerfile
├── entrypoint.sh
└── install-ai-clis.sh

docker-compose.yml
.env.example
README.md
docs/
└── sandbox.md
```

**Structure Decision**: Alterações concentradas em `docker/` e ficheiros de orquestração/documentação na raiz; sem novo pacote `src/` — o projecto é um sandbox de contentor.

## Complexity Tracking

Sem violações de gates que exijam justificação formal; secção omitida.

## Phase 0 & Phase 1 outputs

- **research.md**: decisões sobre instalação mise, pin `php`/`node`, integração com CLIs e remoção da flag `.env`.
- **data-model.md**: entidades de configuração conceptual (pins de runtime, pacote de CLIs).
- **contracts/**: contratos Compose + imagem `dev` + versões ferramenta.
- **quickstart.md**: passos de verificação pós-implementação.
