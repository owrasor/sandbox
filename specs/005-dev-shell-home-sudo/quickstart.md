# Quickstart: verificar home e sudo (005-dev-shell-home-sudo)

Pré-requisitos: `.env` válido (como em [`docs/sandbox.md`](../../docs/sandbox.md)), Docker Compose v2.

## 1. Rebuild da imagem

```bash
cd /home/owrasor/Code/owrasor/sandbox
docker compose build dev
```

## 2. Diretório inicial em sessão não interactiva

```bash
docker compose run --rm --no-deps dev zsh -lc 'pwd'
```

**Esperado**: saída `/home/dev`.

## 3. `exec` com stack em execução

```bash
docker compose up -d dev
docker compose exec dev zsh -lc 'pwd'
docker compose stop dev
```

**Esperado**: `/home/dev`.

## 4. Sudo sem prompt

```bash
docker compose run --rm --no-deps dev zsh -lc 'sudo -n true && sudo -n id -u'
```

**Esperado**: `true` silencioso; segunda linha `0`.

## 5. Navegar para o código

```bash
docker compose run --rm --no-deps dev zsh -lc 'cd workspace && pwd'
```

**Esperado**: `/home/dev/workspace` (ou equivalente se o mount estiver configurado nesse caminho).

Contratos detalhados: [`contracts/shell-session.md`](contracts/shell-session.md), [`contracts/sudo-policy.md`](contracts/sudo-policy.md).
