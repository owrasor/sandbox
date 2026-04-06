# Contract: serviço `dev` (Docker Compose)

## Serviço

- **Nome**: `dev`
- **Build**: contexto `./docker`, Dockerfile `docker/Dockerfile`.

## Requisitos pós-feature

1. **Build args**: Não pode ser obrigatório editar o `.env` apenas para **activar** a instalação das CLIs de IA. O serviço `dev` **não** deve depender de `INSTALL_AI_CLIS` (ou equivalente) vindo do `.env`; o build padrão inclui CLIs e runtimes mise.
2. **env_file**: Continua a carregar `.env` para `USER_ID`, `GROUP_ID`, `WORKSPACE_HOST`, `DOTFILES_HOST`, `SSH_DIR`, etc.; nenhuma variável nova deve ser **mandatória** só para instalar CLIs.
3. **Utilizador em runtime**: `user: "0:0"` com entrypoint que faz `gosu dev` — inalterado salvo necessidade documentada.
4. **Volumes**: Montagens existentes preservadas (`workspace`, `dotfiles`, `.ssh:ro`).

## Verificação

- `docker compose build dev` com `.env` mínimo (caminhos válidos) conclui com sucesso.
- `docker compose run --rm dev` inicia shell interactiva como `dev`.
