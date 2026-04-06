# Contract: versões e verificação

## Pins lógicos

| Ferramenta | Pin | Verificação mínima (exemplos) |
|------------|-----|-------------------------------|
| PHP | 8.4.x | `php -v` → string contém `8.4` |
| Node | 22.x | `node -v` → string contém `v22` |
| mise | última estável no momento do build | `mise --version` exit 0 |

## CLIs de IA (presença)

Após build e primeiro `run`, comandos devem existir e responder (versão ou ajuda), conforme documentação actual do repositório:

- `gemini`, `opencode` (pacote npm **`opencode-ai`**, binário `opencode`), `qwen` — nomes exactos documentados no README e `docs/sandbox.md`.
- `claude`, `agent` (Cursor Agent CLI) quando instaladores tiverem sucesso.

## Amostragem (SC-002 da spec)

- Mínimo **3** builds limpos (`docker compose build --no-cache dev`) em ambiente com rede estável; todas as verificações acima passam.
