# Contract: variáveis de ambiente — bootstrap de dotfiles

**Feature**: 007-dotfiles-bootstrap-once  
**Versão**: 1.0 (plano)

## Objetivo

Fixar a semântica de **FR-001** e a injectação via Compose para evitar interpretações divergentes entre `.env`, documentação e imagem.

## Variáveis

### `DOTFILES_BOOTSTRAP_SCRIPT`

| Propriedade | Regra |
|-------------|--------|
| Obrigatoriedade | Opcional |
| Formato | Nome de ficheiro **no topo** do mount de dotfiles (sem `/`, sem `..`). Ex.: `bootstrap-dev.sh` |
| Resolução | Caminho efectivo = `/home/dev/dotfiles/<valor>` após validação |
| Efeito se vazio/ausente | Nenhum script de bootstrap é invocado pela funcionalidade |

### `SANDBOX_DOTFILES_BOOTSTRAP_SKIP` (opcional, implementação)

| Propriedade | Regra |
|-------------|--------|
| Obrigatoriedade | Opcional |
| Formato | Qualquer valor não vazio desactiva a execução (útil para CI ou depuração) |
| Documentação | DEVE constar em `docs/sandbox.md` se implementada |

## Invariantes

- Variáveis sensíveis de segredos **não** são exigidas por esta feature.
- O `.env` permanece fora do Git; o modelo para o utilizador é [`.env.example`](../../../../.env.example).
- O serviço `dev` no Compose declara `DOTFILES_BOOTSTRAP_SCRIPT` e `SANDBOX_DOTFILES_BOOTSTRAP_SKIP` em `environment:` (pass-through desde o `.env`); o entrypoint preserva-nas com `sudo -E` e `env_keep` na imagem.

## Falhas do contrato

- Se a documentação listar nomes diferentes dos aceites pelo script de orquestração, o contrato falhou — alinhar `.env.example` e `docs/sandbox.md`.
