# Feature Specification: Suporte Laravel no runtime PHP do contentor

**Feature Branch**: `006-laravel-php-mise-tooling`  
**Created**: 2026-04-06  
**Status**: Draft  
**Input**: User description: "instalar todos os pacotes do php 8.4, que está instalado no mise, que são necessários para uso do laravel. Instalar também o composer do php e o comando do laravel. Fazer isso tudo dentro da workspace do container, seguindo o que já foi feito para instalar o php 8.4"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Runtime PHP pronto para aplicações Laravel (Priority: P1)

Um desenvolvedor que trabalha no contentor de desenvolvimento precisa de executar e manter aplicações **Laravel** sem instalar manualmente extensões ou módulos do interpretador PHP que o framework exige para fluxos típicos (HTTP, base de dados, filas, cache, e-mail, etc.), usando o **PHP 8.4** já gerido pelo **mise** como no resto do projecto.

**Why this priority**: Sem o runtime completo, nem Composer nem o instalador Laravel resolvem o problema de fundo; a maior parte dos erros de onboarding aparece aqui.

**Independent Test**: Após build e arranque padronizados, verificar contra a lista de requisitos do Laravel para a versão major alvo que todas as extensões e definições necessárias estão satisfeitas pelo PHP activo na shell de desenvolvimento.

**Acceptance Scenarios**:

1. **Given** uma imagem construída pelo fluxo padrão do projecto, **When** o desenvolvedor executa o interpretador PHP por defeito na shell de trabalho, **Then** as extensões e capacidades exigidas pelo guia oficial de requisitos do Laravel para PHP estão disponíveis (sem instalação ad hoc nessa sessão).
2. **Given** um projecto Laravel de referência ou criado no contentor, **When** o desenvolvedor corre os comandos de consola habituais de manutenção (por exemplo migrações ou servidor de desenvolvimento), **Then** não falham por ausência de extensão PHP documentada como necessária para esse fluxo.

---

### User Story 2 - Composer disponível e alinhado ao PHP do projecto (Priority: P2)

O desenvolvedor precisa de instalar e actualizar dependências PHP dos projectos com **Composer**, usando o mesmo **PHP 8.4** (mise) que o resto do ambiente, sem configurar caminhos alternativos ao padrão do contentor.

**Why this priority**: Composer é o caminho standard para dependências Laravel; sem ele, o fluxo de trabalho diário quebra.

**Independent Test**: Invocar o Composer na shell de desenvolvimento e confirmar que reporta e utiliza o PHP esperado; executar uma operação de leitura (por exemplo `diagnose` ou `validate`) sem erro de ambiente.

**Acceptance Scenarios**:

1. **Given** uma sessão no contentor de desenvolvimento, **When** o desenvolvedor invoca o Composer, **Then** o executável está no PATH e responde com sucesso a um comando de verificação (versão ou diagnóstico).
2. **Given** o mesmo ambiente, **When** o desenvolvedor corre o Composer num projecto PHP, **Then** o binário PHP efectivo corresponde ao PHP 8.4 gerido pelo mise conforme política do repositório.

---

### User Story 3 - Criar novos projectos Laravel pela linha de comando (Priority: P3)

O desenvolvedor quer iniciar um novo projecto **Laravel** com o **comando `laravel`** (instalador oficial), sem sair do contentor nem instalar ferramentas globais por conta própria.

**Why this priority**: Reduz fricção de arranque de novos repositórios e alinha o sandbox ao ecossistema documentado do framework.

**Independent Test**: Executar o instalador com um comando de ajuda ou versão; opcionalmente criar um projecto em directório de trabalho temporário conforme guia de testes do plano.

**Acceptance Scenarios**:

1. **Given** uma sessão no contentor, **When** o desenvolvedor invoca o comando global do instalador Laravel documentado pelo projecto, **Then** o executável está disponível e não retorna «comando não encontrado».
2. **Given** permissões de escrita num directório de trabalho dentro do contentor, **When** o desenvolvedor segue o procedimento documentado para criar um novo projecto, **Then** a estrutura base esperada de um projecto Laravel é gerada sem exigir instalação manual prévia do instalador.

---

### Edge Cases

- **Build sem rede ou rede instável**: download de binários ou dependências do Composer pode falhar; o comportamento esperado é falha clara no build ou primeira utilização, com orientação na documentação (rebuild, proxy, cache).
- **Actualização dos requisitos do Laravel**: se o guia oficial alterar extensões obrigatórias, a lista verificável no plano de testes deve ser revista na mesma entrega ou numa tarefa de seguimento explícita.
- **Conflito com múltiplos PHP**: o PHP activo na shell de desenvolvimento para Composer e para aplicações MUST permanecer o 8.4 via mise, salvo documentação explícita de excepção.
- **Espaço em disco e tempo de build**: pacotes PHP adicionais aumentam imagem ou camadas; a documentação deve mencionar o trade-off qualitativo quando relevante.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: O **PHP 8.4** disponibilizado via **mise** no contentor de desenvolvimento MUST incluir todas as **extensões e definições de runtime** necessárias para cumprir os **requisitos oficiais de servidor** do **Laravel** para a versão major do framework adoptada como alvo neste repositório (incluindo capacidades usadas em fluxos típicos: base de dados relacional, filas, cache, e-mail, conforme guia de instalação).
- **FR-002**: O ambiente MUST disponibilizar o **Composer** (gestor de dependências PHP) globalmente acessível na shell de trabalho do utilizador de desenvolvimento, coerente com o PHP 8.4 do mise.
- **FR-003**: O ambiente MUST disponibilizar o **Laravel Installer** (comando **`laravel`** / fluxo equivalente documentado) para criação de novos projectos, acessível no PATH da shell de desenvolvimento.
- **FR-004**: A forma de instalar e activar estas capacidades MUST **seguir o mesmo padrão** já estabelecido no projecto para o PHP 8.4 com mise no **workspace do contentor** (artefactos versionados e fluxo de build documentado do repositório), sem depender de passos manuais não documentados por cada desenvolvedor.
- **FR-005**: A documentação de desenvolvimento MUST ser actualizada para descrever Composer, o instalador Laravel, e o conjunto de capacidades PHP relevantes para Laravel, incluindo como validar o ambiente após build.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em **três** builds limpos consecutivos (ou amostra equivalente definida no plano de testes), **100%** das verificações automatizadas ou manuais padronizadas confirmam que o PHP activo na shell de desenvolvimento satisfaz a **lista verificável** de requisitos do Laravel alvo (extensões e critérios do guia oficial), sem instalação manual adicional pelo testador.
- **SC-002**: Em **100%** das sessões de teste pós-arranque, o **Composer** responde a um comando de verificação (versão ou diagnóstico) e reporta uso do **PHP 8.4** alinhado ao mise.
- **SC-003**: Em **100%** das sessões de teste pós-arranque, o **comando do instalador Laravel** documentado está disponível e responde a verificação mínima (versão ou ajuda).
- **SC-004**: Um desenvolvedor que segue **apenas** a documentação actualizada consegue, em **≤ 30 minutos** (excluindo tempos de rede variáveis), completar o fluxo documentado «criar ou clonar projecto Laravel e executar comando de consola essencial» sem instalar extensões PHP ou ferramentas globais adicionais não previstas na especificação.

## Assumptions

- O PHP 8.4 continua a ser instalado e seleccionado via **mise**, como nas features anteriores do repositório; esta feature **estende** esse runtime, não substitui o mecanismo.
- «Pacotes do PHP» no pedido do utilizador interpreta-se como **extensões PHP** (e, se necessário, **pacotes de sistema** mínimos para as suportar) exigidas pelo Laravel, não como cada pacote opcional da distribuição Linux.
- A **versão major do Laravel** alvo para validar requisitos é a **estável actual** à data do plano de implementação, salvo pin explícito futuro na documentação do projecto.
- O **workspace do contentor** corresponde ao modelo já usado (código montado, utilizador de desenvolvimento, shell de login); ferramentas globais referem-se ao ambiente da imagem ou ao PATH padrão desse utilizador, conforme padrão existente.
- Chaves API, serviços externos (SMTP, S3, etc.) e bases de dados reais **não** fazem parte desta especificação além do necessário para verificar que o runtime e as extensões permitem essas integrações ao nível de cliente PHP.

## Dependencies

- Feature **002** (mise, PHP 8.4) e política de imagem **Ubuntu 24.04** já adoptada.
- Acesso de rede no build ou no primeiro uso para obter Composer, Laravel Installer e pacotes Composer quando aplicável.
- Compatibilidade entre versões do **Laravel Installer**, **Composer** e **PHP 8.4** na data da implementação.
