# Inventário de capacidades — imagem `dev`

**Última actualização**: 2026-04-06  
**Política**: [freshness-policy.md](./freshness-policy.md) v2026-04-06

Legenda **compliance**: `ok` | `exception` | `pending`  
**Fornecedor / última estável**: referência verificada na data da última auditoria (revalidar em cada auditoria).

| ID | Nome | Criticidade | Dono | Canal | Versão no ambiente | Última estável fornecedor (ref.) | compliance | Notas |
|----|------|-------------|------|-------|--------------------|----------------------------------|------------|-------|
| `base-os` | Ubuntu LTS base | P2 | Maintainer imagem | OCI `ubuntu:24.04` | 24.04 (digest no build) | [Ubuntu 24.04 LTS](https://releases.ubuntu.com/) | ok | Pin explícito no Dockerfile |
| `php-runtime` | PHP (CLI) | P1 | Maintainer imagem | mise `php@8.4` | 8.4.19 | [PHP 8.4 releases](https://www.php.net/releases/) | ok | Patch via rebuild mise |
| `node-runtime` | Node.js | P1 | Maintainer imagem | mise `node@22` | 22.22.2 | [Node 22.x releases](https://nodejs.org/) | ok | v22 LTS line |
| `nvim-editor` | Neovim | P1 | Maintainer imagem | apt (`neovim`) | 0.9.5 | [Neovim stable](https://github.com/neovim/neovim/releases) | exception | Distro atrás do upstream estável ≥ 0.10; ver [platform-evaluation.md](./platform-evaluation.md); migrar para mise ou build se política exigir |
| `git` | Git | P2 | Maintainer imagem | apt | 2.43.0 | [Git SCM](https://git-scm.com/) | ok | Segurança via `apt-get upgrade` no rebuild |
| `ripgrep` | ripgrep | P2 | Maintainer imagem | apt | 14.1.0 | [BurntSushi/ripgrep releases](https://github.com/BurntSushi/ripgrep/releases) | ok | |
| `fd` | fd-find | P3 | Maintainer imagem | apt + symlink `fd` | 9.0.0 (fdfind) | [sharkdp/fd releases](https://github.com/sharkdp/fd/releases) | ok | |
| `tmux` | tmux | P2 | Maintainer imagem | apt | 3.4 | [tmux releases](https://github.com/tmux/tmux/releases) | ok | |
| `build-toolchain` | build-essential + libs dev | P2 | Maintainer imagem | apt (lista no Dockerfile) | (pacotes Ubuntu 24.04) | Ubuntu archives | ok | Actualização em bloco com base image |
| `ai-clis` | CLIs de IA (script) | P3 | Maintainer imagem | `install-ai-clis.sh` + npm | (ver script / build log) | Documentação de cada CLI | pending | Auditar versões em auditoria dedicada se necessário |

### Resumo P1 (auditoria 2026-Q2-01)

- Itens P1: **3** (`php-runtime`, `node-runtime`, `nvim-editor`).  
- Em conformidade directa: **2/3**.  
- Excepção documentada: **1/3** (`nvim-editor`).  
- **Percentagem P1 ok ou excepção**: 100% (≥ 90% SC-002).
