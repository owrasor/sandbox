# Pin explícito LTS — não usar ubuntu:latest
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg \
    gosu \
    sudo \
    zsh \
    tmux \
    build-essential \
    pkg-config \
    ripgrep \
    fd-find \
    bc \
    libevent-dev \
    autoconf \
    dpkg-dev \
    file \
    re2c \
    bison \
    libssl-dev \
    libxml2-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libzip-dev \
    libonig-dev \
    libreadline-dev \
    libgmp-dev \
    libsodium-dev \
    libffi-dev \
    libbz2-dev \
    libgd-dev \
    libfreetype6-dev \
    libpq-dev \
    default-libmysqlclient-dev \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Neovim — tarball estável oficial (https://neovim.io/doc/install/); pin explícito para builds reprodutíveis
ARG NEOVIM_VERSION=v0.12.1
RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz" -o /tmp/nvim-linux-x86_64.tar.gz \
    && rm -rf /opt/nvim-linux-x86_64 \
    && tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz \
    && rm -f /tmp/nvim-linux-x86_64.tar.gz \
    && printf '%s\n' \
    '# Neovim estável upstream (ARG NEOVIM_VERSION no Dockerfile)' \
    'export PATH="/opt/nvim-linux-x86_64/bin:${PATH}"' \
    > /etc/profile.d/neovim-upstream.sh \
    && chmod 644 /etc/profile.d/neovim-upstream.sh \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# fd-find no Ubuntu expõe o binário como fdfind
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Evitar colisão de UID 1000 com o utilizador stock `ubuntu` quando o entrypoint alinha ao host.
RUN userdel -r ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true

# Utilizador base (1001 inicial; UID/GID finais vêm do host via entrypoint).
RUN groupadd -g 1001 dev && \
    useradd -u 1001 -g dev -m -s /bin/zsh dev

RUN printf '%s\n' 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev && chmod 0440 /etc/sudoers.d/dev

# Preservar variáveis opcionais do Compose através de `sudo -E` no entrypoint (evita wipe de env).
RUN printf '%s\n' 'Defaults env_keep += "DOTFILES_BOOTSTRAP_SCRIPT SANDBOX_DOTFILES_BOOTSTRAP_SKIP USER_ID GROUP_ID"' \
    > /etc/sudoers.d/sandbox-bootstrap-env \
    && chmod 0440 /etc/sudoers.d/sandbox-bootstrap-env \
    && visudo -cf /etc/sudoers.d/sandbox-bootstrap-env

# mise — instalador oficial (https://mise.run); PHP 8.4 + Node 22 como ferramentas de sistema partilhadas
# (cookbook: https://mise.jdx.dev/mise-cookbook/docker.html — `mise install --system` + devcontainers)
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"

RUN curl -fsSL https://mise.run | sh

RUN mise install --system php@8.4 node@22

# `mise install --system` coloca binários em /usr/local/share/mise/installs/... (sem shims).
# O zsh de login em Ubuntu não percorre /etc/profile.d — garantir PATH para `dev` e para RUNs seguintes.
RUN printf '%s\n' \
    '# mise — runtimes de sistema (PHP 8.4, Node 22)' \
    'export PATH="/usr/local/share/mise/installs/node/22/bin:/usr/local/share/mise/installs/php/8.4/bin:${PATH}"' \
    > /etc/profile.d/mise-system-runtimes.sh && chmod 644 /etc/profile.d/mise-system-runtimes.sh \
    && printf '\n%s\n%s\n' \
    '# mise — mesmo PATH em zsh login (zprofile não inclui profile.d por defeito)' \
    '[ -r /etc/profile.d/mise-system-runtimes.sh ] && . /etc/profile.d/mise-system-runtimes.sh' \
    >> /etc/zsh/zprofile

RUN printf '\n%s\n%s\n' \
    '# Neovim upstream (zsh login)' \
    '[ -r /etc/profile.d/neovim-upstream.sh ] && . /etc/profile.d/neovim-upstream.sh' \
    >> /etc/zsh/zprofile

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY sandbox-dotfiles-bootstrap.sh /usr/local/bin/sandbox-dotfiles-bootstrap.sh
RUN chmod +x /usr/local/bin/sandbox-dotfiles-bootstrap.sh

COPY zshenv-sandbox-bootstrap.snippet /tmp/zshenv-sandbox-bootstrap.snippet
RUN cat /tmp/zshenv-sandbox-bootstrap.snippet >> /etc/zsh/zshenv \
    && rm -f /tmp/zshenv-sandbox-bootstrap.snippet

COPY install-ai-clis.sh /usr/local/bin/install-ai-clis.sh
RUN chmod +x /usr/local/bin/install-ai-clis.sh

# CLIs de IA: parte fixa do build; usa Node do mise (ver install-ai-clis.sh)
RUN /usr/local/bin/install-ai-clis.sh

# Alguns wrappers (ex. Cursor `agent`) referem `/usr/local/bin/node`; o Node real vem do mise.
RUN ln -sf /usr/local/share/mise/installs/node/22/bin/node /usr/local/bin/node \
    && ln -sf /usr/local/share/mise/installs/node/22/bin/npm /usr/local/bin/npm \
    && ln -sf /usr/local/share/mise/installs/node/22/bin/npx /usr/local/bin/npx

# PHP / Laravel: verificação de extensões (Laravel 12.x server requirements) + Composer global + instalador
COPY verify-php-laravel-extensions.sh /usr/local/bin/verify-php-laravel-extensions.sh
RUN chmod +x /usr/local/bin/verify-php-laravel-extensions.sh \
    && export PATH="/usr/local/share/mise/installs/node/22/bin:/usr/local/share/mise/installs/php/8.4/bin:${PATH}" \
    && /usr/local/bin/verify-php-laravel-extensions.sh

ENV COMPOSER_HOME=/usr/local/share/composer
RUN mkdir -p "${COMPOSER_HOME}" \
    && export PATH="/usr/local/share/mise/installs/node/22/bin:/usr/local/share/mise/installs/php/8.4/bin:${PATH}" \
    && composer global require laravel/installer \
    && ln -sf "${COMPOSER_HOME}/vendor/bin/laravel" /usr/local/bin/laravel \
    && chmod -R a+rX "${COMPOSER_HOME}"

WORKDIR /home/dev

# Processo principal como `dev`: `docker compose exec` / `docker exec` usam este utilizador
# por defeito em vez de root.
USER dev

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["zsh", "-l"]
