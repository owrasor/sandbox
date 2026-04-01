# Feature Specification: Angie como proxy reverso para domínios `.test` com HTTPS

**Feature Branch**: `001-angie-proxy-test`  
**Created**: 2026-04-01  
**Status**: Draft  
**Input**: User description: "Implementar o Angie para proxy reverso dos sites terminados em `.test`, com possibilidade de HTTPS."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Um hostname `.test` aponta para o serviço certo (Priority: P1)

Como desenvolvedor, quero que `https://meuapp.test` (ou `http://`) encaminhe para o contentor ou processo onde o meu app corre (por exemplo `dev:5173`), para trabalhar com URLs estáveis e sem memorizar portas.

**Why this priority**: É o valor central do proxy reverso; sem isto não há feature.

**Independent Test**: Com DNS/hosts e proxy configurados, um pedido ao hostname resolve e devolve a resposta do upstream esperado.

**Acceptance Scenarios**:

1. **Given** um `server_name` e `proxy_pass` configurados para um upstream acessível na rede Docker, **When** faço `curl -k https://exemplo.test/`, **Then** recebo o corpo esperado do serviço upstream.
2. **Given** o mesmo hostname em HTTP (se permitido), **When** acedo a `http://exemplo.test/`, **Then** sou redirecionado para HTTPS **ou** obtenho resposta HTTP conforme política documentada (MVP pode ser só HTTPS).

---

### User Story 2 - TLS local confiável no browser (Priority: P2)

Como desenvolvedor, quero HTTPS local sem avisos de certificado (ou com procedimento claro de confiança), para testar cookies `Secure`, HSTS e fluxos mistos.

**Why this priority**: O utilizador pediu explicitamente HTTPS; a experiência depende de certificados.

**Independent Test**: Após seguir `quickstart.md`, o browser aceita `https://*.test` (ou documenta uso de `-k`/exceção controlada).

**Acceptance Scenarios**:

1. **Given** certificado wildcard ou SAN para `*.test` gerado e montado no Angie, **When** o Angie arranca com `ssl_certificate` configurado, **Then** o handshake TLS completa na porta 443 publicada.
2. **Given** instruções de confiança da CA local (ex. mkcert) no SO do utilizador, **When** abro o site no browser, **Then** não há erro de certificado inválido (cenário alvo).

---

### User Story 3 - Integração com o stack Docker existente (Priority: P3)

Como mantenedor do repo, quero o Angie como serviço Compose (rede `sandbox`, volumes para conf/certificados), alinhado com `docs/sandbox.md`, para subir e reproduzir o ambiente facilmente.

**Why this priority**: O repositório já é centrado em Docker Compose; o proxy deve encaixar sem quebrar o fluxo atual.

**Independent Test**: `docker compose` (com perfil ou serviço documentado) sobe o proxy e os serviços existentes continuam acessíveis pelos mapeamentos atuais.

**Acceptance Scenarios**:

1. **Given** ficheiros de configuração versionados (sem segredos) e certificados fora do Git, **When** executo os comandos em `quickstart.md`, **Then** o stack sobe sem erros de sintaxe de configuração.
2. **Given** documentação de variáveis (paths de certs, portas), **When** outro developer clona o repo, **Then** consegue replicar o proxy em máquina local.

---

### Edge Cases

- Upstream indisponível: Angie deve devolver 502/504 de forma previsível; documentar como diagnosticar.
- Conflito de portas 80/443 no host: documentar requisito ou portas alternativas mapeadas.
- Browser/OS que não confia na CA local: fallback documentado (curl `-k` apenas para debug, não como solução de produto local).
- Múltiplos projetos com o mesmo `server_name`: validação manual da configuração; evitar duplicados na pasta `conf.d`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O sistema MUST expor o Angie (ou imagem oficial compatível) como reverse proxy na stack Docker deste repositório.
- **FR-002**: O proxy MUST encaminhar tráfego HTTP(S) para upstreams definidos por configuração (ficheiros incluídos ou montados), por hostname (`server_name` alinhado com `*.test` ou nomes explícitos).
- **FR-003**: O sistema MUST suportar TLS terminado no Angie com caminhos configuráveis para certificado e chave (montagem de volume).
- **FR-004**: A configuração MUST ser reprodutível: documentar geração de certificados locais (recomendação: mkcert ou equivalente) e mapeamento `*.test` → IP do host (hosts ou DNS local).
- **FR-005**: Credenciais, chaves privadas e artefactos sensíveis MUST NOT ser commitados; `.gitignore` ou política do repo MUST cobrir diretórios de certs.
- **FR-006**: SHOULD existir pelo menos um exemplo de `server` para um app típico (ex. Vite `5173` ou alvo já usado no `docker-compose`).

### Key Entities

- **Virtual host**: hostname servido (`meuapp.test`), protocolo (HTTP/HTTPS), regras de proxy e cabeçalhos relevantes.
- **Upstream**: destino interno (`host:porta` na rede Docker ou host gateway conforme desenho).
- **Material TLS**: par certificado/chave (e opcionalmente cadeia CA) usado pelo Angie.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Um developer segue `quickstart.md` e obtém resposta HTTP 200 (ou equivalente da app) via `https://<hostname>.test` em menos de 30 minutos (assumindo Docker e deps já instalados).
- **SC-002**: A configuração do Angie valida sintaticamente (`angie -t` ou equivalente na imagem) antes de documentar como concluída.
- **SC-003**: Pelo menos dois cenários documentados: (a) app num contentor na rede `sandbox`, (b) procedimento TLS local explícito.

## Assumptions

- Domínios `.test` são para desenvolvimento local; não há requisito de CA pública.
- O host ou resolvimento local encaminha `*.test` para a máquina onde o Docker publica 80/443.
- Angie é o motor escolhido pelo utilizador (fork evoluído do ecossistema Nginx, configuração familiar `nginx`-like).
- Escopo não inclui substituir ngrok; podem coexistir (perfis Compose distintos).
