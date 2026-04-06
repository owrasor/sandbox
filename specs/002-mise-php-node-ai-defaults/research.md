# Research: Runtimes mise, PHP 8.4, Node 22 e CLIs de IA por defeito

**Feature**: `002-mise-php-node-ai-defaults`  
**Date**: 2026-04-06

## 1. Instalação do mise na imagem Docker

**Decision**: Instalar mise com o script oficial (`curl https://mise.run | sh`) durante o `Dockerfile` (como `root`), seguindo a documentação e o [Mise + Docker Cookbook](https://mise.jdx.dev/mise-cookbook/docker.html).

**Rationale**: Método suportado upstream; funciona em Ubuntu 24.04; reprodutível em CI/build local.

**Alternatives considered**:

- **Apt repository third-party**: mais complexo de manter e validar por release.
- **Asdf**: pedido explícito do utilizador foi **mise** (fork/evolução na mesma família; não substituir sem mudar a spec).

## 2. PHP 8.4 e Node 22 visíveis para todos os utilizadores (incl. `dev`)

**Decision**: Após instalar mise, executar `mise install --system php@8.4 node@22` (ou equivalente exacto aceite pelo registry no momento do build, p.ex. patch mais recente da linha 8.4 / 22).

**Rationale**: O cookbook documenta `--system` para instalação em caminho partilhado (`/usr/local/share/mise/installs` / integração com shims), evitando depender de `mise activate` só no `~/.zshrc` do utilizador que ainda pode ser sobrescrito por dotfiles do host.

**Alternatives considered**:

- **Apenas `mise use -g` no HOME do `dev`**: frágil com bind mount de dotfiles e ordem de carregamento do shell.
- **PHP/Node via apt + NodeSource**: duplica fontes de verdade e conflita com o requisito de gestão via mise.

## 3. CLIs de IA e Node

**Decision**: Refactor de `install-ai-clis.sh` para **não** usar o pipeline NodeSource quando já existir `node` no PATH (fornecido pelo mise) satisfazendo a major 22; usar `npm install -g` com prefixo `/usr/local` como hoje. Manter instaladores curl para Claude e Cursor Agent.

**Rationale**: Cumpre FR-003 (Node via mise) e evita duas instalações de Node. Reduz divergência de versão entre `node` do sistema e `node` do npm.

**Alternatives considered**:

- **Manter NodeSource sempre**: viola coerência “Node via mise”.
- **Instalar CLIs só com `mise x` em runtime**: mais frágil para globais e para root durante build.

## 4. Remover necessidade de `.env` para “ligar” CLIs de IA

**Decision**:

- Tornar a instalação das CLIs parte **incondicional** do build da imagem `dev` (sempre executar o script no `Dockerfile`), **ou** fixar o argumento de build a activo sem depender de variável no `.env` do utilizador.
- Remover ou deprecar `INSTALL_AI_CLIS` em `.env.example` e deixar de passar `INSTALL_AI_CLIS` desde o Compose como toggle obrigatório (o valor por defeito do Compose deve resultar em imagem com CLIs sem edição extra do `.env`).

**Rationale**: Alinha com SC-001 e User Story 3 da spec.

**Alternatives considered**:

- **Entrypoint que instala CLIs no primeiro run**: aumenta tempo de primeiro arranque e exige rede em runtime; pior UX que bake-in no build.

## 5. Shell de login (`zsh -l`) e PATH

**Decision**: Garantir que ficheiros de ambiente do sistema (ex. `/etc/profile.d/mise.sh` ou documentação mise para shims) colocam `mise`-managed binaries no PATH para sessões de login. Validar com `zsh -l -c 'command -v php node mise'`.

**Rationale**: O CMD do contentor é `zsh -l`; o utilizador real é `dev` após entrypoint.

**Alternatives considered**:

- **Só documentar `eval "$(mise activate zsh)"` nos dotfiles**: depende do repositório de dotfiles do utilizador; a spec exige disponível “sem configuração ad hoc” na primeira sessão.

## 6. Dependências de sistema para PHP (mise)

**Decision**: Incluir pacotes de build necessários aos plugins mise/php (ex. `libxml2-dev`, `libsqlite3-dev`, `libssl-dev`, etc.) conforme erros de build iterativos ou documentação do plugin; começar pelo conjunto mínimo habitual em imagens dev Ubuntu.

**Rationale**: Builds de PHP via mise frequentemente compilam extensões.

**Alternatives considered**:

- **PHP do Ubuntu + só Node no mise**: viola FR-002 (PHP via mise).
