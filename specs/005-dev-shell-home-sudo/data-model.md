# Data model: 005-dev-shell-home-sudo

Esta feature não introduz base de dados nem API HTTP. Modela-se o **comportamento do ambiente** e a **política de elevação** como entidades lógicas para testes e documentação.

## Entidade: `DevRuntimeLayout`

Descrição dos caminhos estáveis do serviço `dev` após a entrega.

| Campo | Tipo lógico | Regras / notas |
|--------|----------------|----------------|
| `user_name` | string | Constante: `dev`. |
| `home_dir` | path | `/home/dev`. |
| `workspace_mount` | path | `/home/dev/workspace` (bind mount do código; inalterado). |
| `dotfiles_mount` | path | `/home/dev/dotfiles` (inalterado). |
| `default_cwd` | path | **Igual a `home_dir`** após arranque de sessão interativa via Compose (`working_dir`). |
| `shell_login` | string | `zsh -l` (comportamento existente do CMD / fluxo documentado). |

**Validação**: Após `docker compose exec dev zsh -lc 'pwd'` (ou equivalente documentado), o caminho impresso deve ser **`default_cwd`**.

## Entidade: `PrivilegeElevationPolicy`

Política de `sudo` aplicável ao utilizador `dev` dentro do contentor.

| Campo | Tipo lógico | Regras |
|--------|----------------|--------|
| `mechanism` | string | `sudo`. |
| `subject` | string | Utilizador `dev`. |
| `password_prompt` | enum | `none` (NOPASSWD) — alinhado às Assumptions da spec. |
| `scope` | string | Comandos permitidos: política alargada de desenvolvimento (`ALL`) salvo endurecimento futuro documentado. |

**Validação**: `sudo -n true` como `dev` termina com código de saída 0; uma operação representativa (ex.: `sudo -n id -u`) confirma identidade efectiva `0`.

## Relações

- `DevRuntimeLayout.default_cwd` é **independente** de `workspace_mount`: o utilizador navega explicitamente para o mount quando precisa do repositório.

## Transições de estado

1. **Antes**: `working_dir` Compose e `WORKDIR` imagem apontam para `/home/dev/workspace`; `dev` sem `sudo` instalado/configurado.  
2. **Depois**: CWD por defeito `/home/dev`; `dev` pode elevar via `sudo` conforme política; montagens e entrypoint preservados salvo regressão documentada.
