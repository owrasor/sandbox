# Feature Specification: Runtimes e CLIs de IA por defeito no contentor de desenvolvimento

**Feature Branch**: `002-mise-php-node-ai-defaults`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "Gostaria que por padrão viesse instalado o mise para controle de pacotes de versão. Também gostaria que visesse por padrão no php 8.4 usando o mise e o node na versão 22. Depois disso, quero que seja instalado automaticamente os clientes de IA sem a necessidade do uso da configuração no .env."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Runtimes PHP e Node prontos ao entrar no contentor (Priority: P1)

Um desenvolvedor clona o repositório, segue o arranque documentado do contentor de desenvolvimento e, na primeira sessão interactiva, precisa de PHP 8.4 e Node 22 já disponíveis e correctamente versionados para trabalhar em projectos típicos, sem instalar manualmente esses runtimes dentro do contentor.

**Why this priority**: Sem runtimes alinhados, o resto do ambiente (ferramentas, scripts, CLIs) deixa de ser utilizável para a maioria dos fluxos de trabalho; é a base do valor do sandbox.

**Independent Test**: Subir o contentor conforme documentação; verificar que os comandos de versão de PHP e Node reportam as séries major acordadas sem passos adicionais não documentados.

**Acceptance Scenarios**:

1. **Given** uma imagem construída pelo fluxo padrão do projecto, **When** o desenvolvedor abre uma shell de login no serviço de desenvolvimento, **Then** consegue executar PHP e Node com as versões major 8.4 e 22 respectivamente.
2. **Given** o mesmo contentor, **When** o desenvolvedor consulta a ferramenta de gestão de versões por defeito, **Then** vê PHP 8.4 e Node 22 como parte do conjunto de runtimes geridos por essa ferramenta (coerente com a configuração do projecto).

---

### User Story 2 - Gestão de versões integrada no ambiente (Priority: P2)

O desenvolvedor quer instalar ou alinhar outras versões de linguagens e ferramentas no futuro usando o mesmo mecanismo que o projecto já expõe por defeito, em vez de misturar instaladores ad-hoc.

**Why this priority**: Reduz deriva entre máquinas e documentação; suporta evolução do stack sem reescrever a imagem para cada bump menor.

**Independent Test**: Confirmar presença e funcionamento básico da ferramenta de gestão de versões no PATH do utilizador de desenvolvimento após arranque.

**Acceptance Scenarios**:

1. **Given** uma sessão no contentor de desenvolvimento, **When** o desenvolvedor invoca a ferramenta de gestão de versões acordada, **Then** o comando está disponível e responde de forma consistente (sem erro de «comando não encontrado»).

---

### User Story 3 - Clientes de IA disponíveis sem passo extra no `.env` (Priority: P3)

O desenvolvedor espera que os clientes de linha de comando de IA já referidos na documentação do repositório estejam instalados (ou aplicados no primeiro arranque de forma equivalente) no fluxo normal, sem ter de definir uma opção específica no `.env` apenas para permitir essa instalação.

**Why this priority**: Remove fricção de onboarding e evita que novos utilizadores ignorem ferramentas por desconhecerem a flag; alinha o comportamento ao pedido de «por defeito».

**Independent Test**: Construir e arrancar sem definir variáveis opcionais relacionadas com instalação de CLIs de IA; verificar que os executáveis documentados respondem a comandos de versão ou ajuda.

**Acceptance Scenarios**:

1. **Given** um `.env` criado a partir do modelo do projecto sem activar manualmente opções dedicadas à instalação de CLIs de IA, **When** o desenvolvedor entra no contentor após o fluxo padrão de build/up, **Then** os clientes de IA listados na documentação do projecto estão invocáveis na linha de comando.
2. **Given** o mesmo cenário, **When** um novo membro segue apenas o guia de início rápido, **Then** não existe requisito documentado de editar o `.env` unicamente para «ligar» a instalação desses clientes.

---

### Edge Cases

- **Build sem rede ou rede instável**: a instalação de runtimes ou pacotes remotos pode falhar; o comportamento esperado é falha clara no build ou no arranque, com mensagem acionável na documentação de resolução (rebuild, proxy, cache).
- **Conflito com ferramentas já presentes na imagem**: se existirem múltiplas fontes de Node/PHP, a versão por defeito na shell de login do utilizador de desenvolvimento deve ser a acordada (PHP 8.4, Node 22), sem exigir conhecimento interno da imagem.
- **Tamanho e tempo de build**: o utilizador aceita imagem mais pesada em troca de tudo pré-instalado; o projecto deve documentar o impacto qualitativo (tempo de primeira build) para expectativas realistas.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O ambiente de desenvolvimento containerizado MUST disponibilizar, por defeito na shell de trabalho do utilizador de desenvolvimento, uma ferramenta de gestão de versões de runtimes e ferramentas (conforme premissa: **mise**), invocável sem configuração manual ad hoc nessa primeira sessão.
- **FR-002**: O ambiente MUST disponibilizar **PHP na série major 8.4** como runtime por defeito para o utilizador de desenvolvimento, instalado e seleccionado de forma coerente com a ferramenta de gestão de versões (mise).
- **FR-003**: O ambiente MUST disponibilizar **Node na série major 22** como runtime por defeito para o utilizador de desenvolvimento, instalado e seleccionado de forma coerente com a ferramenta de gestão de versões (mise).
- **FR-004**: O conjunto de **clientes de linha de comando de IA** já documentados para este repositório MUST estar presente no fluxo padrão de utilização **sem** depender de variáveis opcionais no `.env` cujo único propósito seja activar essa instalação.
- **FR-005**: A documentação de arranque MUST reflectir o novo comportamento por defeito (mise, versões de PHP/Node, CLIs de IA sempre incluídos no caminho normal), incluindo nota sobre impacto em tamanho/tempo de build se aplicável.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: **Zero** passos documentados obrigatórios que exijam editar o `.env` apenas para permitir a instalação dos clientes de IA no fluxo padrão (comparado com o estado anterior em que uma flag opcional controlava isso).
- **SC-002**: Em verificação pós-arranque padronizada, **100%** das tentativas (amostra mínima definida no plano de testes, por exemplo 3 builds limpos) confirmam que os dois runtimes por defeito na shell de desenvolvimento correspondem às **séries major** definidas como alvo nas premissas desta especificação, sem comandos de instalação adicionais pelo utilizador.
- **SC-003**: **100%** dos clientes de IA listados na documentação do projecto respondem a um comando de verificação (versão ou ajuda) após o primeiro arranque válido, sem configuração extra no `.env` para esse fim.
- **SC-004**: Inquérito interno informal ou revisão de onboarding: desenvolvedores reportam que o tempo até «primeiro commit útil» no contentor **não piora** face à percepção anterior, **ou** a documentação explica explicitamente o trade-off de tempo de build aceite pela equipa.

## Assumptions

- A ferramenta de gestão de versões pedida pelo utilizador é **mise**; alternativas não foram solicitadas.
- «PHP 8.4» e «Node 22» referem-se às **séries major**; patches mínimos seguem a política de imagem do projecto (última patch estável disponível no momento do build, salvo pin explícito futuro).
- «Clientes de IA» corresponde ao conjunto actualmente descrito na documentação do repositório para CLIs de IA (incluindo, sem limitar, os fornecedores já referidos na documentação: Gemini, OpenCode, Qwen Code, Claude Code, Cursor Agent), mantendo-se a separação entre **instalação** (sempre por defeito) e **chaves/API** (podem continuar opcionais por ferramenta).
- O âmbito restringe-se ao **serviço de desenvolvimento** do Compose e à sua imagem/documentação; serviços `angie` e `ngrok` não são alvo desta especificação salvo impacto indirecto documentado.

## Dependencies

- Acesso de rede durante build para obter runtimes e pacotes (mise, PHP, Node, npm, instaladores externos das CLIs).
- Manutenção compatível entre mise e as versões pinadas de PHP e Node.
