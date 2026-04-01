# Quickstart: Angie + `*.test` + HTTPS

Caminhos absolutos do repositório: `/home/owrasor/Code/owrasor/development_enviroment` (ajusta se o teu clone for noutro sítio).

## Pré-requisitos

- Docker e Docker Compose v2 (ver `docs/sandbox.md`).
- Portas **80** e **443** livres no host (ou altera o mapeamento no Compose e documenta localmente).
- [mkcert](https://github.com/FiloSottile/mkcert) instalado no **host** (recomendado para HTTPS sem avisos no browser).

## 1. Certificados TLS no host

No host (não dentro do contentor `dev`):

```bash
mkcert -install
mkdir -p /home/owrasor/Code/owrasor/development_enviroment/docker/angie/certs
cd /home/owrasor/Code/owrasor/development_enviroment/docker/angie/certs
mkcert "*.test" "test" localhost 127.0.0.1 ::1
```

Isto gera `*.test+4.pem` e `*.test+4-key.pem` (nomes podem variar). Renomeia para algo estável **ou** aponta os `ssl_certificate` / `ssl_certificate_key` no conf Angie para os nomes reais gerados.

**Importante**: o diretório `certs/` deve estar no `.gitignore`.

## 2. Resolver `*.test` para o teu host

**Opção A — uma app**: adiciona ao `/etc/hosts`:

```text
127.0.0.1  meuapp.test
```

**Opção B — wildcard**: configura dnsmasq (ou equivalente) com `address=/.test/127.0.0.1` e usa o resolver do SO apontando para ele (detalhe depende da distribuição).

## 3. Configurar o Angie

Após implementação (ver `plan.md`):

1. Garante `docker/angie/angie.conf` e includes em `docker/angie/conf.d/`.
2. Ajusta o exemplo `example-app.test.conf` com `proxy_pass http://dev:PORTA;` coerente com a app (ex. `5173` para Vite).
3. Valida a sintaxe (comando exato depende da imagem; típico):

```bash
cd /home/owrasor/Code/owrasor/development_enviroment
docker compose run --rm angie angie -t
```

(Se o serviço ou entrypoint da imagem diferirem, segue a documentação em https://en.angie.software/angie/docs/installation/docker )

## 4. Variáveis de ambiente

Quando o Compose estiver atualizado, prevê-se algo como:

- `ANGIE_CERTS_HOST` — caminho absoluto no host para a pasta de certs (opcional se usar path fixo `./docker/angie/certs`).

Copia `.env.example` → `.env` e preenche conforme documentação adicionada na implementação.

## 5. Subir a stack

```bash
cd /home/owrasor/Code/owrasor/development_enviroment
docker compose up -d angie dev
```

(Comando final pode usar perfil; alinha com o `docker-compose.yml` após merge da implementação.)

## 6. Verificar

```bash
curl -I https://meuapp.test/
```

Com CA mkcert instalada no host, o browser deve abrir `https://meuapp.test` sem erro de certificado.

## Troubleshooting

| Sintoma | Ação |
|---------|------|
| `502 Bad Gateway` | Confirma que o upstream está a escutar na rede `sandbox` e que o nome/porta no `proxy_pass` estão corretos. |
| Certificado inválido | Corre `mkcert -install` no host; confirma que os paths no conf apontam para os ficheiros montados no contentor. |
| Não resolve `meuapp.test` | Verifica hosts/dnsmasq; `ping meuapp.test` deve ir para `127.0.0.1`. |
| Porta em uso | `ss -tlnp \| grep ':443'` no host; para o serviço que ocupa a porta ou muda o bind no Compose. |

## Tempo alvo (SC-001)

Com Docker funcional e deps instaladas, o percurso 1–6 deve caber em **~30 minutos** na primeira vez (inclui geração de certs e hosts).
