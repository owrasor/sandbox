# Research: Neovim estável oficial (004-update-neovim-stable)

**Data**: 2026-04-06

## 1. Fonte de verdade da versão estável

**Decision**: Tratar a documentação oficial [Install - Neovim](https://neovim.io/doc/install/) como referência de *canal* (**stable**), com artefactos em [GitHub Releases](https://github.com/neovim/neovim/releases); para Linux x86_64 usar `nvim-linux-x86_64.tar.gz` (secção “Install from download” / “Pre-built archives”).

**Rationale**: Cumpre FR-001 da spec (Input do utilizador aponta explicitamente para `neovim.io/doc/install/`). O link “Latest stable release” resolve para o tag **latest** do repositório.

**Alternatives considered**:

- **Apenas `apt install neovim` (Ubuntu 24.04)**: Rejeitado — em 2026-Q2 o inventário do repo regista **0.9.5**, aquém do estável upstream (ver `docs/dev-environment/capability-inventory.md`).
- **PPA `neovim-ppa/stable`**: Rejeitado para imagem mínima — a própria documentação Neovim indica que a equipa Neovim **não** mantém o PPA; aumenta superfície de confiança e variabilidade.
- **AppImage**: Possível em desktop; em Docker minimal costuma exigir workarounds (`--appimage-extract`); mais frágil que tarball.
- **mise `neovim`**: Alinharia com PHP/Node; depende de plugin/registry mise estável e de política interna. Reservado como alternativa futura se o projeto quiser unificar **todas** as ferramentas versionadas no mise; para esta feature o tarball espelha literalmente o guia oficial Linux.

## 2. Versão estável corrente (snapshot de pesquisa)

**Decision**: Para documentação e pinagem inicial, usar o tag **v0.12.1** (nome de release “Nvim 0.12.1”), obtido via API `GET https://api.github.com/repos/neovim/neovim/releases/latest` em 2026-04-06.

**Rationale**: Reproduzibilidade do build; `latest` no Dockerfile sem pinos quebra builds antigos quando sai nova minor.

**Alternatives considered**: URL `.../releases/latest/download/...` sem pin — aceitável só em prototipagem; para merge, preferir URL com tag **v0.12.1** ou `ARG NEOVIM_VERSION` com default `v0.12.1`.

## 3. Integração na imagem Ubuntu 24.04

**Decision**:

1. Remover o pacote **`neovim`** da lista `apt-get install` no `Dockerfile` (evitar dois binários e PATH ambíguo).
2. Em `RUN`, fazer download do `.tar.gz` oficial, extrair para **`/opt/nvim-linux-x86_64`** (layout documentado no guia de instalação).
3. Expor **`/opt/nvim-linux-x86_64/bin`** no `PATH` para todos os utilizadores relevantes: ficheiro em `/etc/profile.d/` (e coerência com o padrão já usado para mise em `/etc/zsh/zprofile`).

**Rationale**: Espelha os comandos oficiais Linux da página de instalação; `/opt` é convencional para software empacotado fora do apt.

**Alternatives considered**: Instalar em `/usr/local` com `stow`-like manual — mais passos; `/opt` + PATH é o mesmo padrão do doc.

## 4. Configuração do utilizador (FR-004)

**Decision**: Não alterar `entrypoint.sh` nem montagens documentadas de dotfiles; Neovim continua a ler `~/.config/nvim` por defeito (XDG), igual ao pacote distro.

**Rationale**: A spec exige preservar convenções já documentadas.

**Alternatives considered**: Flatpak/snap — mudaria caminhos de config (`~/.var/app/...`); explicitamente fora de escopo.

## Resolução de NEEDS CLARIFICATION

Não havia marcadores NEEDS CLARIFICATION pendentes no `plan.md` após leitura da spec; decisões acima fecham escopo técnico para implementação.
