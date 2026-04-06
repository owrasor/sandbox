#!/usr/bin/env bash
# Instala CLIs de IA com prefixo global em /usr/local.
# Se já existir Node no PATH com a major pretendida (ex.: 22 via mise), não corre NodeSource.
# Executar como root (build Dockerfile ou `docker compose exec -u root dev /usr/local/bin/install-ai-clis.sh`).
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then
  echo "install-ai-clis: executar como root." >&2
  exit 1
fi

# Garantir Node/php do `mise install --system` no PATH (build Docker e exec não-login).
if [ -r /etc/profile.d/mise-system-runtimes.sh ]; then
  # shellcheck disable=SC1091
  . /etc/profile.d/mise-system-runtimes.sh
fi

NODE_MAJOR="${NODE_MAJOR:-22}"

need_nodesource=1
if command -v node >/dev/null 2>&1 && [ "${FORCE_NODE_INSTALL:-0}" != "1" ]; then
  major="$(node -p "process.versions.node.split('.')[0]" 2>/dev/null || true)"
  if [ "${major}" = "${NODE_MAJOR}" ]; then
    need_nodesource=0
  fi
fi

if [ "${need_nodesource}" -eq 1 ]; then
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
  apt-get install -y nodejs
  rm -rf /var/lib/apt/lists/*
fi

npm config set fund false
npm config set audit false
npm config set prefix /usr/local

npm install -g \
  @google/gemini-cli@latest \
  opencode-ai@latest \
  "@qwen-code/qwen-code@latest"

# Claude Code — instalador nativo recomendado pela Anthropic
# Copiar para /usr/local/bin (não symlink para /root/.local: utilizador `dev` não atravessa /root).
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
  for d in /root/.local/bin /usr/local/bin; do
    if [ -x "${d}/claude" ]; then
      if [ "${d}" != "/usr/local/bin" ]; then
        cp -f "${d}/claude" /usr/local/bin/claude
        chmod 755 /usr/local/bin/claude
      fi
      break
    fi
  done
fi

# Cursor Agent CLI — instalador oficial (copiar o directório da versão: cursor-agent + index.js + node embutido)
cursor_bundle_ok() {
  [ -x /usr/local/share/cursor-agent/current/cursor-agent ] && [ -f /usr/local/share/cursor-agent/current/index.js ]
}

if ! cursor_bundle_ok; then
  curl -fsSL https://cursor.com/install | bash
  shopt -s nullglob
  found=0
  for installdir in /root/.local/share/cursor-agent/versions/*/; do
    if [ -x "${installdir}cursor-agent" ] && [ -f "${installdir}index.js" ]; then
      rm -rf /usr/local/share/cursor-agent/current
      mkdir -p /usr/local/share/cursor-agent
      cp -a "${installdir%/}" /usr/local/share/cursor-agent/current
      chmod -R a+rX /usr/local/share/cursor-agent/current
      ln -sf /usr/local/share/cursor-agent/current/cursor-agent /usr/local/bin/agent
      found=1
      break
    fi
  done
  shopt -u nullglob
  if [ "${found}" -ne 1 ]; then
    echo "install-ai-clis: aviso — pacote cursor-agent não encontrado após install." >&2
  fi
fi

echo "install-ai-clis: concluído. Verifique: node -v, gemini --version, opencode --version, qwen --version, claude --version, agent --version"
