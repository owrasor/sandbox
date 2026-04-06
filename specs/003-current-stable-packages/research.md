# Research — 003-current-stable-packages

## 1. Plataforma base: LTS fixo vs rolling release

**Decision**: Manter **Ubuntu LTS 24.04** (ou equivalente fixo) como base da imagem `dev` na entrega inicial desta feature; **não** migrar para distribuição rolling sem conclusão explícita favorável no relatório de avaliação da plataforma (FR-004).

**Rationale**: Rolling maximiza frescura de *todo* o stack de sistema, mas aumenta **variância**, **risco de regressões** em bibliotecas partilhadas e **custo de revisão** para uma equipa pequena. A spec exige sobretudo **ferramentas de desenvolvimento** estáveis recentes e **processo mensurável** — isso consegue-se com base fixa + camada de ferramentas versionada.

**Alternatives considered**:

- **Imagem rolling (ex.: Arch, openSUSE Tumbleweed)**: melhor para “sempre o mais recente” global; contra: menos previsibilidade, documentação de suporte mais exigente, possível fricção com binários pré-compilados de terceiros.
- **Debian testing/unstable em contentor**: compromisso intermédio; contra: testing não é “estável” no sentido Debian stable — conflita com a definição de “estável” na spec sem política extra.
- **Duas imagens (`dev` + `dev-rolling`)**: útil como spike futuro; fora do MVP desta feature salvo decisão no relatório.

---

## 2. Canal para “estável mais recente” das ferramentas

**Decision**: Política em **dois níveis**: (1) **apt** — pacotes de sistema e dependências de compilação com critério “security + cadência trimestral de revisão”; (2) **mise** — runtimes e ferramentas com releases claras (**PHP**, **Node**, e futuros pins documentados no inventário). Versões exactas registadas no inventário; actualização por **rebuild de imagem** com changelog curto no PR.

**Rationale**: O repositório já usa mise para PHP/Node (`002`); alinhar a política evita duas “fontes de verdade” conflituosas. Ferramentas que o Ubuntu atrasa (ex.: Neovim major) entram no inventário com estratégia explícita: **mise plugin**, **release upstream**, ou **excepção** com prazo.

**Alternatives considered**:

- **Apenas apt + backports**: simples, mas frequentemente insuficiente para versões major de editores/runtimes pedidas pela equipa.
- **Nix ou Homebrew no contentor**: poderoso; contra: complexidade e tempo de build; reservado para avaliação futura se mise não cobrir requisitos.
- **Sempre `latest` sem pin**: rejeitado — viola FR-006 (baseline reprodutível).

---

## 3. Onde vivem os artefactos de governação

**Decision**: Diretório **`docs/dev-environment/`** na raiz do repo (versionado), com ficheiros listados no `plan.md`; ligação a partir de `README.md` e `docs/sandbox.md`.

**Rationale**: Mantém política próxima do código que define o contentor; auditável em PR; não exige infra externa.

**Alternatives considered**:

- **Wiki externa**: menos rastreável em revisão de código.
- **Só em `specs/003-.../`**: bom para histórico da feature, mas **operacional** deve viver em `docs/` para sobreviver ao encerramento do número da spec.

---

## 4. Cadência e métricas (ligação a SC-001–SC-004)

**Decision**: Proposta de métricas iniciais (ajustáveis na política final): (a) **Prazo máximo** de adoção da última minor/patch estável do fornecedor: **30 dias** para itens críticos do inventário; (b) **auditoria trimestral** obrigatória (FR-005); (c) **≥90%** itens críticos em conformidade ou com excepção aprovada (SC-002); (d) inquérito 1–5 após primeira rodagem (SC-004).

**Rationale**: Dá conteúdo testável aos FRs sem depender de uma ferramenta de CI específica.

**Alternatives considered**: Prazos mais agressivos (7 dias) — possível para equipa dedicada; mais relaxados (90 dias) — arrisca obsolescência percebida; ficam como opções na secção “Ajuste” da política.

---

## Resolução de NEEDS CLARIFICATION

Nenhum marcador pendente no `spec.md`; decisões acima fecham escolhas técnicas abertas para planeamento.
