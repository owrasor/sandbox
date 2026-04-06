# Contract: imagem Docker `dev`

## Base

- **FROM**: `ubuntu:24.04` (pin existente; não migrar para `latest`).

## mise

- **Instalação**: script oficial `mise.run` (ou método documentado equivalente no `Dockerfile`).
- **Disponibilidade**: binário `mise` invocável em build e em shell de login como `dev`.

## Runtimes (sistema)

- **PHP**: linha **8.4** instalada e seleccionada para uso por defeito em sessão de login (major.minor 8.4).
- **Node**: linha **22** instalada e seleccionada para uso por defeito em sessão de login (major 22).

Ambos **DEVE** ser instalados via mise de forma **coerente** (ex. `mise install --system` ou mecanismo equivalente documentado no plano de implementação).

O PATH de login **DEVE** expor esses binários ao utilizador `dev` (ex.: `/etc/profile.d/mise-system-runtimes.sh` + entrada em `/etc/zsh/zprofile` em Ubuntu, onde o zsh de login não percorre `profile.d` por defeito).

## CLIs de IA

- O script `docker/install-ai-clis.sh` (ou sucessor documentado) **DEVE** executar no fluxo de build padrão da imagem.
- **DEVE** usar o Node disponibilizado pelo mise quando já satisfizer a major requerida (evitar segunda cadeia de instalação NodeSource salvo fallback documentado).
- Instaladores externos (ex. Claude, Cursor Agent) mantêm-se enquanto a documentação do projecto os listar. O **Cursor Agent** deve ser invocável por `dev` (p.ex. cópia do pacote de versão para `/usr/local/share/cursor-agent/current` e `agent` em `/usr/local/bin`), não apenas via `~/.local` do utilizador que corre o build.

## Entrypoint

- `docker/entrypoint.sh` mantém comportamento de UID/GID; **NÃO** deve instalar CLIs em runtime por defeito (preferir bake no build).
