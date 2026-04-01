# Contract: serviço Docker Compose `angie`

**Versão**: 1.0 (planeamento)  
**Repo**: `/home/owrasor/Code/owrasor/development_enviroment`

## Identificação

- **Nome do serviço**: `angie` (snake_case alinhado a `dev`, `ngrok`).
- **Imagem**: `docker.angie.software/angie:<TAG>` — **TAG fixa** na implementação (não `latest` em commits estáveis).

## Rede

- **Networks**: `sandbox` (mesma que `dev`).
- **Publicação no host**:
  - `80:80` (HTTP, opcional redirect).
  - `443:443` (HTTPS).

## Volumes (contrato)

| Mount no contentor | Origem no host | Modo |
|--------------------|----------------|------|
| `/etc/angie/angie.conf` ou path documentado pela imagem | `./docker/angie/angie.conf` | ro |
| Diretório includes | `./docker/angie/conf.d` | ro |
| Certificados | `./docker/angie/certs` ou `${ANGIE_CERTS_HOST}` | ro |

*Nota*: O path exato do ficheiro principal depende da imagem oficial; na implementação, alinhar com a documentação Angie Docker e refletir aqui se divergir.

## Variáveis de ambiente

- `ANGIE_CERTS_HOST` (opcional): caminho absoluto no host para certs; se omitido, usar default relativo ao repo documentado no `.env.example`.

Nenhum segredo (tokens) no serviço Angie para o MVP local.

## Dependências

- **depends_on**: `dev` (opcional, ordem de arranque); não substitui healthcheck se for introduzido mais tarde.
- **profiles**: opcional `proxy` — se usado, documentar em `quickstart.md` e `docs/sandbox.md`.

## Comportamento esperado

- O contentor **falha ao arrancar** se a config for inválida (preferível a servir tráfego errado).
- Logs acessíveis via `docker compose logs angie`.

## Compatibilidade

- Não remover portas já documentadas para `dev` (3000, 8080, 5173) sem atualizar `docs/sandbox.md`.
