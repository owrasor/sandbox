# Feature Specification: Arranque único de script de dotfiles configurável

**Feature Branch**: `007-dotfiles-bootstrap-once`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "eu quero fazer com que eu possa rodar um script, especificado dentro do meu .env pelo nome do arquivo, que esteja dentro da minha pasta compartilhada do dotfiles no container. O objetivo é permitir que ele faça umas instalações básicas e que seja rodado apenas uma vez. Não sei se tem uma opção para rodar durante o build ou se é melhor rodar durante a inicialização do container. No meu caso ele irá preparar o que tenho de configuração de tmux, zsh e nvim conforme o meu workflow."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Configurar e executar um arranque pessoal uma única vez (Priority: P1)

Um desenvolvedor que usa o contentor de desenvolvimento com uma pasta pessoal de configuração (dotfiles) partilhada quer indicar, através de configuração de ambiente no seu `.env`, o **nome de ficheiro** de um script que vive nessa pasta. Na **primeira utilização válida** do ambiente de trabalho, esse script deve ser executado **automaticamente uma vez** para aplicar preparações iniciais (por exemplo alinhar tmux, zsh e nvim ao fluxo de trabalho do utilizador), sem voltar a correr em arranques posteriores com o mesmo “estado persistente” de ambiente.

**Why this priority**: Entrega o valor central — automatizar onboarding de ferramentas interactivas sem repetir trabalho a cada sessão.

**Independent Test**: Com variável de ambiente definida no `.env`, ficheiro presente na área partilhada de dotfiles e sem registo prévio de conclusão, arrancar o ambiente e verificar que o script corre exactamente uma vez e que um segundo arranque equivalente não o volta a invocar.

**Acceptance Scenarios**:

1. **Given** configuração que aponta para um nome de ficheiro existente na pasta partilhada de dotfiles e ainda não houve arranque bem-sucedido registado, **When** o ambiente de desenvolvimento completa o arranque habitual, **Then** o script referenciado é executado e as alterações pretendidas pelo utilizador ficam aplicadas para sessões seguintes.
2. **Given** o mesmo utilizador e volume persistente após um arranque em que o script já foi concluído com sucesso, **When** o ambiente arranca novamente, **Then** o script de arranque **não** é executado outra vez.

---

### User Story 2 - Desactivar ou omitir o arranque sem erros (Priority: P2)

O desenvolvedor pode não querer nenhum script de arranque (campo vazio ou ausente) ou pode remover o ficheiro; o arranque do ambiente deve permanecer utilizável.

**Why this priority**: Evita bloquear o contentor por configuração opcional ou ficheiros em mutação.

**Independent Test**: Arrancar com variável vazia, com variável apontando para ficheiro inexistente, e confirmar comportamento previsível documentado (sem falha de arranque por defeito).

**Acceptance Scenarios**:

1. **Given** nenhum nome de script configurado ou valor explicitamente vazio, **When** o ambiente arranca, **Then** nenhum script de dotfiles bootstrap é invocado e a shell fica disponível normalmente.
2. **Given** um nome configurado mas o ficheiro não existe na pasta partilhada, **When** o ambiente arranca, **Then** o sistema regista ou comunica o problema de forma clara e o utilizador consegue entrar no ambiente para corrigir a configuração (sem ciclo de falha silenciosa que pareça “já ter corrido”).

---

### User Story 3 - Falhas do script não corrompem o estado “uma vez” (Priority: P3)

Se o script falhar (erro de sintaxe, comando intermédio falhou, permissões), o utilizador espera poder corrigir o script e voltar a tentar num arranque futuro, em vez de ficar bloqueado com um estado “já executado” incorrecto.

**Why this priority**: Alinha expectativas com workflows de iteração em configuração pessoal.

**Independent Test**: Forçar saída de erro do script; arrancar de novo após correcção e verificar segunda tentativa permitida.

**Acceptance Scenarios**:

1. **Given** script configurado que termina com código de erro (falha), **When** o ambiente conclui a tentativa de arranque, **Then** o sistema **não** regista o arranque como concluído com sucesso e uma execução futura pode voltar a tentar após correcção.
2. **Given** script que termina com sucesso, **When** a execução completa, **Then** o registo de “já executado” reflecte apenas essa conclusão bem-sucedida.

---

### Edge Cases

- Nome de ficheiro com caracteres ou caminhos inseguros: o sistema deve resolver o ficheiro apenas dentro da área partilhada de dotfiles (sem seguir caminhos absolutos arbitrários que saiam dessa raiz, salvo política explícita documentada).
- Arranques concorrentes (dois processos de entrada ao mesmo tempo): o “uma vez” deve permanecer verdadeiro — no máximo uma execução bem-sucedida ou comportamento de exclusão mútua documentado.
- Utilizador altera o nome do script no `.env` após já ter corrido outro: definir se novo nome implica nova execução (recomendação em Assumptions).
- Espaço em disco ou permissões na localização do marcador de “já executado”: falha ao gravar o marcador deve ser visível ou repetir tentativa de forma segura.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O ambiente de desenvolvimento MUST permitir configurar, via ficheiro `.env` do projecto, o **nome** (ou identificador de ficheiro relativo acordado) do script de arranque opcional.
- **FR-002**: O script referenciado MUST ser resolvido apenas a partir da pasta partilhada de dotfiles do contentor (mesma área já usada para montar configuração pessoal).
- **FR-003**: Quando a configuração estiver definida e o ficheiro existir, o ambiente MUST executar o script **no máximo uma vez** por identidade persistente de arranque (por exemplo volume ou utilizador no contentor), até que o utilizador invalide explicitamente esse estado conforme política documentada.
- **FR-004**: Quando a configuração estiver vazia ou ausente, o ambiente MUST arrancar sem invocar script de bootstrap.
- **FR-005**: Quando o ficheiro não existir, o ambiente MUST não tratar o arranque como “concluído” e MUST permitir ao utilizador corrigir e voltar a arrancar.
- **FR-006**: Se o script terminar com erro, o ambiente MUST **não** marcar o bootstrap como concluído com sucesso.
- **FR-007**: O ponto do ciclo de vida em que a execução ocorre MUST ser **no arranque do ambiente** (quando ficheiros do utilizador e volumes estão disponíveis), **não** como passo obrigatório da construção da imagem que não tenha acesso ao `.env` e dotfiles do utilizador — salvo documentação de excepção acordada para casos especiais.

### Key Entities

- **Configuração de bootstrap**: Par nome/valor no `.env` que identifica o ficheiro de script (sem conteúdo do script na spec).
- **Área partilhada de dotfiles**: Directório montado no contentor onde o utilizador coloca scripts e configuração pessoal.
- **Estado de conclusão**: Marcador persistido (por exemplo ficheiro em volume gravável) que indica que o script já foi executado com sucesso para aquela identidade de ambiente.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em cenário de primeira utilização com script válido, **100%** dos arranques de referência executam o script **exactamente uma vez** antes de o utilizador usar a shell interactiva para trabalho normal (medido por ordem de eventos de arranque e presença do marcador de sucesso).
- **SC-002**: Em **pelo menos 3** arranques consecutivos após sucesso, **0** reexecuções involuntárias do mesmo script de bootstrap (verificação por registo ou auditoria simples).
- **SC-003**: Com configuração omitida ou vazia, **100%** dos arranques de teste completam sem invocação de script e sem erro atribuível a esta funcionalidade.
- **SC-004**: Com script que falha intencionalmente, **100%** dos casos de teste permitem nova tentativa após correcção (marcador de sucesso não gravado após falha).

## Assumptions

- A pasta partilhada de dotfiles e o `.env` já existem no fluxo actual do projecto; esta feature apenas liga um script nomeado no `.env` a uma execução única no arranque.
- O “uma vez” associa-se ao **mesmo volume/persistência** do contentor de desenvolvimento; recriar o volume sem dados equivale a “primeira vez” de novo.
- Se o utilizador mudar o nome do ficheiro configurado **depois** de um bootstrap bem-sucedido, assume-se que **não** reexecuta automaticamente a menos que o utilizador apague o marcador de conclusão (comportamento a documentar na implementação para evitar surpresas).
- O script é não-interactivo ou adequado a execução no arranque (sem prompts bloqueantes); pedidos interactivos são responsabilidade do conteúdo do script do utilizador.
- Execução no **arranque** (e não no build da imagem) é o modo por defeito para ter acesso ao `.env` local e aos dotfiles montados; builds reprodutíveis da imagem base não dependem deste script.
