# Research: 007-dotfiles-bootstrap-once

## 1. Momento de execução: build da imagem vs arranque do contentor

**Decision**: Executar no **arranque da sessão shell** (primeira invocação relevante de `zsh` no contentor), **não** durante `docker build`.

**Rationale**: O `.env` do repositório e o conteúdo montado de `DOTFILES_HOST` não fazem parte da imagem; no build não há garantia de acesso ao script escolhido pelo utilizador. A spec (**FR-007**) exige disponibilidade de ficheiros do utilizador e volumes.

**Alternatives considered**:

- **RUN no Dockerfile**: reprodutível mas ignora dotfiles dinâmicos e `.env` local; obrigaria a copiar ou argumentos de build frágeis.
- **Entrypoint antes de `gosu dev`**: corre como root — viola expectativa de script de utilizador no home `dev` e complica permissões; possível mas inferior ao hook como `dev`.
- **CMD wrapper** (`script && exec zsh -l`): **não** cobre `docker compose exec dev zsh` sem `-l` ou quando o comando não passa pelo CMD; fácil de contornar inadvertidamente.

## 2. Onde disparar a lógica para cobrir `compose up`, `exec` e `zsh -lc`

**Decision**: Incluir um snippet em **`/etc/zsh/zshenv`** (ou ficheiro `source` a partir dele) que invoca o script de orquestração com **saída imediata** quando a variável está vazia ou o marcador de sucesso já existe.

**Rationale**: `zshenv` corre em **todo** o processo `zsh` (interactivo, login, `zsh -c`), garantindo o mesmo comportamento para CMD `zsh -l` e para `docker compose exec dev zsh`. O custo após o primeiro sucesso é uma verificação de ficheiro.

**Alternatives considered**:

- **Só `/etc/zsh/zprofile`**: não corre em shells interactivos **não-login** (comum em `exec zsh` sem `-l`).
- **Bash no entrypoint após `gosu`**: o CMD actual é `zsh`; reestruturar para `bash -c` complica o contrato de processo principal e ainda pode não alinhar com todos os `exec`.

## 3. Persistência do estado “já executado com sucesso”

**Decision**: Gravar um **marcador** sob o bind mount do **workspace** (ex.: `workspace/.sandbox/dotfiles-bootstrap.done`), com o repositório a ignorar `.sandbox/` via `.gitignore`.

**Rationale**: Em `docker compose`, `/home/dev` fora dos mounts é **efémero**; apenas volumes montados persistem entre recriações do contentor. O workspace já é o mount padrão do código e persiste com o fluxo actual. Evita poluir o repositório de dotfiles do utilizador com estado local da sandbox.

**Alternatives considered**:

- **Marcador em `~/dotfiles`**: pode ser commitado por engano ou conflitar com o fluxo Stow do utilizador.
- **Volume nomeado dedicado**: mais Compose YAML e superfície operacional para um único ficheiro de estado.
- **Marcador só na camada do contentor**: perde-se ao `docker compose down` + `up` com imagem nova — viola **SC-002** na prática.

## 4. Segurança do nome do ficheiro (path traversal)

**Decision**: Aceitar apenas um **segmento seguro** (ex.: `basename` sem `/`, regex alfanumérico + `._-`), e resolver o caminho final como `/home/dev/dotfiles/<segmento>`; rejeitar se `realpath` não estiver prefixado por `/home/dev/dotfiles`.

**Rationale**: Alinha com o edge case da spec (sem sair da raiz dos dotfiles).

**Alternatives considered**:

- **Caminhos relativos com subpastas** (`scripts/bootstrap.sh`): útil mas aumenta superfície; pode ser fase 2 se a spec for alargada; v1 pode restringir a ficheiro no topo do mount.

## 5. Concorrência (dois `zsh` ao mesmo tempo no primeiro arranque)

**Decision**: Usar **`flock`** (ou equivalente) num lockfile junto ao marcador antes de executar o script do utilizador; só um processo executa; os outros esperam ou saem após verificar marcador actualizado.

**Rationale**: Garante no máximo uma execução bem-sucedida e um único marcador coerente.

**Alternatives considered**:

- **Sem lock**: duas execuções paralelas possíveis no primeiro boot.
- **Marcador antes de executar**: violaria **FR-006** se o script falhar a meio.

## 6. Nome da variável no `.env`

**Decision**: **`DOTFILES_BOOTSTRAP_SCRIPT`** — valor = nome do ficheiro (não caminho absoluto) dentro de `/home/dev/dotfiles`.

**Rationale**: Simétrico a `DOTFILES_HOST`; claro no `.env.example`.

**Alternatives considered**:

- `SANDBOX_BOOTSTRAP_SCRIPT`: mais genérico mas menos descobrível face ao mount `dotfiles`.

## 7. Comportamento quando o script falha

**Decision**: Escrever diagnóstico em **stderr**; **não** criar marcador de sucesso; permitir que a shell continue a arrancar para o utilizador corrigir (alinhado a **User Story 3** e **FR-006**).

**Rationale**: Bloquear PID 1 ou impedir entrada no contentor piora a iteracção; a visibilidade do erro cumpre **FR-005**/**FR-006**.

**Alternatives considered**:

- **Encerrar o processo zsh com `exit`**: dificulta `exec` para depuração.
