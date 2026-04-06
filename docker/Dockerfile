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
    zsh \
    tmux \
    neovim \
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
    && rm -rf /var/lib/apt/lists/*

# fd-find no Ubuntu expõe o binário como fdfind
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Evitar colisão de UID 1000 com o utilizador stock `ubuntu` quando o entrypoint alinha ao host.
RUN userdel -r ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true

# Utilizador base (1001 inicial; UID/GID finais vêm do host via entrypoint).
RUN groupadd -g 1001 dev && \
    useradd -u 1001 -g dev -m -s /bin/zsh dev

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

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY install-ai-clis.sh /usr/local/bin/install-ai-clis.sh
RUN chmod +x /usr/local/bin/install-ai-clis.sh

# CLIs de IA: parte fixa do build; usa Node do mise (ver install-ai-clis.sh)
RUN /usr/local/bin/install-ai-clis.sh

# Alguns wrappers (ex. Cursor `agent`) referem `/usr/local/bin/node`; o Node real vem do mise.
RUN ln -sf /usr/local/share/mise/installs/node/22/bin/node /usr/local/bin/node \
    && ln -sf /usr/local/share/mise/installs/node/22/bin/npm /usr/local/bin/npm \
    && ln -sf /usr/local/share/mise/installs/node/22/bin/npx /usr/local/bin/npx

WORKDIR /home/dev/workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["zsh", "-l"]
