# Quickstart: 007-dotfiles-bootstrap-once (verificação manual)

## 1. Preparar o `.env`

Na raiz do sandbox:

```bash
cp .env.example .env
```

Garantir `DOTFILES_HOST`, `SSH_DIR`, `USER_ID`, `GROUP_ID` e `WORKSPACE_HOST` (por defeito `./workspace`). Adicionar, por exemplo:

```bash
DOTFILES_BOOTSTRAP_SCRIPT=my-bootstrap.sh
```

## 2. Colocar o script no clone de dotfiles

No **host**, no directório apontado por `DOTFILES_HOST`, criar `my-bootstrap.sh` **no topo** desse directório, executável. O contentor resolve `/home/dev/dotfiles/<DOTFILES_BOOTSTRAP_SCRIPT>`.

Exemplo mínimo (prova de execução + log):

```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /home/dev/workspace/.sandbox
echo "bootstrap-ran $(date -Iseconds)" >> /home/dev/workspace/.sandbox/bootstrap-probe.log
```

```bash
chmod +x /caminho/no/host/dos/dotfiles/my-bootstrap.sh
```

## 3. Build e execução

Na raiz do repositório:

```bash
docker compose build dev
docker compose run --rm --no-deps dev zsh -lc 'true'
```

Verificar no **host** (pasta `workspace` do repo, por defeito):

- Marcador de sucesso: `workspace/.sandbox/dotfiles-bootstrap.done`
- Lock (pode existir): `workspace/.sandbox/dotfiles-bootstrap.lock`

Segunda corrida com o mesmo workspace:

```bash
docker compose run --rm --no-deps dev zsh -lc 'true'
```

O script do utilizador **não** deve voltar a acrescentar linhas ao log de prova (o hook sai cedo por causa do marcador).

## 4. Variável vazia / ficheiro em falta / falha do script

- **Vazio**: comenta ou remove `DOTFILES_BOOTSTRAP_SCRIPT` no `.env` → nenhum bootstrap; sem marcador novo.
- **Ficheiro em falta**: define um nome que não exista → stderr com `sandbox-dotfiles-bootstrap:`; shell disponível; **sem** `dotfiles-bootstrap.done`.
- **Falha**: script com `exit 1` → stderr com código de saída; **sem** marcador; após corrigir o script, apaga o lock se ficar preso e volta a arrancar (o marcador continua ausente).

## 5. Repor a “primeira vez”

No host:

```bash
rm -f workspace/.sandbox/dotfiles-bootstrap.done workspace/.sandbox/dotfiles-bootstrap.lock
```

(ajusta o caminho se `WORKSPACE_HOST` não for `./workspace`).

## 6. Documentação completa

Ver [docs/sandbox.md](../../docs/sandbox.md) (secção **Bootstrap opcional de dotfiles**).

## 7. Contratos de verificação

Cenários **B1–B5**: [contracts/bootstrap-once.md](./contracts/bootstrap-once.md).
