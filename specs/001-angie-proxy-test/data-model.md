# Data model (conceitual): proxy Angie + `.test`

Este feature não persiste dados em base de dados. Seguem-se **entidades lógicas** de configuração e operação.

## VirtualHost

Representa um hostname servido pelo Angie e a política de encaminhamento.

| Campo | Tipo / descrição | Regras |
|-------|------------------|--------|
| `server_name` | string | Deve coincidir com o hostname usado no browser (ex. `app.test`, wildcard `*.test` em certificado TLS). |
| `listen` | portas / ssl | Tipicamente `443 ssl` e opcionalmente `80` para redirect ou HTTP puro. |
| `tls` | referência a material criptográfico | Caminhos para `certificate` e `certificate_key` dentro do contentor. |
| `locations` | lista de regras | Pelo menos `/` com `proxy_pass` para um upstream. |
| `proxy_headers` | opcional | `Host`, `X-Forwarded-For`, `X-Forwarded-Proto` recomendados para apps que precisem. |

**Relações**: referencia um ou mais **Upstream**; usa **TlsMaterial**.

## Upstream

Destino interno do proxy.

| Campo | Tipo / descrição | Regras |
|-------|------------------|--------|
| `target` | host:porta | Deve ser alcançável na rede Docker (ex. `dev:5173`, `dev:3000`). |
| `scheme` | `http` \| `https` | MVP: `http` para serviços internos na bridge. |

**Relações**: referenciado por **VirtualHost** (via `proxy_pass`).

## TlsMaterial

Certificados para terminação TLS no Angie.

| Campo | Tipo / descrição | Regras |
|-------|------------------|--------|
| `certificate_path` | path no contentor | Montado read-only; não commitado. |
| `private_key_path` | path no contentor | Montado read-only; não commitado; permissões restritas no host. |
| `san_or_wildcard` | string | Deve cobrir os `server_name` usados (ex. `*.test`). |

**Relações**: usado por **VirtualHost** com `ssl` ativo.

## Resolução de nomes (ambiente)

| Campo | Descrição |
|-------|-----------|
| `hostname` | ex. `meuapp.test` |
| `resolver` | `/etc/hosts`, dnsmasq, ou outro DNS local documentado |
| `address` | Tipicamente `127.0.0.1` quando o proxy publica no host |

Não é configuração do Angie; faz parte do **contrato operacional** do developer.

## Validação e estados

- **Config inválida**: Angie recusa arranque após `angie -t` falhar.
- **Upstream down**: resposta 502/504; estado operacional, não persistido.
- **Certificado em falta**: falha de arranque do `server` SSL ou handshake falhado; detetável nos logs do contentor.

## Transições (operacionais)

1. Developer adiciona `sites/novo-site.conf` → valida → reinicia/recarrega Angie conforme imagem suportar.  
2. Rotação de certificado: substitui ficheiros no volume host → reload/restart documentado em `quickstart.md`.
