# Quickstart: validar Neovim estável (004-update-neovim-stable)

## Pré-requisitos

- Docker e Docker Compose v2  
- Clone do repositório em `/home/owrasor/Code/owrasor/sandbox` (ou equivalente)  
- Arquitectura de build **x86_64**

## 1. Rebuild da imagem de desenvolvimento

Na raiz do repositório:

```bash
docker compose build dev
```

## 2. Verificar versão e caminho

```bash
docker compose run --rm dev bash -lc 'command -v nvim && nvim --version | head -1'
```

Compare a linha `NVIM v…` com a versão pinada documentada em `docker/Dockerfile` e em `docs/dev-environment/capability-inventory.md`.

## 3. Smoke não interactivo

```bash
docker compose run --rm dev bash -lc 'nvim --headless +q'
```

Exit code **0** esperado.

## 4. Smoke com config mínima (opcional)

Sem TTY (CI ou redireccionamento), usar **headless**:

```bash
docker compose run -T --rm dev bash -lc 'nvim -u NONE --headless +q'
```

Com TTY interactivo (`docker compose run --rm dev` sem `-T`), podes usar `nvim -u NONE +q` na shell dentro do contentor.

## Referências

- Contrato detalhado: [contracts/version-check.md](./contracts/version-check.md)  
- Decisões: [research.md](./research.md)  
- Spec de produto: [spec.md](./spec.md)
