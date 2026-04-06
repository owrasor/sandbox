# Avaliação da plataforma base — contentor `dev`

## Metadados

| Campo | Valor |
|-------|-------|
| **date** | 2026-04-06 |
| **author** | Equipa sandbox (documento inicial em implementação 003) |
| **reviewer** | _Pendente — assinar no PR antes de encerrar a feature (SC-003)_ |

> **SC-003**: Exigem-se **duas pessoas** (autor + revisor). Substituir a linha do revisor por nome/handle e data quando validado por par humano.

## Contexto

A política de frescura ([freshness-policy.md](./freshness-policy.md)) exige ferramentas estáveis recentes com SLAs mensuráveis. A imagem actual usa **Ubuntu 24.04 LTS** com **APT** para a maior parte do sistema e **mise** para **PHP 8.4** e **Node 22**. Foi levantada a hipótese de migrar para uma **distribuição rolling** para maximizar frescura global.

## Critérios de decisão

1. Capacidade de cumprir SLAs da política com esforço sustentável.  
2. Estabilidade e previsibilidade para debugging e onboarding.  
3. Tempo de build e manutenção do Dockerfile.  
4. Segurança e suporte de patches.  
5. Alinhamento com o inventário ([capability-inventory.md](./capability-inventory.md)).

## Estado actual (resumo)

- **Base**: Ubuntu 24.04 LTS, pin explícito no Dockerfile.  
- **Runtimes críticos**: PHP e Node via **mise** com pins `8.4` e `22`.  
- **Editores / CLI**: maioritariamente **APT**; **Neovim** empacotado em 0.9.5 (atrás do upstream estável ≥ 0.10), tratado como **excepção** documentada até decisão de canal.

## Opções consideradas

### A — Manter LTS + APT + mise (actual, evolutivo)

- **Prós**: Previsível, bem suportado, já implementado; mise cobre runtimes com releases claras.  
- **Contras**: Pacotes só APT podem atrasar versões major (caso Neovim).

### B — Migrar imagem para base **rolling** (ex.: Arch, Tumbleweed)

- **Prós**: Frescura elevada em todo o stack de sistema.  
- **Contras**: Mais variância entre builds; mais tempo de revisão; possível fricção com binários de terceiros; curva de aprendizagem para a equipa.

### C — Manter LTS; mover ferramentas críticas lentas do APT para **mise** ou builds upstream

- **Prós**: Mantém base estável; resolve casos pontuais (Neovim) sem rolling global.  
- **Contras**: Dockerfile ligeiramente mais complexo.

## Riscos

| Opção | Risco | Mitigação |
|-------|-------|-----------|
| A | Obsolescência pontual (editores) | Excepções + roadmap para mise/build |
| B | Regressões de biblioteca | Testes de smoke; pinagem mais frequente; documentação |
| C | Duplicação de canais | Inventário claro por ID; uma fonte por ferramenta |

## Recomendação

**Manter (A)** a base **Ubuntu 24.04 LTS** com **mise** para runtimes pinados; **não migrar** para rolling neste ciclo.  
Planeamento: avaliar **(C)** para **Neovim** (ou equivalente) num PR futuro para fechar a excepção P1, se a política deixar de aceitar 0.9.x.

**Próximos passos**

1. Revisor humano assinar metadados acima.  
2. Abrir tarefa/PR opcional: Neovim via mise ou binário upstream.  
3. Rever esta avaliação **anualmente** ou após mudança major do Dockerfile.
