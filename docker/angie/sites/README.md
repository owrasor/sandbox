# Sites `.test` (proxy reverso)

Coloca aqui **um ficheiro `*.conf` por hostname** (ou grupo de `server_name` relacionados). Todos os ficheiros são incluídos automaticamente pelo Angie:

```nginx
# em angie.conf (no contentor)
include /etc/angie/sites/*.conf;
```

## Adicionar um site novo

1. Copia `example-app.test.conf` para `meu-projeto.test.conf` (o nome do ficheiro é só organização; o que importa é `server_name` e os blocos `server`).
2. Ajusta:
   - `server_name` para o teu domínio (ex.: `api.meuapp.test`);
   - caminhos `ssl_certificate` / `ssl_certificate_key` para PEM em `docker/angie/certs/` (montados em `/etc/angie/certs/`);
   - `proxy_pass` para o upstream na rede Docker (ex.: `http://dev:3000`, outro serviço Compose, ou `host.docker.internal:porta` se documentado no teu ambiente).
3. Gera certificados com mkcert (ver `../certs/README.md`) com nomes que coincidam com o `ssl_certificate` no conf.
4. Adiciona o hostname ao `/etc/hosts` (ou DNS local) apontando para o IP onde o Docker expõe 80/443.
5. Valida e recarrega:
   - `docker compose run --rm angie angie -t` (com `.env` configurado), ou o `docker run ... angie -t` descrito no `quickstart.md`;
   - `docker compose restart angie` (ou `kill -HUP` ao processo conforme a imagem).

## Boas práticas

- Evita dois ficheiros com o mesmo `server_name` em 443 — o comportamento fica indefinido.
- Mantém `resolver 127.0.0.11` e `proxy_pass` com **variável** (`set $upstream_...`) quando o upstream for um nome DNS de outro contentor, para `angie -t` passar sem esse contentor a correr.
- Não commits chaves nem PEM em `certs/` (já ignorados pelo Git).
