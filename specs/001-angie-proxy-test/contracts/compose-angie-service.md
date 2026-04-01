# Contract: serviço Docker Compose `angie`

**Versão**: 1.2 (`sites/` em vez de `conf.d/`)  
**Repo**: `/home/owrasor/Code/owrasor/development_enviroment`

## Identificação

- **Nome do serviço**: `angie` (snake_case alinhado a `dev`, `ngrok`).
- **Imagem**: `docker.angie.software/angie:1.11.4` — tag fixa (não `latest` em commits estáveis).

## Rede

- **Networks**: `sandbox` (mesma que `dev`).
- **Publicação no host**:
  - `80:80` (HTTP; exemplo redireciona para HTTPS).
  - `443:443` (HTTPS).

## Volumes (contrato)

| Mount no contentor        | Origem no host                                              | Modo |
|---------------------------|-------------------------------------------------------------|------|
| `/etc/angie/angie.conf`   | `./docker/angie/angie.conf`                                 | ro   |
| `/etc/angie/sites`        | `./docker/angie/sites`                                      | ro   |
| `/etc/angie/certs`        | `${ANGIE_CERTS_HOST:-./docker/angie/certs}`                 | ro   |

## Variáveis de ambiente

- `ANGIE_CERTS_HOST` (opcional): caminho absoluto no host para certs; se omitido, Compose usa `./docker/angie/certs` relativo ao ficheiro compose.

Nenhum segredo (tokens) no serviço Angie para o MVP local.

## Dependências

- **depends_on**: `dev` (ordem de arranque ao testar proxy → upstream).
- **profiles**: não usados nesta implementação; `ngrok` continua em perfil `public`.

## Comportamento esperado

- O contentor **falha ao arrancar** se a config for inválida ou ficheiros TLS em falta (preferível a servir tráfego errado).
- Logs: `docker compose logs angie`.

## Compatibilidade

- Portas publicadas do `dev` mantidas: `3000`, `8080`, `5173`.
