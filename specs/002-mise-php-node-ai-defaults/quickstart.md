# Quickstart — verificação `002-mise-php-node-ai-defaults`

## Pré-requisitos

- Docker e Docker Compose v2.
- `.env` válido (caminhos `DOTFILES_HOST`, `SSH_DIR`, ids) como hoje — **sem** necessidade de activar instalação de CLIs via variável dedicada.

## Passos

1. **Build limpo (recomendado para QA)**

   ```bash
   docker compose build --no-cache dev
   ```

2. **Smoke de runtimes**

   ```bash
   docker compose run --rm dev zsh -l -c 'mise --version && php -v && node -v'
   ```

   Esperado: `php` vem de `/usr/local/share/mise/installs/php/8.4/...`, `node` de `/usr/local/share/mise/installs/node/22/...`; versões **8.4.x** e **v22.x**; `mise` imprime versão.

3. **Smoke de mise (visibilidade)**

   ```bash
   docker compose run --rm dev zsh -l -c 'mise --version && mise ls'
   ```

   Esperado: `mise ls` lista `php` e `node` como `(system)` alinhados a **8.4** e **22**.

4. **Smoke de CLIs de IA**

   ```bash
   docker compose run --rm dev zsh -l -c 'command -v gemini opencode qwen claude agent'
   ```

   OpenCode: pacote npm `opencode-ai`, comando **`opencode`**. Ajustar só se o upstream mudar nomes.

5. **Confirmar ausência de toggle `.env` para instalação**

   - Com `.env` mínimo (como `.env.example`, sem activar nada só para CLIs), após `docker compose build dev`, o passo 4 continua a passar.

## Falhas comuns

- **Rede**: build falha ao obter toolchains mise ou npm — repetir com rede ou mirror.
- **PHP build deps**: faltam headers `-dev` — o Dockerfile inclui o conjunto usado para compilar PHP 8.4 via mise; ver `research.md` §6 se uma extensão nova falhar.
- **Dotfiles do host**: podem alterar PATH na shell interactiva; validar com `docker compose run --rm dev zsh -l -c '...'` como acima.
- **Cursor `agent`**: o instalador coloca ficheiros em `~/.local` do utilizador que corre o script; a imagem copia o pacote para `/usr/local/share/cursor-agent/current` para o utilizador `dev` conseguir executar.
