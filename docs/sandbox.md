# Sandbox Docker para desenvolvimento

Ambiente de desenvolvimento em contentor: código e dotfiles no host via bind mount, ferramentas base isoladas (Ubuntu 24.04), **zsh**, **tmux**, **Neovim**, exposição **LAN** por portas e túnel **opcional** com **ngrok**.

**Governação de frescura das ferramentas** (SLAs, inventário, auditorias): ver **[dev-environment/freshness-policy.md](./dev-environment/freshness-policy.md)** e o índice **[dev-environment/README.md](./dev-environment/README.md)**.

## Pré-requisitos

- Docker e Docker Compose v2
- Clone local do repositório [owrasor/dotfiles](https://github.com/owrasor/dotfiles) (caminho usado em `DOTFILES_HOST`)
- Ficheiro `.env` na raiz do repo (a partir de `.env.example`)

## Configuração rápida

```bash
cp .env.example .env
```

Editar `.env`:

- `USER_ID` / `GROUP_ID`: normalmente `id -u` e `id -g` no host.
- `DOTFILES_HOST`: caminho absoluto do clone dos dotfiles.
- `SSH_DIR`: normalmente `$HOME/.ssh` no host. No ficheiro `.env` usa-se o caminho **absoluto** (Compose não expande `~`).
- `WORKSPACE_HOST`: por defeito `./workspace` (pasta neste repositório).

Permissões SSH no host: diretório `~/.ssh` com modo `700`, chaves privadas `600`.

O entrypoint **não** faz `chown` recursivo sobre `workspace` nem `dotfiles` (evita alterar o dono dos ficheiros no host e falhas com `.ssh` montado só de leitura). Mantém `USER_ID`/`GROUP_ID` iguais ao teu utilizador no host para o bind mount do workspace ter donos coerentes.

## Construir e entrar

```bash
docker compose build dev
docker compose run --rm dev
```

Dentro do contentor o utilizador é `dev`, shell de login **zsh**. O **diretório de trabalho inicial** do serviço `dev` (Compose `working_dir` e imagem `WORKDIR`) é **`/home/dev`**. O código do projecto continua montado em **`/home/dev/workspace`** — usa `cd workspace` (relativo à home) ou `cd /home/dev/workspace` quando precisares de trabalhar no repositório.

### Aplicar dotfiles

O clone dos dotfiles está em `/home/dev/dotfiles`. Segue o procedimento do próprio repositório (por exemplo GNU Stow ou script de instalação indicado no README do dotfiles), por exemplo:

```bash
cd ~/dotfiles
# Exemplo genérico — confirma no README do teu fork/clone
stow zsh tmux nvim
```

Objetivo: **zsh**, **tmux** e **Neovim** consumirem a configuração **a partir desse clone** (symlinks ou layout que o dotfiles definir), não montar `~/.config/nvim` diretamente do home do host em alternativa.

### Fluxo tmux + Neovim

Com TTY interativo (`docker compose run` já usa `stdin_open` e `tty`):

```bash
tmux new -s dev
# ou: tmux attach -t dev
```

Dentro do tmux, abre **nvim** num painel e usa outros painéis/janelas para servidores de desenvolvimento ou CLIs.

Se cores ou truecolor estiverem estranhos, alinha `TERM` (no `.env` ou no host) com o que o dotfiles espera (ex. `xterm-256color` ou `tmux-256color`).

### `known_hosts` e montagem SSH `:ro`

Com `~/.ssh` montado em **read-only**, atualizações a `known_hosts` ou escritas nessa árvore **falham** dentro do contentor. Se precisares de gravar `known_hosts`, faz-o no host ou ajusta a estratégia de mounts (documenta o teu caso localmente).

## Expor serviços na LAN

No `docker-compose.yml`, o serviço `dev` publica portas de exemplo (`3000`, `8080`, `5173`). Edita a lista conforme o projeto. A partir de outro dispositivo na LAN acede a `http://<IP-do-host>:<porta>`.

Restringe portas na firewall do host se só quiseres localhost ou tráfego específico.

## Angie: proxy reverso `*.test` com HTTPS

O serviço **`angie`** expõe **80** e **443** no host e faz proxy reverso para upstreams na rede `sandbox` (ex.: `dev:5173`), com TLS terminado no contentor. Virtual hosts adicionam-se em **`docker/angie/sites/*.conf`** (ver `docker/angie/sites/README.md`); certificados em `docker/angie/certs/` (gitignored) ou `ANGIE_CERTS_HOST` no `.env`.

Guia passo a passo (hosts, mkcert, `curl`, validação `angie -t`): [specs/001-angie-proxy-test/quickstart.md](../specs/001-angie-proxy-test/quickstart.md).

```bash
docker compose up -d dev angie
```

### Conflito de portas 80/443 no host

Se outro serviço (Apache, outro proxy, Caddy) já usar **80** ou **443**, o contentor `angie` não consegue fazer bind — o `docker compose up` falha ou o mapeamento fica indisponível. Liberta as portas (`ss -tlnp | grep -E ':80|:443'`) ou altera temporariamente o mapeamento no `docker-compose.yml` (ex.: `8080:80`, `8443:443`) e ajusta o teu fluxo local (aceder a `https://example-app.test:8443` ou equivalente).

### Debug HTTPS com `curl -k`

Quando o browser mostra certificado não confiável mas queres confirmar que o Angie responde, usa `curl -vk https://<hostname>.test/` **apenas** em desenvolvimento local. Não substitui instalar/confiar na CA mkcert para testar cookies `Secure` e comportamento real do browser.

## Internet: perfil `public` (ngrok)

1. Define `NGROK_AUTHTOKEN` no `.env` (token da consola ngrok).
2. Ajusta `NGROK_TUNNEL_TARGET` se o serviço não estiver na porta `3000` **dentro** do contentor `dev` (formato `dev:<porta>` na rede Docker).
3. Sobe o stack com o perfil:

```bash
docker compose --profile public up
```

O serviço **ngrok** partilha a rede `sandbox` com `dev` e cria um túnel HTTP até `NGROK_TUNNEL_TARGET` (por defeito `dev:3000`). Não commits o token; roda-o se vazar.

## Runtimes (mise, PHP, Node, Neovim)

A imagem `dev` instala **[mise](https://mise.jdx.dev/)** no build e corre `mise install --system php@8.4 node@22`. Os binários ficam em `/usr/local/share/mise/installs/...`; o PATH de shell de login (`zsh -l`) é configurado em `/etc/profile.d/mise-system-runtimes.sh` e em `/etc/zsh/zprofile` (o zsh de login em Ubuntu não carrega `profile.d` por defeito).

**Neovim** não vem do APT: usa-se o **tarball estável oficial** (Linux x86_64) referenciado em [neovim.io/doc/install](https://neovim.io/doc/install/), com versão pinada por `ARG NEOVIM_VERSION` no `docker/Dockerfile`, extraído para `/opt/nvim-linux-x86_64` e antecedido no `PATH` via `/etc/profile.d/neovim-upstream.sh` (e o mesmo snippet em `zprofile`).

- **Primeira sessão**: `php`, `node` e `mise` devem estar disponíveis **sem** depender de dotfiles do host.
- **Dotfiles do host**: se sobrescreverem `PATH` ou desactivarem o perfil do sistema, valida com `docker compose run --rm dev zsh -l -c 'command -v php node mise'`.
- **Tempos de build**: a primeira `docker compose build dev` pode demorar (compilação/download de PHP via mise, `npm install -g`, instaladores externos). Requer rede estável.

## CLIs de IA

O script `docker/install-ai-clis.sh` corre **sempre** durante o build da imagem. **Não** é necessário editar o `.env` para “ligar” esta fase.

- **Node para npm**: se já existir no PATH uma major **22** (o Node instalado pelo mise), o script **não** adiciona o repositório NodeSource. Caso contrário, usa NodeSource como *fallback* (`NODE_MAJOR`, por defeito 22).
- **npm (prefixo `/usr/local`)**: `@google/gemini-cli`, **`opencode-ai`** (comando `opencode`), `@qwen-code/qwen-code`.
- **Claude Code**: instalador `https://claude.ai/install.sh`; binário em `/usr/local/bin/claude` (cópia a partir de `~/.local` do root no build, para o utilizador `dev` não depender de `/root`).
- **Cursor Agent**: instalador `https://cursor.com/install`; o pacote completo fica em `/usr/local/share/cursor-agent/current`, com `agent` em `/usr/local/bin` (o launcher precisa de `index.js` e do `node` embutido no mesmo directório).

Para **reinstalar** ou actualizar manualmente (como root):

```bash
docker compose exec -u root dev /usr/local/bin/install-ai-clis.sh
```

Variáveis de API/tokens: vê `.env.example` e a documentação de cada ferramenta.

Limitação: “isolamento” não inclui o que está montado: o contentor **lê/escreve** em `workspace` e `dotfiles`, e **lê** `~/.ssh` (mesmo `:ro`). Não executes software não confiável com esses mounts ativos. Mitigação futura: SSH agent forwarding em vez de montar chaves privadas.

## Comandos úteis

| Objetivo | Comando |
|----------|---------|
| Shell interativo | `docker compose run --rm dev` |
| Shell num contentor já a correr | `docker compose exec dev zsh` (utilizador **dev** — a imagem define `USER dev`) |
| Reexecutar instalador de CLIs (root) | `docker compose exec -u root dev /usr/local/bin/install-ai-clis.sh` |
| Dev + proxy `.test` (Angie) | `docker compose up -d dev angie` |
| LAN + ngrok | `docker compose --profile public up` |

## Diretório inicial da sessão e `sudo`

- **CWD ao entrar**: após `docker compose run --rm dev` ou `docker compose exec dev zsh`, confirma com `pwd` — deve ser `/home/dev`.
- **`sudo`**: o utilizador `dev` tem elevação **sem palavra-passe** dentro deste contentor (apenas ambiente de desenvolvimento). Verificação rápida:

```bash
docker compose run --rm dev zsh -lc 'sudo -n true && sudo -n id -u'
```

A segunda linha deve mostrar `0`. Guia passo a passo: [specs/005-dev-shell-home-sudo/quickstart.md](../specs/005-dev-shell-home-sudo/quickstart.md).

## Verificação sugerida

- `zsh` como shell, dotfiles aplicados.
- `tmux -V`, sessão criada/anexada.
- `nvim --version` **dentro** do tmux com config carregada.
- `ssh -T git@github.com` (chaves do host via mount).
- Servidor de desenvolvimento na porta mapeada, acesso a partir da LAN.
- Com perfil `public`, URL ngrok a servir o mesmo serviço.

## O que ficou de fora (por desenho)

Orquestração Kubernetes, GPU, substituição de ngrok por Cloudflare Tunnel (podes documentar como alternativa localmente).
