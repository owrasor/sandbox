# Contract: configuração Angie (Nginx-compatible)

**Versão**: 1.0 (planeamento)

## Layout de ficheiros no repositório

```text
docker/angie/
├── angie.conf          # eventos + http + include conf.d/*.conf
├── conf.d/
│   └── *.conf          # um ou mais virtual hosts
└── certs/              # gitignored — apenas no disco local
```

## `angie.conf` (mínimo lógico)

- Declaração `worker_processes` conforme defaults da imagem ou `auto`.
- Bloco `http` com:
  - `include /etc/angie/conf.d/*.conf` **ou** path equivalente suportado pela imagem montada.
  - Tipos MIME padrão se não herdados.
- Sem credenciais em claro no repo.

## Bloco `server` HTTPS (contrato por virtual host)

Cada ficheiro em `conf.d/` para site com TLS **deve** incluir:

- `listen 443 ssl;`
- `server_name <hostname>;` alinhado com certificado (wildcard `*.test` ou nome explícito).
- `ssl_certificate` e `ssl_certificate_key` apontando para ficheiros **dentro** do volume de certs montado.
- `location /` com `proxy_pass http://<upstream_host>:<port>;`
- Recomendado: `proxy_set_header Host $host;`, `X-Forwarded-For $proxy_add_x_forwarded_for;`, `X-Forwarded-Proto $scheme;`

## Bloco `server` HTTP (opcional)

- `listen 80;` com `return 301 https://$host$request_uri;` **ou** servir só HTTP em dev — política por ficheiro, documentada no comentário do topo do `.conf`.

## O que não é permitido no Git

- Ficheiros `*.pem` / `*.key` privados dentro de paths versionados (usar `certs/` ignorado).
- URLs de upstream com credenciais na query string.

## Validação

- Antes de PR: comando de teste de configuração documentado em `quickstart.md` deve passar.

## Extensão futura

- ACME / certificados dinâmicos Angie: fora do MVP; se adotado, novo contract versionado (2.0).
