#!/usr/bin/env bash
set -euo pipefail

PUID="${USER_ID:-1000}"
PGID="${GROUP_ID:-1000}"

# Imagem base já tem utilizador e grupo `dev`; alinhar a UID/GID do host
groupmod -o -g "$PGID" dev
usermod -o -u "$PUID" -g dev dev

# Não fazer chown recursivo em /home/dev: bind mounts (.ssh :ro, workspace, dotfiles)
# alterariam o dono no host ou falhariam em sistemas de ficheiros só de leitura.
chown dev:dev /home/dev 2>/dev/null || true

exec gosu dev "$@"
