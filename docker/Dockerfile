# Pin explícito LTS — não usar ubuntu:latest
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

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
    && rm -rf /var/lib/apt/lists/*

# fd-find no Ubuntu expõe o binário como fdfind
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Evitar colisão de UID 1000 com o utilizador stock `ubuntu` quando o entrypoint alinha ao host.
RUN userdel -r ubuntu 2>/dev/null || true; \
    groupdel ubuntu 2>/dev/null || true

# Utilizador base (1001 inicial; UID/GID finais vêm do host via entrypoint).
# UID/GID finais vêm do host via entrypoint (USER_ID / GROUP_ID).
RUN groupadd -g 1001 dev && \
    useradd -u 1001 -g dev -m -s /bin/zsh dev

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY install-ai-clis.sh /usr/local/bin/install-ai-clis.sh
RUN chmod +x /usr/local/bin/install-ai-clis.sh

ARG INSTALL_AI_CLIS=0
RUN if [ "$INSTALL_AI_CLIS" = "1" ]; then /usr/local/bin/install-ai-clis.sh; fi

WORKDIR /home/dev/workspace

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["zsh", "-l"]
