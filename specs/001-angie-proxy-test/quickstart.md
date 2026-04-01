# Quickstart: Angie + `*.test` + HTTPS

Caminhos absolutos do repositório: `/home/owrasor/Code/owrasor/development_enviroment` (ajusta se o teu clone for noutro sítio).

## Pré-requisitos

- Docker e Docker Compose v2 (ver `docs/sandbox.md`).
- Portas **80** e **443** livres no host (ou altera o mapeamento no Compose e documenta localmente).
- [mkcert](https://github.com/FiloSottile/mkcert) instalado no **host** (recomendado para HTTPS sem avisos no browser).
- Certificados presentes em `docker/angie/certs/` com os nomes esperados (ver `docker/angie/certs/README.md`) **antes** de subir o Angie com o exemplo `example-app.test`.
- Para **mais hostnames `.test`**, adiciona ficheiros `*.conf` em `docker/angie/sites/` (guia em `docker/angie/sites/README.md`).

## 1. Certificados TLS no host

No host (não dentro do contentor `dev`):

```bash
mkcert -install
mkdir -p /home/owrasor/Code/owrasor/development_enviroment/docker/angie/certs
cd /home/owrasor/Code/owrasor/development_enviroment/docker/angie/certs
mkcert -cert-file example-app.test.pem -key-file example-app.test-key.pem example-app.test "*.test" localhost 127.0.0.1 ::1
```

Isto cria `example-app.test.pem` e `example-app.test-key.pem`, alinhados com `docker/angie/sites/example-app.test.conf`.

**Importante**: ficheiros `*.pem` / chaves estão no `.gitignore`; não commits.

### Confiança no browser (mkcert)

- `mkcert -install` instala a CA local no arquivo de confiança do SO (Linux: depende da distro; macOS/Windows: prompts guiados).
- Depois de subir o stack e resolver `example-app.test` para o host, abre `https://example-app.test` — não deve aparecer aviso de certificado inválido se a CA mkcert estiver confiada.
- Se o SO/browser não confiar na CA: usa apenas `curl -k` para **debug controlado** (não substitui confiar na CA para desenvolvimento normal).

## 2. Resolver `*.test` para o teu host

### Exemplo para a app de demonstração (`example-app.test`)

Adiciona ao `/etc/hosts` (ou equivalente):

```text
127.0.0.1  example-app.test
```

**Opção B — wildcard**: configura dnsmasq (ou equivalente) com `address=/.test/127.0.0.1` e usa o resolver do SO apontando para ele (detalhe depende da distribuição).

## 3. Validar sintaxe da configuração Angie

Na raiz do repositório, com `.env` presente (o Compose referencia `env_file: .env` no serviço `dev`):

```bash
cd /home/owrasor/Code/owrasor/development_enviroment
docker compose run --rm angie angie -t
```

A imagem `docker.angie.software/angie:1.11.4` usa `CMD ["angie","-g","daemon off;"]`; o comando acima substitui temporariamente por `angie -t` para teste de configuração. Deve terminar com código 0 se os volumes e ficheiros PEM existirem.

**Sem `.env` na raiz**, valida só a config montada no contentor Angie:

```bash
cd /home/owrasor/Code/owrasor/development_enviroment
docker run --rm \
  -v "$(pwd)/docker/angie/angie.conf:/etc/angie/angie.conf:ro" \
  -v "$(pwd)/docker/angie/sites:/etc/angie/sites:ro" \
  -v "$(pwd)/docker/angie/certs:/etc/angie/certs:ro" \
  docker.angie.software/angie:1.11.4 angie -t
```

O exemplo `example-app.test.conf` usa `resolver 127.0.0.11` e `proxy_pass` com variável para o upstream `dev:5173`, de modo que `angie -t` não exige o contentor `dev` a correr.

## 4. Variáveis de ambiente

- `ANGIE_CERTS_HOST` — caminho absoluto no host para a pasta de certs (opcional; por defeito `./docker/angie/certs` via Compose).

Copia `.env.example` → `.env` e preenche conforme necessário.

## 5. Subir a stack

```bash
cd /home/owrasor/Code/owrasor/development_enviroment
docker compose up -d dev angie
```

Garante que o upstream (ex. Vite em `dev:5173`) está a correr quando testares o proxy.

## 6. Verificar

Com hosts e certs corretos:

```bash
curl -k -I https://example-app.test/
```

Esperado: resposta do upstream (ex. cabeçalhos HTTP do Vite) ou redirecionamentos da app. Com CA mkcert confiável no host, podes omitir `-k`:

```bash
curl -I https://example-app.test/
```

### Debug com `curl -k` (sem CA confiável)

- `curl -vk https://example-app.test/` — mostra handshake TLS e cabeçalhos; útil quando o browser recusa mas queres confirmar que o Angie responde na 443.
- **Não** uses `-k` em produção; apenas em desenvolvimento local quando documentado.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| `502 Bad Gateway` | Upstream indisponível ou `proxy_pass` incorreto. Confirma que o serviço escuta na rede `sandbox` (`docker compose exec dev ss -tlnp` ou equivalente) e que o nome/porta batem com `docker/angie/sites/*.conf`. |
| `504 Gateway Timeout` | Upstream não responde a tempo; mesmas verificações que 502; firewall interno entre contentores. |
| Erro de handshake TLS / Angie não arranca | Ficheiros PEM em falta ou paths errados; confirma montagem `${ANGIE_CERTS_HOST:-./docker/angie/certs}` → `/etc/angie/certs` e nomes em `ssl_certificate` / `ssl_certificate_key`. |
| Certificado inválido no browser | Corre `mkcert -install` no host; confirma que os PEM montados são os gerados por mkcert. |
| Não resolve `example-app.test` | Verifica `/etc/hosts` ou dnsmasq; `getent hosts example-app.test` deve apontar para o IP onde o Docker publica 80/443 (típico `127.0.0.1`). |
| Porta 80/443 em uso no host | Ver `docs/sandbox.md` (conflitos de porta e alternativas). |

## Tempo alvo (SC-001)

Com Docker funcional e deps instaladas, o percurso 1–6 deve caber em **~30 minutos** na primeira vez (inclui geração de certs e hosts).
