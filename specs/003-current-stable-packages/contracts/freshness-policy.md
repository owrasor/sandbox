# Contract: Política de frescura

## Obrigatório

1. **Título e versão** da política (ex.: `version: 2026-04-06` ou semver).
2. **Definição de “estável”** por categoria de software (pacote de distribuição vs release upstream vs canal mise).
3. **Pelo menos três** entre: prazos máximos em dias, percentagem mínima de conformidade numa auditoria, cadência de reverificação, tempo máximo de vida de excepções.
4. **Processo de excepção**: aprovador, registo, data de revisão obrigatória.
5. **Procedimento de linha de base** (FR-006): como referenciar uma revisão da imagem ou um conjunto de versões para reprodução de incidentes.

## Opcional recomendado

- Matriz RACI para donos vs aprovadores.
- Ligação ao serviço Compose `dev` e ao `Dockerfile` (“fonte de verdade” técnica).

## Verificação

- Revisor confirma que nenhuma frase contradiz `spec.md` FR-001 / FR-003 / FR-006.
