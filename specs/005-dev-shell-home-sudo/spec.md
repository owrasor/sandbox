# Feature Specification: Shell na home do desenvolvedor e privilégios elevados

**Feature Branch**: `005-dev-shell-home-sudo`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "Tendo o contexto anterior em vista, eu gostaria que quando eu rodasse o comando docker compose exec dev zsh que ele entrasse diretamente no zsh no home do usuário dev. E quero que este usuário tenha acesso a sudo."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sessão interativa começa na pasta pessoal (Priority: P1)

Um desenvolvedor que abre uma sessão de terminal interativa no serviço de desenvolvimento do projeto, usando o **fluxo documentado** para anexar um interpretador de comandos a esse serviço, passa a **começar essa sessão com a pasta de trabalho atual na área pessoal** da conta de desenvolvimento (equivalente conceitual a “home” desse utilizador), em vez de ficar preso à pasta do código montada por defeito.

**Why this priority**: Corresponde ao pedido explícito e remove fricção ao correr ferramentas que assumem ficheiros de configuração ou caches na home.

**Independent Test**: Com o ambiente de desenvolvimento em execução, abrir uma sessão interativa conforme documentação atualizada; verificar que o caminho inicial exibido corresponde à pasta pessoal da conta de desenvolvimento.

**Acceptance Scenarios**:

1. **Given** o serviço de desenvolvimento em execução conforme a documentação do projeto, **When** o desenvolvedor executa o comando documentado para abrir `zsh` interativo nesse serviço, **Then** a pasta de trabalho atual ao entrar é a pasta pessoal da conta de desenvolvimento.
2. **Given** uma sessão já aberta nessa pasta pessoal, **When** o desenvolvedor navega para a pasta do repositório montada, **Then** continua a conseguir trabalhar no código normalmente (sem regressão de montagens ou permissões já estabelecidas).

---

### User Story 2 - Tarefas de manutenção com privilégios elevados (Priority: P2)

O mesmo utilizador de desenvolvimento (conta não privilegiada no dia a dia) consegue, quando necessário, **executar ações que exigem privilégios de administrador** dentro do ambiente (por exemplo instalar um pacote de sistema ou ajustar permissões), sem precisar de reconstruir a imagem para cada pequena necessidade de laboratório.

**Why this priority**: Desbloqueia fluxos de trabalho reais em ambiente de desenvolvimento sem comprometer o objetivo de trabalhar habitualmente como utilizador não root.

**Independent Test**: Na sessão como conta de desenvolvimento, executar um comando de verificação de privilégios elevados documentado (por exemplo listar identidade após elevação) e uma operação simples permitida por essa política.

**Acceptance Scenarios**:

1. **Given** sessão interativa como a conta de desenvolvimento, **When** o utilizador invoca o mecanismo de elevação suportado pelo ambiente para um comando de sistema, **Then** o comando executa com privilégios elevados e o resultado confirma sucesso para operações permitidas pela política configurada.
2. **Given** a necessidade de instalar uma dependência de sistema durante o desenvolvimento, **When** o utilizador segue o procedimento documentado usando elevação, **Then** conclui a instalação sem ter de entrar como superutilizador em sessão de login completa, salvo onde a documentação explicitamente recomende outro fluxo.

---

### Edge Cases

- **Variáveis de ambiente ou ficheiros de perfil** que alterem o diretório ao iniciar o interpretador: o comportamento acordado é o **diretório após carregar o perfil de login** do `zsh` ser a pasta pessoal; se o perfil mudar explicitamente de diretório, isso é comportamento do perfil, não regressão desta feature.
- **Outros comandos além de `zsh`**: o escopo mínimo é o fluxo pedido (`exec` + `zsh`); outros pontos de entrada podem manter o diretório de trabalho anterior salvo decisão futura de alinhar tudo.
- **Política de elevação**: erros de configuração (comando não permitido, política restritiva) devem falhar de forma clara; não é objetivo desta feature definir lista exaustiva de comandos permitidos — assume-se elevação típica de ambiente de desenvolvimento interno.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O ambiente de desenvolvimento MUST garantir que, ao abrir uma sessão interativa de `zsh` no serviço de desenvolvimento através do **fluxo documentado** para esse efeito, a pasta de trabalho inicial após o arranque do interpretador seja a **pasta pessoal** da conta de desenvolvimento do ambiente.
- **FR-002**: A conta de desenvolvimento MUST poder **elevar privilégios** (acesso a `sudo` ou equivalente funcional) para executar comandos de sistema dentro do ambiente, conforme política instalada na mesma entrega.
- **FR-003**: A documentação do projeto MUST descrever, em passos verificáveis, como confirmar (1) o diretório inicial da sessão interativa e (2) que a elevação de privilégios está disponível para a conta de desenvolvimento.
- **FR-004**: A alteração MUST preservar o comportamento existente de montagem do código e de ficheiros pessoais (por exemplo dotfiles e chaves) já definido pelo projeto, salvo correção documentada de bug de segurança ou de permissões.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em **100%** das tentativas bem-sucedidas de abrir sessão interativa de `zsh` no serviço de desenvolvimento pelo fluxo documentado, o diretório de trabalho após o arranque corresponde à pasta pessoal da conta de desenvolvimento (validação por comando de listagem de diretório ou equivalente).
- **SC-002**: Em **100%** dos testes de aceitação executados como conta de desenvolvimento, pelo menos **uma** operação privilegiada representativa (por exemplo instalação ou consulta de pacote de sistema) completa com sucesso em **menos de 2 minutos** em condições de rede e hardware típicas de desenvolvimento, seguindo apenas a documentação do projeto.
- **SC-003**: **90%** dos desenvolvedores que já usam o ambiente relatam, num inquérito interno informal ou retro de equipa, que deixaram de precisar de “truques” manuais (como `cd` imediato ou sessão separada como superutilizador) para as duas necessidades acima — medido na primeira iteração após a entrega.

## Assumptions

- O ambiente destina-se a **desenvolvimento interno/equipa**, não a imagens expostas como produto final sem endurecimento adicional.
- É aceitável configurar elevação **sem pedido interativo de palavra-passe** para a conta de desenvolvimento dentro deste ambiente, alinhado a padrões comuns de contentores de desenvolvimento.
- O superutilizador continua a existir para tarefas de arranque (por exemplo alinhar UID/GID), mas o trabalho quotidiano permanece na conta de desenvolvimento com elevação sob demanda.
