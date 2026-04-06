# Feature Specification: Editor na versão estável oficial

**Feature Branch**: `004-update-neovim-stable`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "então quero trocar a versão dele para a última versão estável contida no site https://neovim.io/doc/install/"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ambiente com editor estável atual (Priority: P1)

Um desenvolvedor que abre o ambiente de trabalho padrão do projeto (por exemplo, após clonar o repositório e subir o ambiente documentado) passa a ter o editor de terminal na **versão estável atual** indicada pela documentação oficial de instalação do produto referenciada pelo pedido, sem precisar instalar manualmente outra versão só para acompanhar o time.

**Why this priority**: Entrega o valor central — paridade de ferramentas e acesso a correções e recursos da linha estável suportada oficialmente.

**Independent Test**: Subir o ambiente padrão documentado, abrir uma sessão interativa do editor a partir do shell e confirmar que a identificação de versão corresponde à estável oficial vigente na data da entrega.

**Acceptance Scenarios**:

1. **Given** um ambiente recém-provisionado conforme a documentação do projeto, **When** o desenvolvedor inicia o editor de terminal, **Then** a versão apresentada corresponde à versão estável atual descrita na documentação oficial de instalação do produto.
2. **Given** um desenvolvedor que já usa o ambiente padrão, **When** aplica a atualização desta entrega e reinicia o ambiente, **Then** obtém a mesma geração estável que um colega que provisiona do zero.

---

### User Story 2 - Verificação objetiva pela equipe (Priority: P2)

Uma pessoa responsável pela manutenção do ambiente (ou qualquer desenvolvedor seguindo um checklist) consegue **confirmar em poucos passos** que o ambiente está alinhado à estável oficial, sem interpretação subjetiva de “versão nova o suficiente”.

**Why this priority**: Reduz divergência entre máquinas e facilita suporte quando algo falha.

**Independent Test**: Executar o procedimento de verificação documentado no repositório e obter um resultado binário (alinhado / não alinhado) em no máximo 5 minutos.

**Acceptance Scenarios**:

1. **Given** a documentação oficial de instalação que indica a versão estável corrente, **When** o mantenedor executa o passo de verificação descrito pelo projeto, **Then** o resultado confirma correspondência com essa indicação.
2. **Given** um relatório de incidente “editor com comportamento estranho”, **When** o suporte pede a verificação de versão, **Then** a equipe consegue coletar a informação de versão de forma consistente em todos os ambientes padrão.

---

### Edge Cases

- O site oficial publicar uma nova versão estável **durante** a entrega: a entrega fixa uma geração estável explícita no material do projeto; uma atualização subsequente pode alinhar de novo — o escopo desta feature é **uma** atualização para a estável vigente à conclusão, registrada de forma auditável.
- **Provisionamento sem rede** ou com espelhos restritos: o material do projeto deve deixar claro se a imagem/artefato já inclui o editor ou se o download é obrigatório, para não falhar em silêncio.
- **Configuração pessoal** do desenvolvedor (arquivos de configuração locais): a atualização não deve apagar ou ignorar caminhos de configuração já documentados pelo projeto sem aviso equivalente na documentação de migração.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O ambiente de desenvolvimento padrão do projeto MUST expor o editor de terminal na **versão estável atual** conforme a documentação oficial de instalação referida no campo **Input** desta especificação, na data em que a mudança for concluída.
- **FR-002**: O repositório MUST registrar de forma explícita **qual** geração estável foi adotada (identificador de versão legível por humanos), para que qualquer pessoa possa comparar com a documentação oficial.
- **FR-003**: Após seguir apenas os passos já documentados para subir o ambiente, o desenvolvedor MUST conseguir invocar o editor interativo sem passos ad hoc não documentados exclusivamente para esta versão.
- **FR-004**: A mudança MUST preservar os caminhos e convenções de configuração do editor que o projeto já documenta como suportados, salvo se a documentação de projeto for atualizada na mesma entrega para descrever qualquer alteração necessária.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em testes de aceitação no ambiente padrão, **100%** das execuções bem-sucedidas de provisionamento permitem abrir o editor e obter identificação de versão que coincide com a estável oficial indicada na documentação de instalação referida, sem erro de inicialização atribuível à troca de versão.
- **SC-002**: **100%** dos membros da equipe que usam o ambiente padrão completam, em **uma única sessão de trabalho**, um roteiro mínimo de edição (abrir repositório, abrir arquivo existente, gravar alteração, localizar texto) em **menos de 2 minutos por etapa** em hardware e rede típicos de desenvolvimento.
- **SC-003**: O registro da versão estável adotada fica disponível na documentação voltada à equipe **no máximo 1 dia útil** após a conclusão da mudança, permitindo auditoria posterior sem consultar apenas histórico técnico interno.

## Assumptions

- “Ele” no pedido original refere-se ao editor **Neovim** já usado ou previsto no ambiente de desenvolvimento do workspace (incluindo dev container, se for o caso).
- O escopo limita-se à **versão estável** divulgada pela documentação oficial de instalação; builds noturnos, pré-lançamentos ou forks não entram no escopo salvo decisão futura explícita.
- A equipe já possui ou aceita um procedimento mínimo de “fumaça” (abrir/editar/gravar) para validar o ambiente após mudanças de ferramentas.
- Outras ferramentas do ambiente (proxy, linguagens, extensões de IDE) permanecem fora do escopo salvo regressão diretamente causada pela atualização do editor.
