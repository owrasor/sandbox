# Contract: sessão shell — diretório inicial

**Feature**: 005-dev-shell-home-sudo  
**Versão**: 1.0 (rascunho de plano)

## Objetivo

Garantir observabilidade de **FR-001** e **SC-001**: o fluxo documentado para abrir `zsh` no serviço `dev` deve começar com CWD na pasta pessoal do utilizador `dev`.

## Comandos canónicos de verificação

Executar a partir da raiz do repositório no host:

| ID | Comando | Resultado esperado |
|----|---------|---------------------|
| C1 | `docker compose run --rm --no-deps dev zsh -lc 'pwd'` | Saída exacta: `/home/dev` |
| C2 | Com `dev` em execução: `docker compose exec dev zsh -lc 'pwd'` | Saída exacta: `/home/dev` |

## Invariantes

- O bind mount do código permanece disponível em **`/home/dev/workspace`** (nome relativo `workspace` a partir de `/home/dev`).
- O utilizador efectivo da shell interactiva (após entrypoint) é **`dev`**, não root.

## Falhas

- Se C1 ou C2 imprimirem `/home/dev/workspace` (ou outro caminho), o contrato **falhou** — rever `working_dir` no Compose e `WORKDIR` na imagem.
