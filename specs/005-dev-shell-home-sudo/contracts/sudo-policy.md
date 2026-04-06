# Contract: política de elevação (`sudo`)

**Feature**: 005-dev-shell-home-sudo  
**Versão**: 1.0 (rascunho de plano)

## Objetivo

Garantir observabilidade de **FR-002** e **SC-002**: a conta `dev` pode elevar privilégios sem palavra-passe interativa dentro do contentor.

## Comandos canónicos de verificação

| ID | Comando | Resultado esperado |
|----|---------|---------------------|
| S1 | `docker compose run --rm --no-deps dev zsh -lc 'command -v sudo'` | Caminho absoluto para o binário `sudo` |
| S2 | `docker compose run --rm --no-deps dev zsh -lc 'sudo -n true'` | Código de saída `0`, sem prompt |
| S3 | `docker compose run --rm --no-deps dev zsh -lc 'sudo -n id -u'` | Saída `0` (UID efectivo root) |

## Âmbito e aviso

- Válido apenas para a **imagem de desenvolvimento** deste repositório; **não** constitui modelo para imagens de produção.
- Qualquer restrição futura (sudoers mínimo) deve actualizar este contrato e a documentação em `docs/sandbox.md`.

## Falhas

- `sudo: a password is required` ou código de saída não zero em S2/S3 → contrato **falhou**.
