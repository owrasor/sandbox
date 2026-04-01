#!/usr/bin/env bash
# Instala Node (LTS atual na fila NodeSource) e CLIs de IA com prefixo global em /usr/local.
# Executar como root (build Dockerfile com INSTALL_AI_CLIS=1 ou `docker compose run --user root dev install-ai-clis`).
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then
  echo "install-ai-clis: executar como root." >&2
  exit 1
fi

NODE_MAJOR="${NODE_MAJOR:-22}"

if ! command -v node >/dev/null 2>&1 || [ "${FORCE_NODE_INSTALL:-0}" = "1" ]; then
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
  apt-get install -y nodejs
  rm -rf /var/lib/apt/lists/*
fi

npm config set fund false
npm config set audit false
npm config set prefix /usr/local

npm install -g \
  @google/gemini-cli@latest \
  @opencode-ai/cli@latest \
  "@qwen-code/qwen-code@latest"

# Claude Code — instalador nativo recomendado pela Anthropic
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
  for d in /root/.local/bin /usr/local/bin; do
    if [ -x "${d}/claude" ]; then
      if [ "${d}" != "/usr/local/bin" ]; then
        ln -sf "${d}/claude" /usr/local/bin/claude
      fi
      break
    fi
  done
fi

# Cursor Agent CLI — instalador oficial
if ! command -v agent >/dev/null 2>&1; then
  curl -fsSL https://cursor.com/install | bash
  for d in /root/.local/bin /home/dev/.local/bin /usr/local/bin; do
    if [ -x "${d}/agent" ]; then
      if [ "${d}" != "/usr/local/bin" ]; then
        ln -sf "${d}/agent" /usr/local/bin/agent
      fi
      break
    fi
  done
fi

echo "install-ai-clis: concluído. Verifique: node -v, gemini --version, opencode --version, qwen --version, claude --version, agent --version"
