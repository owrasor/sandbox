# Política de frescura — imagem `dev` (sandbox)

**Versão da política**: 2026-04-06  
**Âmbito**: Serviço **`dev`** definido em `docker-compose.yml` / `docker/Dockerfile` deste repositório. Não obriga configurações em máquinas pessoais fora deste fluxo.

## 1. Definição de «estável» por categoria

| Categoria | Fonte de verdade para «última estável» | Notas |
|-----------|----------------------------------------|-------|
| Pacotes **APT** (Ubuntu 24.04) | Repositórios oficiais Ubuntu para a série LTS em uso | Versões seguem o ciclo LTS; *não* se considera «estável» o canal Debian unstable/testing. |
| Runtimes **mise** (`php@8.4`, `node@22`) | Releases publicadas nos canais estáveis dos fornecedores (PHP.net, Node.js) para os **major/minor pinados** no Dockerfile | O pin é `8.4` e `22`; dentro desses, adoptar **última patch** disponível no registry mise no rebuild. |
| **Neovim** e outros pacotes só APT | Versão empacotada no Ubuntu para a imagem base | Se o pacote distro violar o SLA P1, abrir excepção ou migrar canal (ex.: mise/build) com PR dedicado. |

**Excluído**: builds noturnas, `-git`, forks não oficiais, salvo excepção documentada.

## 2. Métricas e prazos (mínimo três)

1. **SLA P1 (dias)**: até **30 dias** após publicação da **última patch estável** do fornecedor para um item **P1**, a imagem `dev` rebuildada deve reflectir essa versão *ou* existir **excepção aprovada** com data de revisão.  
2. **SLA P2/P3 (dias)**: até **90 dias** para itens não P1, salvo decisão contrária no inventário.  
3. **Auditoria / reverificação**: **trimestral** (mínimo uma vez por trimestre civil) contra o inventário crítico; meta **≥ 90%** dos itens **P1** em `ok` ou com excepção registada (alinhado SC-002).  
4. **Excepções**: duração máxima **90 dias** por excepção; renovação requer re-aprovação explícita.

## 3. Processo de actualização (repetível)

1. Consultar releases upstream para itens P1 do [capability-inventory.md](./capability-inventory.md).  
2. Actualizar `docker/Dockerfile` (e scripts referenciados) com pins/versões necessários.  
3. `docker compose build dev` localmente; corrigir falhas de build.  
4. Actualizar `capability-inventory.md` e criar/actualizar registo em `audits/` no mesmo PR.  
5. Merge após revisão de código; preferencialmente um maintainer da imagem como aprovador para mudanças P1.

**Aprovação de excepções**: um maintainer + registo no inventário e na auditoria (motivo, dono, data de revisão).

## 4. Processo de excepção (detalhe)

- Abrir issue ou secção no PR com: **ID inventário**, **motivo**, **risco**, **data limite**, **aprovador**.  
- Marcar linha no inventário: `compliance = exception`.  
- Não mais de **3 excepções P1** em simultâneo sem revisão formal da política.

## 5. Linha de base reprodutível (FR-006)

Para incidentes e suporte, referenciar sempre **pelo menos um** dos seguintes:

1. **Git SHA** do repositório sandbox no momento do build (ex.: `git rev-parse HEAD` no CI ou anotado no PR de imagem).  
2. **Digest** da imagem publicada (se/tag) após push para registry interno; se só local, **tag de data** `dev-YYYY-MM-DD` documentada no registo de auditoria.  
3. **Snapshot** do ficheiro `capability-inventory.md` e do registo em `audits/` na data do incidente.

**Rollback lógico**: voltar ao commit do Dockerfile que corresponde à baseline; rebuild; confirmar versões com os comandos do `audit-template.md`.

## 6. Anúncio de mudanças incompatíveis

Antes de merge que altere **comportamento** ou **CLI** de ferramenta P1 de forma incompatível:

- [ ] Descrição no PR com impacto esperado e mitigação.  
- [ ] Entrada curta em `docs/sandbox.md` ou `README.md` (secção changelog interno) se afectar fluxo documentado.  
- [ ] Actualizar `capability-inventory.md` na mesma alteração.  
- [ ] Notificar canal da equipa (fora deste repo) quando existir.

## 7. Cadência de reverificação

- **Trimestral**: Q1, Q2, Q3, Q4 — criar ficheiro em `audits/` usando o modelo.  
- **Ad hoc** após incidente de segurança relevante ou CVE em ferramenta P1.

## 8. Revisão desta política

Rever pelo menos **anualmente** ou quando a [platform-evaluation.md](./platform-evaluation.md) recomendar mudança de modelo (ex.: migração para base rolling).
