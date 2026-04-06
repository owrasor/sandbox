# Feature Specification: Ambiente de desenvolvimento com pacotes estáveis recentes

**Feature Branch**: `003-current-stable-packages`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "eu preciso dos pacotes sempre instalados nas versões estáveis mais recentes. Talvez seja melhor trocar de debian para um outro sistema operacional com roling release."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ferramentas alinhadas com versões estáveis recentes (Priority: P1)

Como desenvolvedor que usa o ambiente padronizado da equipa, quero que editores, runtimes e utilitários acordados estejam, de forma consistente, nas versões estáveis mais recentes permitidas pela política da equipa, para evitar incompatibilidades com documentação, tutoriais e dependências modernas.

**Why this priority**: É o problema central descrito pelo utilizador; sem frescura controlada, o resto da feature perde sentido.

**Independent Test**: Contra um inventário priorizado de capacidades (ex.: editor, runtime de linguagem, cliente de base de dados), verifica-se que cada item cumpre a política de frescura numa data de auditoria acordada.

**Acceptance Scenarios**:

1. **Given** uma política de frescura publicada e um inventário de pacotes/capacidades críticas, **When** se executa a auditoria na data planeado, **Then** cada item crítico está dentro dos prazos máximos definidos ou existe exceção documentada com dono e plano.
2. **Given** um novo membro que segue apenas a documentação oficial do ambiente, **When** provisiona o ambiente pela primeira vez, **Then** obtém versões que cumprem a mesma política que o resto da equipa (sem passos manuais não documentados para “atualizar tudo”).

---

### User Story 2 - Decisão informada sobre a plataforma base (Priority: P2)

Como equipa responsável pelo ambiente, queremos avaliar se a plataforma base atual (ciclo de atualizações mais lento) continua adequada ou se um modelo de atualização mais contínuo melhor cumpre a política de frescura, com riscos e custos explícitos.

**Why this priority**: O utilizador levantou explicitamente a troca de modelo de distribuição; a decisão deve ser registada e fundamentada, não apenas implícita.

**Independent Test**: Existe um documento de avaliação com critérios, comparação contra a política, recomendação e próximos passos, revisto por pelo menos um par.

**Acceptance Scenarios**:

1. **Given** a política de frescura e o inventário crítico, **When** a avaliação é concluída, **Then** o documento conclui se se mantém a plataforma atual, se se migra, ou se se adia decisão, com justificação ligada aos critérios.
2. **Given** a opção de mudança de plataforma base, **When** alguém lê o documento, **Then** encontra riscos (ex.: estabilidade, suporte, curva de aprendizagem) e mitigações ou itens em aberto claramente listados.

---

### User Story 3 - Equilíbrio entre frescura e previsibilidade (Priority: P3)

Como equipa, precisamos que atualizações frequentes não quebrem fluxos de trabalho nem tornem impossível reproduzir um estado “conhecido bom” quando há um incidente.

**Why this priority**: “Sempre o mais recente” entra em conflito com debugging e onboarding; deve ficar explícito como se gere esse equilíbrio.

**Independent Test**: A documentação descreve como congelar, etiquetar ou referenciar uma linha de base para suporte e como isso coexiste com a política de frescura.

**Acceptance Scenarios**:

1. **Given** um incidente atribuído a mudança de versão, **When** a equipa segue o procedimento documentado, **Then** consegue identificar a linha de base em uso e reproduzir ou reverter para um estado documentado sem improvisação não registada.
2. **Given** uma atualização que introduz mudança incompatível (comportamento ou formato), **When** a alteração é aplicada ao ambiente padrão, **Then** existe nota de migração ou checklist acessível à equipa antes ou no mesmo prazo da mudança.

---

### Edge Cases

- **Definição de “estável” ambígua**: algumas ferramentas têm vários canais; a política deve indicar qual canal conta como estável para efeitos de cumprimento.
- **Atualização que quebra projetos legados**: exceções temporárias ou pinos documentados até migração de código ou de configuração.
- **Heterogeneidade**: developers em máquinas pessoais fora do ambiente padronizado — política deve clarificar o que é obrigatório vs. recomendado.
- **Indisponibilidade temporária** de builds ou repositórios: prazo de frescura pode ser violado por causa externa; deve haver registo de incidente e plano de recuperação.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A organização MUST publicar e manter uma **política de frescura** que defina o que significa “versão estável mais recente” aplicável ao ambiente padronizado e **prazos máximos mensuráveis** (em dias ou equivalente) entre a disponibilização da versão estável pelo fornecedor e a sua adoção no ambiente padrão, para as capacidades críticas inventariadas.
- **FR-002**: MUST existir um **inventário priorizado** de capacidades de desenvolvimento (ferramentas, runtimes, serviços locais) com indicação de criticidade para o trabalho diário e responsável pela sua manutenção.
- **FR-003**: O processo de atualização do ambiente padrão MUST ser **repetível e documentado** (passos, frequência mínima de verificação, e quem aprova exceções).
- **FR-004**: MUST ser produzida uma **avaliação documentada da plataforma base** (adequação à política de frescura, alternativas consideradas incluindo modelos de atualização mais contínuos, riscos e recomendação), datada e sujeita a revisão por pares.
- **FR-005**: O sistema de governação do ambiente MUST prever **cadência de reverificação** (por exemplo trimestral) contra o inventário e a política, com registo de resultado.
- **FR-006**: MUST existir **procedimento para linhas de base reprodutíveis** (como referenciar um estado aprovado para suporte ou rollback lógico) sem contradizer a política de frescura de forma não explicada.

### Key Entities

- **Política de frescura**: regras, prazos, definição de canal “estável”, tratamento de exceções.
- **Inventário de capacidades**: lista priorizada, criticidade, dono, evidência de última conformidade.
- **Avaliação de plataforma base**: critérios, opções consideradas, riscos, recomendação, data e revisores.
- **Registo de auditoria / reverificação**: data, amostra verificada, passou/falhou, ações corretivas.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A política de frescura contém **pelo menos três prazos ou métricas numéricas explícitas** (ex.: dias máximos, percentagem mínima de itens em conformidade numa auditoria) aplicáveis ao inventário crítico.
- **SC-002**: Na **primeira auditoria completa** após implementação, **no mínimo 90%** dos itens do inventário classificados como críticos cumprem a política ou têm **exceção assinada** com data de revisão.
- **SC-003**: O documento de avaliação da plataforma base está **completo, datado e revisto por pelo menos duas pessoas** (autor + revisor) antes de encerrar a feature.
- **SC-004**: **Inquérito rápido à equipa** (escala 1–5) sobre “as versões das ferramentas permitem trabalhar sem bloqueios por obsolescência”: **mediana ≥ 4** na primeira medição após entrada em vigor da política e processos.

## Assumptions

- O foco é o **ambiente de desenvolvimento padronizado da equipa** (por exemplo imagem ou kit partilhado), não necessariamente todas as máquinas pessoais dos developers.
- “Estável mais recente” refere-se a **canais oficiais de estabilidade** dos fornecedores, não a builds experimentais ou noturnas, salvo exceção na política.
- A decisão sobre **mudança de plataforma base** é uma **recomendação governada**; a implementação física pode ser faseada noutro trabalho, desde que esta feature entregue política, inventário, avaliação e critérios de sucesso verificáveis.
- Não há requisito legal específico além de boas práticas habituais de equipa de produto interno; conformidade sectorial, se existir, será acrescentada noutra especificação.
