# Data model: 004-update-neovim-stable

Esta feature não introduz base de dados nem API REST. Os “dados” são **metadados de ferramenta** e **estado documental** no repositório.

## Entidade: `PinnedToolVersion`

Representa a escolha auditável de uma ferramenta CLI na imagem de desenvolvimento.

| Campo | Tipo lógico | Regras / notas |
|--------|----------------|------------------|
| `tool_id` | string | Constante: `nvim-editor` (alinhado ao inventário existente). |
| `channel` | enum | `upstream-stable` (artefacto GitHub Releases estável, não nightly). |
| `version_tag` | string | Formato `vMAJOR.MINOR.PATCH` (ex.: `v0.12.1`), pinado no build. |
| `artifact_name` | string | `nvim-linux-x86_64.tar.gz` para a arquitectura alvo. |
| `install_prefix` | path | `/opt/nvim-linux-x86_64` na imagem. |
| `path_entry` | path | `/opt/nvim-linux-x86_64/bin` antecedente a outros `nvim` no `PATH`. |
| `spec_reference` | URI | `https://neovim.io/doc/install/` (rastreabilidade FR-001). |

**Validação**: `nvim --version` (primeira linha) deve reportar a mesma geração semântica que `version_tag` (ex.: `NVIM v0.12.1`).

## Entidade: `DevEnvironmentDocRecord`

Linha conceptual no inventário / política (`docs/dev-environment/capability-inventory.md`).

| Campo | Tipo lógico | Regras |
|--------|----------------|--------|
| `inventory_id` | string | `nvim-editor`. |
| `supplier` | string | Passa de “apt (`neovim`)” para “Neovim upstream release tarball”. |
| `exception_status` | enum | De `exception` para **ausente** ou `none` quando o SLA P1 estiver cumprido. |
| `observed_version_command` | string | Comando canónico de auditoria (ver `contracts/version-check.md`). |

## Relações

- `PinnedToolVersion` **alimenta** `DevEnvironmentDocRecord.observed_version` após build (valor observado deve coincidir com `version_tag`).

## Transições de estado

1. **Antes**: Imagem contém Neovim 0.9.x via APT; inventário marca excepção.  
2. **Depois**: Imagem contém Neovim pinado via tarball; inventário sem excepção (ou com nota “fechado em [data]”).
