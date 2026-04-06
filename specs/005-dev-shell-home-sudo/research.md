# Research: Shell na home e sudo (005-dev-shell-home-sudo)

**Data**: 2026-04-06

## 1. Diretório inicial em `docker compose exec dev zsh`

**Decision**: Definir `working_dir: /home/dev` no serviço `dev` em `docker-compose.yml` e `WORKDIR /home/dev` no `Dockerfile`.

**Rationale**: O Docker Compose aplica o `working_dir` do serviço ao processo criado por `docker compose exec <service> <cmd>` (CWD da sessão). O pedido do utilizador cita explicitamente `docker compose exec dev zsh` **sem** flags extra (`-w`); esta é a forma mais directa de cumprir FR-001 sem exigir novo hábito de linha de comando. Alinhar `WORKDIR` na imagem evita surpresas em `docker run` / ferramentas que leem o WORKDIR da imagem.

**Alternatives considered**:

- **Documentar apenas `docker compose exec -w /home/dev dev zsh`**: Rejeitado — contradiz o comando exacto pedido no Input.
- **`cd /home/dev` no zprofile global**: Fragilidade com dotfiles do utilizador que também alteram diretório; a spec já nota que perfis podem mudar CWD após o arranque — melhor controlar CWD no nível do orquestrador.
- **Manter `working_dir` em `/home/dev/workspace` e wrapper `zsh`**: Mais indireto e manutenção extra.

## 2. Impacto no fluxo “código no workspace”

**Decision**: O código continua montado em **`/home/dev/workspace`**; desenvolvedores passam a fazer **`cd workspace`** (caminho relativo a `/home/dev`) ou caminho absoluto quando precisam da árvore do repositório.

**Rationale**: FR-004 exige preservar montagens; apenas muda o diretório **por defeito** ao entrar. A documentação actual ([`docs/sandbox.md`](../../docs/sandbox.md)) afirma que o diretório inicial do compose é `/home/dev/workspace` — deve ser actualizada para evitar contradição.

**Alternatives considered**:

- **Symlink `~/workspace` → `/home/dev/workspace`**: Opcional como melhoria futura; não necessário para MVP se `cd workspace` estiver documentado.

## 3. Instalação e política de `sudo` para `dev`

**Decision**: Instalar o pacote **`sudo`** via `apt-get` no `Dockerfile`; criar **`/etc/sudoers.d/dev`** com regra **`dev ALL=(ALL) NOPASSWD:ALL`**, permissões **`0440`**, e validar com `visudo -c` no build se se optar por ficheiro include (padrão Ubuntu inclui `#includedir /etc/sudoers.d`).

**Rationale**: Cumpre FR-002 e as Assumptions (elevação sem palavra-passe interativa no contentor de desenvolvimento). É o padrão mais simples para laboratório local; a superfície continua confinada ao contentor.

**Alternatives considered**:

- **Só `su` / login root**: Pior UX; a spec pede explicitamente sudo ou equivalente.
- **NOPASSWD só para `/usr/bin/apt-get`**: Mais restritivo mas aumenta fricção (outros comandos `apt`, scripts); para dev interno, política alargada é aceitável com documentação de risco.
- **`gosu root` no entrypoint para tarefas**: Já existe para alinhamento de UID; não substitui sudo interativo na sessão do desenvolvedor.

## Resolução de NEEDS CLARIFICATION

Não havia marcadores NEEDS CLARIFICATION no `plan.md` após preenchimento do Technical Context; as decisões acima fecham o desenho para implementação e contratos.
