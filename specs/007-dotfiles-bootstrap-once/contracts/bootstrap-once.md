# Contract: execução única do script de dotfiles

**Feature**: 007-dotfiles-bootstrap-once  
**Versão**: 1.0 (plano)

## Objetivo

Garantir observabilidade de **FR-003**, **FR-006**, **SC-001**, **SC-002** e **SC-004** através de verificações manuais repetíveis.

## Pré-requisitos

- Repositório na raiz; `.env` válido com `DOTFILES_HOST`, `WORKSPACE_HOST`, etc., como em [docs/sandbox.md](../../../../docs/sandbox.md).
- No host, dentro do clone de dotfiles referenciado por `DOTFILES_HOST`, existe um script de teste com o nome definido em `DOTFILES_BOOTSTRAP_SCRIPT` (ex.: cria um ficheiro temporário ou escreve uma linha num log **dentro do workspace** para inspecção).

## Comandos canónicos de verificação

Executar a partir da raiz do repositório no host. Ajustar o nome do script de teste ao valor da variável.

| ID | Cenário | Comando (exemplo) | Resultado esperado |
|----|---------|-------------------|--------------------|
| B1 | Primeiro arranque com script válido | `docker compose run --rm --no-deps dev zsh -lc 'test -f /home/dev/workspace/.sandbox/dotfiles-bootstrap.done && echo OK'` | `OK` após implementação (marcador criado só após sucesso) |
| B2 | Segundo arranque | Repetir `docker compose run --rm --no-deps dev zsh -lc '…'` com o mesmo workspace | O script de utilizador **não** deve ter sido reexecutado (verificar por efeito colateral idempotente, ex.: contagem de linhas num ficheiro de prova) |
| B3 | Variável vazia | Remover ou esvaziar `DOTFILES_BOOTSTRAP_SCRIPT`, arrancar | Marcador **não** é exigido; nenhum erro atribuível ao bootstrap |
| B4 | Ficheiro ausente | Variável aponta para nome inexistente | Shell disponível; **sem** marcador de sucesso; mensagem de erro visível (stderr ou log documentado) |
| B5 | Script falha | Script com `exit 1` | **Sem** marcador de sucesso; após corrigir script e arrancar de novo, nova tentativa permitida |

## Invariantes

- O script do utilizador **nunca** é resolvido fora de `/home/dev/dotfiles` após validação.
- O marcador de sucesso **só** existe após término com código **0** do script do utilizador.

## Falhas

- Marcador presente após **B5** → viola **FR-006**.
- Script corre duas vezes em **B2** com o mesmo marcador já criado → viola **FR-003** / **SC-002**.
