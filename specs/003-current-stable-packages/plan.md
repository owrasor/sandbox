# Implementation Plan: Ambiente de desenvolvimento com pacotes estáveis recentes

**Branch**: `003-current-stable-packages` | **Date**: 2026-04-06 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/home/owrasor/Code/owrasor/sandbox/specs/003-current-stable-packages/spec.md`

**Note**: Plano gerado pelo fluxo `/speckit.plan`.

## Summary

Entregar **governação documental e processos** para o ambiente de desenvolvimento padronizado (contentor `dev` deste repositório): **política de frescura** com prazos mensuráveis, **inventário priorizado** de capacidades, **procedimento de auditoria/reverificação**, **avaliação da plataforma base** (incluindo comparação com modelo de atualização contínua tipo rolling) e **linhas de base reprodutíveis**. Em paralelo, alinhar a **estratégia técnica** com o que já existe (**Ubuntu 24.04 + apt + mise**): usar **canais estáveis oficiais** (apt para sistema, mise/registry para runtimes e ferramentas versionáveis) em vez de migrar a imagem inteira para rolling release na primeira entrega — a migração de SO fica como **opção avaliada** no relatório, com critérios e riscos (ver `research.md`).

## Technical Context

**Language/Version**: Markdown para política e relatórios; **Bash** para scripts de verificação opcionais; **Dockerfile** (sintaxe estável) para alterações futuras à imagem.  
**Primary Dependencies**: Imagem actual **Ubuntu 24.04**; **apt** (pacotes de sistema); **mise** já integrado para **PHP 8.4** e **Node 22**; extensão futura do mise (ou equivalente documentado) para ferramentas cujo pacote distro fica aquém da política (ex.: editor).  
**Storage**: Ficheiros versionados em `docs/` e `specs/003-current-stable-packages/`; sem base de dados.  
**Testing**: Checklists manuais em `quickstart.md`; `docker compose build` / `run` como fumo quando o plano técnico tocar no Dockerfile; inquérito à equipa (Google Form / poll interno — fora do repo) para SC-004.  
**Target Platform**: Contentor **Linux amd64** (Compose local); política aplica-se ao fluxo padronizado do repo.  
**Project Type**: Documentação operacional + eventual ajuste de infra de desenvolvimento (Docker).  
**Performance Goals**: N/A para esta feature (não há SLA de latência); builds podem alongar-se se se adicionarem mais ferramentas ao mise — documentar trade-off na política.  
**Constraints**: Manter **entrypoint** e alinhamento `USER_ID`/`GROUP_ID`; **sem segredos** em Git; mudança para rolling release **não é pré-requisito** da spec — requer ADR/avaliação explícita antes de implementar.  
**Scale/Scope**: Uma equipa pequena/média usando o `docker-compose` do sandbox; inventário inicial pode cobrir ~10–30 itens.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

O ficheiro `/home/owrasor/Code/owrasor/sandbox/.specify/memory/constitution.md` está ainda como **template não ratificado**. Gates aplicáveis ao repositório **sandbox**:

| Gate | Status |
|------|--------|
| Configuração **declarativa** (Compose, Angie) preservada onde não tocada | Pass |
| **Sem segredos** commitados | Pass |
| **Documentação** de arranque e política acessível a novos membros | Pass (entregue via `docs/` + `quickstart.md`) |
| **Compatibilidade** com utilizador `dev` e bind mounts | Pass (sem exigir rolling na v1) |

**Pós-Phase 1**: Contratos em `contracts/` definem estrutura dos artefactos de governação; nenhuma violação adicional.

## Project Structure

### Documentation (this feature)

```text
specs/003-current-stable-packages/
├── plan.md              # Este ficheiro
├── research.md          # Phase 0
├── data-model.md        # Phase 1
├── quickstart.md        # Phase 1
├── contracts/           # Phase 1
└── tasks.md             # Phase 2 (/speckit.tasks — não criado aqui)
```

### Source Code (repository root)

```text
docs/
├── sandbox.md                    # Referência cruzada à política (actualizar na implementação)
└── dev-environment/              # NOVO (proposto): política, inventário, ADR/avaliação
    ├── README.md
    ├── freshness-policy.md
    ├── capability-inventory.md
    ├── audit-template.md
    └── platform-evaluation.md    # ou docs/adr/000X-... conforme convenção adoptada

docker/
├── Dockerfile                    # Opcional: pins adicionais mise / ferramentas
├── entrypoint.sh
└── install-ai-clis.sh

docker-compose.yml
README.md
```

**Structure Decision**: A maior parte do valor da spec é **documentação e processo** sob `docs/dev-environment/` (caminho proposto); alterações ao `Dockerfile` são **opcionais** e só após decisão registada na avaliação da plataforma (ex.: instalar Neovim via mise em vez de apenas `apt`).

## Complexity Tracking

Sem violações de gates que exijam justificação formal; secção omitida.

## Phase 0 & Phase 1 outputs

- **research.md**: decisão base OS + canais de frescura + alternativa rolling.
- **data-model.md**: entidades Política, Item de inventário, Avaliação, Registo de auditoria.
- **contracts/**: formatos mínimos dos documentos e relação com a imagem `dev`.
- **quickstart.md**: como executar primeira auditoria e reverificação.
