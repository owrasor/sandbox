#!/usr/bin/env bash
set -euo pipefail

PUID="${USER_ID:-1000}"
PGID="${GROUP_ID:-1000}"

# Com `USER dev` na imagem, o primeiro arranque é como `dev`. É preciso alinhar
# UID/GID como root; após `usermod` o PID 1 ainda teria o UID antigo (inválido em
# passwd), por isso re-invocamos este script via sudo e só aí fazemos groupmod/usermod.
if [ "$(id -u)" -ne 0 ]; then
  exec /usr/bin/sudo env USER_ID="$PUID" GROUP_ID="$PGID" /usr/local/bin/docker-entrypoint.sh "$@"
fi

groupmod -o -g "$PGID" dev
usermod -o -u "$PUID" -g dev dev
chown dev:dev /home/dev 2>/dev/null || true
exec gosu dev "$@"
