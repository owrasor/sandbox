# Data Model (conceptual): `002-mise-php-node-ai-defaults`

Esta feature **não** introduz entidades persistentes em base de dados. Segue-se um **modelo conceptual de configuração** útil para contratos e tarefas de implementação.

## Entity: `DevImageRuntimePins`

Representa as versões de runtime que a imagem `dev` deve expor por defeito.

| Campo | Tipo (lógico) | Regras / notas |
|-------|----------------|----------------|
| `php_major_minor` | string | Deve satisfazer **8.4** (patch pela política de pin do build). |
| `node_major` | string | Deve satisfazer **22** (patch pela política de pin do build). |
| `version_manager` | enum | Valor fixo **mise** (pedido de produto). |

**Relações**: 1:N com `AiCliPackage` (Node/npm é prerequisito de parte do conjunto).

## Entity: `AiCliBundle`

Conjunto de ferramentas de linha de comando de IA que a imagem deve conter após build padrão.

| Campo | Tipo (lógico) | Regras / notas |
|-------|----------------|----------------|
| `packages` | lista de identificadores | Alinhada à documentação do repositório (npm global + instaladores curl onde aplicável). |
| `requires_env_toggle` | boolean | **DEVE** ser `false` para instalação (sem flag dedicada no `.env` só para instalar). |
| `api_keys_required_for_use` | boolean | Pode ser `true` por ferramenta; fora do âmbito de instalação (premissa da spec). |

**Validação**: Após build, cada item de `packages` deve responder a comando de verificação (`--version`, `--help`, ou equivalente documentado).

## Entity: `ComposeBuildContract` (referência)

Ligação entre orquestração e imagem.

| Campo | Tipo (lógico) | Regras / notas |
|-------|----------------|----------------|
| `service_name` | string | `dev`. |
| `build_context` | path | `./docker`. |
| `user_visible_runtimes` | lista | `php`, `node`, `mise` invocáveis em `zsh -l` como utilizador `dev`. |

## State transitions

Não aplicável (sem máquina de estados de domínio). O “estado” relevante é **imagem construída** vs **falha de build**, tratado em CI/manual QA.
