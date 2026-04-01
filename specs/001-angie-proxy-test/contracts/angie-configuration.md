# Contract: configuração Angie (Nginx-compatible)

**Versão**: 1.2 (`sites/` para virtual hosts)

## Layout de ficheiros no repositório

```text
docker/angie/
├── angie.conf          # worker/events/http + include sites/*.conf
├── sites/
│   ├── README.md       # como adicionar novos hosts .test
│   └── *.conf          # um ou mais virtual hosts por ficheiro
└── certs/              # gitignored — PEM no disco local + README.md versionado
```

## `angie.conf`

- Ficheiro principal montado em **`/etc/angie/angie.conf`** no contentor.
- Bloco `http` com `include /etc/angie/mime.types;` e `include /etc/angie/sites/*.conf;` (directório montado em `/etc/angie/sites`).

## Bloco `server` HTTPS (contrato por virtual host)

Cada ficheiro em `sites/` para site com TLS **deve** incluir:

- `listen 443 ssl;`
- `server_name <hostname>;` alinhado com certificado.
- `ssl_certificate` e `ssl_certificate_key` apontando para **`/etc/angie/certs/...`** (volume de certs).
- `location /` com proxy para upstream na rede Docker. No exemplo versionado usa-se `resolver 127.0.0.11;`, variável `set $upstream_dev http://dev:5173;` e `proxy_pass $upstream_dev;` para adiar a resolução de `dev` (permite `angie -t` fora da stack e evita falha se o nome ainda não existir no DNS do contentor).
- `proxy_set_header Host $host;`, `X-Forwarded-For $proxy_add_x_forwarded_for;`, `X-Forwarded-Proto $scheme;`

## Bloco `server` HTTP (exemplo)

- `listen 80;` com `return 301 https://$host$request_uri;` no exemplo `sites/example-app.test.conf`.

## O que não é permitido no Git

- Ficheiros `*.pem` / chaves privadas (ignorados; ver `.gitignore`).

## Validação

- `docker compose run --rm angie angie -t` (ver `quickstart.md`).

## Extensão futura

- ACME / certificados dinâmicos Angie: fora do MVP; se adotado, novo contract versionado (2.0).
