# Sandbox — ambiente de desenvolvimento em Docker

Repositório de **ambiente de desenvolvimento containerizado**: shell interativo com Ubuntu 24.04, dotfiles e workspace montados do host, exposição de portas na LAN, **proxy reverso Angie** para hostnames `*.test` com HTTPS local e, opcionalmente, túnel público com **ngrok**.

O objetivo é trabalhar dentro de um contentor com ferramentas consistentes (zsh, tmux, Neovim, Git, build essentials) sem sacrificar o código e a configuração pessoal que permanecem no disco do host.

## Requisitos

- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose v2](https://docs.docker.com/compose/)
- Clone local dos [dotfiles](https://github.com/owrasor/dotfiles) (caminho indicado em `DOTFILES_HOST` no `.env`)
- Portas **80** e **443** livres no host se fores usar o serviço **Angie** (ou ajusta o mapeamento no Compose)

## Início rápido

```bash
cp .env.example .env
```

Edita `.env` e define pelo menos:

| Variável               | Descrição                                                                                 |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| `USER_ID` / `GROUP_ID` | Normalmente `id -u` e `id -g` no Linux, para ficheiros no bind mount terem o dono correto |
| `DOTFILES_HOST`        | Caminho **absoluto** ao clone dos dotfiles                                                |
| `SSH_DIR`              | Caminho **absoluto** à pasta `.ssh` do host (montagem só leitura)                         |
| `WORKSPACE_HOST`       | Diretório de trabalho no host (por defeito `./workspace`)                                 |

Constrói e entra no contentor de desenvolvimento:

```bash
docker compose build
docker compose run --rm dev
```

Dentro do contentor: utilizador `dev`, shell de login **zsh**, diretório de trabalho `/home/dev/workspace`. Aplica os dotfiles a partir de `~/dotfiles` conforme o README do repositório de dotfiles (por exemplo Stow).

## Serviços do Compose

| Serviço   | Função                                                                                                                                                           |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **dev**   | Imagem customizada (`docker/Dockerfile`): Ubuntu 24.04, zsh, tmux, Neovim, ferramentas de build; portas publicadas por defeito `3000`, `8080`, `5173`            |
| **angie** | [Angie](https://angie.software/) `1.11.4` como proxy reverso; TLS com certificados em `docker/angie/certs/` (ver documentação em `docker/angie/certs/README.md`) |
| **ngrok** | Perfil Compose `public`: túnel HTTP até `NGROK_TUNNEL_TARGET` (por defeito `dev:3000`)                                                                           |

Subir desenvolvimento e proxy local:

```bash
docker compose up -d dev angie
```

Túnel público (requer `NGROK_AUTHTOKEN` no `.env`):

```bash
docker compose --profile public up
```

## Estrutura do repositório

```text
.
├── docker-compose.yml      # Orquestração: dev, angie, ngrok (perfil public)
├── .env.example            # Modelo de variáveis de ambiente
├── docker/
│   ├── Dockerfile          # Imagem do serviço dev
│   ├── entrypoint.sh
│   ├── install-ai-clis.sh  # Instalação opcional de Node e CLIs de IA
│   └── angie/              # Configuração Angie + sites *.conf + certs (gitignored)
├── docs/
│   └── sandbox.md          # Guia completo (tmux, LAN, Angie, ngrok, CLIs de IA)
├── specs/                  # Especificações e quickstarts (ex.: proxy Angie)
└── workspace/              # Diretório de trabalho sugerido no host (criar se usar WORKSPACE_HOST=./workspace)
```

Novos virtual hosts: ficheiros em `docker/angie/sites/*.conf` — ver [docker/angie/sites/README.md](docker/angie/sites/README.md).

## Documentação detalhada

- **[docs/sandbox.md](docs/sandbox.md)** — fluxo completo: dotfiles, tmux, SSH em montagem read-only, exposição na LAN, Angie, ngrok, instalação de CLIs de IA (`INSTALL_AI_CLIS` ou script pós-arranque).
- **[specs/001-angie-proxy-test/quickstart.md](specs/001-angie-proxy-test/quickstart.md)** — mkcert, `/etc/hosts`, validação `angie -t` e troubleshooting HTTPS.

## Segurança (nota breve)

O contentor monta o **workspace**, os **dotfiles** e lê **`.ssh`** do host. Não executes software não confiável com estes mounts ativos; o token do ngrok não deve ser commitado (mantê-lo só no `.env`, que não entra no Git).
