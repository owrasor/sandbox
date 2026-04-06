# Contract: verificação Neovim na imagem `dev`

**Feature**: 004-update-neovim-stable  
**Âmbito**: Imagem Docker de desenvolvimento (Linux x86_64), shell de login com `PATH` configurado pelo sistema.

## Comando de verificação (canónico)

Após build da imagem `dev` (ou tag equivalente definida em `compose.yaml`):

```bash
docker compose run --rm dev bash -lc 'command -v nvim && nvim --version | head -1'
```

*(Caminho de trabalho: raiz do repositório onde existe `compose.yaml`.)*

## Saída esperada

1. **`command -v nvim`**: Imprime um caminho absoluto cujo sufixo é `/nvim` (tipicamente `/opt/nvim-linux-x86_64/bin/nvim`).
2. **Primeira linha de `nvim --version`**: Deve corresponder ao padrão  
   `NVIM v<major>.<minor>.<patch>`  
   com `<major>.<minor>.<patch>` igual à versão **pinada** no `Dockerfile` / `ARG` documentado (referência de pesquisa: **0.12.1** no momento do plano).

## Invariantes

- Não deve existir um segundo `nvim` anterior no `PATH` (ex.: `/usr/bin/nvim` do pacote distro) que seja resolvido primeiro — o contract falha se `command -v nvim` não apontar para `/opt/nvim-linux-x86_64/bin/nvim`.
- O editor deve iniciar em modo interativo sem erro fatal atribuível à instalação (teste manual mínimo: `nvim --headless +'q'` com exit code 0).

## Evolução

Quando o projeto bump a versão Neovim, actualizar em conjunto:

- Pin no `Dockerfile` (ou `ARG` default).
- Primeira linha esperada neste contract / auditorias.
- `docs/dev-environment/capability-inventory.md` (coluna “Observed” ou equivalente).
