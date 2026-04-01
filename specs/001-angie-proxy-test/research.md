# Research: Angie, proxy reverso e HTTPS para `*.test`

Consolidação das decisões para a feature `001-angie-proxy-test`. Data: 2026-04-01.

## 1. Motor de proxy: Angie

**Decision**: Usar **Angie** (servidor web / reverse proxy com configuração compatível com Nginx) como serviço dedicado no Docker Compose.

**Rationale**:

- Requisito explícito do utilizador (“implementação do Angie”).
- Sintaxe e operação próximas do Nginx: `server`, `location`, `proxy_pass`, validação com teste de configuração.
- Imagem/container oficial ou comunidade mantida reduz fricção em relação a builds custom.

**Alternatives considered**:

- **Caddy**: TLS automático e config mínima; rejeitado como primário porque o utilizador pediu Angie.
- **Nginx (mainline)**: equivalente funcional; Angie escolhido por alinhamento ao pedido e roadmap do projeto Angie.
- **Traefik**: labels Compose e ACME; mais complexo para um único TLD `.test` local sem orquestração dinâmica obrigatória.

## 2. Resolução DNS local para `*.test`

**Decision**: Documentar **duas opções**: (A) entradas em `/etc/hosts` por hostname, (B) **dnsmasq** (ou systemd-resolved stub) com wildcard `address=/.test/127.0.0.1` onde aplicável.

**Rationale**:

- `.test` é reservado para testes (RFC 6761); em desenvolvimento local o controlo fica no developer.
- Wildcard no hosts nativo não existe na maioria dos SO; dnsmasq simplifica `qualquer-coisa.test`.

**Alternatives considered**:

- **Somente hosts**: simples mas não escala para muitos nomes.
- **`.localhost` / `.local`**: evitado para respeitar o pedido explícito de `.test`.

## 3. HTTPS local (certificados)

**Decision**: Recomendar **mkcert** no host para emitir CA local confiável e certificado **wildcard** `*.test` (e opcionalmente `*.dev.test` se necessário), montando `fullchain + key` no contentor Angie.

**Rationale**:

- Browsers confiam após `mkcert -install` na máquina do developer.
- Wildcard cobre múltiplos projectos sem novo cert por hostname.
- Adequado a ambiente local; não expõe segredos se chaves ficam fora do Git.

**Alternatives considered**:

- **Certificados autoassinados sem instalar CA**: rápido mas avisos constantes no browser (aceitável só para curl `-k` em CI local).
- **Let's Encrypt para `.test`**: inviável (domínio não público / não validável pela CA pública da forma usual).

## 4. Topologia Docker e rede

**Decision**: Novo serviço **angie** na rede **`sandbox`** (mesma que `dev`), portas **80** e **443** publicadas no host; volumes: diretório de **config** (read-only) e diretório de **certificados** (read-only). Upstreams como `dev:5173`, `dev:3000`, etc.

**Rationale**:

- Consistente com `docker-compose.yml` existente e `docs/sandbox.md`.
- TLS termina no proxy; apps upstream podem continuar em HTTP.
- `extra_hosts: host.docker.internal:host-gateway` pode ser documentado se algum serviço correr no host em vez do contentor.

**Alternatives considered**:

- **Proxy só dentro da rede sem publicar 443**: não cumpre browser no host com `https://app.test`.
- **TLS nos apps e proxy TCP pass-through**: mais complexo; fora do MVP.

## 5. Organização da configuração Angie

**Decision**: Ficheiro principal mínimo + **`sites/*.conf`** montados em `docker/angie/sites/` (um ficheiro por site ou por equipa), com `include` no bloco `http` conforme padrão Nginx/Angie.

**Rationale**:

- Facilita PRs pequenos e revisão.
- Novos hosts `.test` adicionam-se com novos `sites/*.conf` sem alterar `angie.conf`.

**Alternatives considered**:

- **Um único ficheiro gigante**: mais conflitos em git.
- **Apenas variáveis de ambiente sem ficheiros**: limitado para blocos `server` completos.

## 6. Testes e validação

**Decision**: Gate manual: `docker compose run --rm angie angie -t` (ou comando documentado pela imagem) + `curl` com e sem `-k` conforme fase de confiança da CA; opcionalmente teste de integração mínimo com script shell no repo (futuro `speckit.tasks`).

**Rationale**:

- Infraestrutura sem código de aplicação; testes automatizados completos têm ROI baixo no MVP.
- Validação de sintaxe evita arranque silenciosamente partido.

**Alternatives considered**:

- **Testcontainers**: excesso para proxy estático local.

---

## Resolução de NEEDS CLARIFICATION (Technical Context)

| Tópico | Resolução |
|--------|-----------|
| Imagem exata do Angie | Registry documentado: `docker.angie.software/angie:<tag>` (fixar tag no Compose; ver https://en.angie.software/angie/docs/installation/docker ). |
| Política HTTP → HTTPS | MVP: redirecionamento 301 opcional por `server` de exemplo; não obrigatório globalmente na primeira iteração. |
| Onde gerar mkcert | No **host**; montar apenas os ficheiros `.pem` gerados no volume do contentor. |
