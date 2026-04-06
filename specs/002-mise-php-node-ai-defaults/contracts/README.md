# Contracts — Imagem `dev` + mise (`002-mise-php-node-ai-defaults`)

Contratos da feature: superfícies entre **operadores**, **Docker Compose** e **imagem de desenvolvimento**. Formato: Markdown neste diretório.

| Ficheiro | Escopo |
|----------|--------|
| `compose-dev-service.md` | Serviço `dev`: build, args, env_file, volumes, comportamento esperado pós-mudança. |
| `docker-dev-image.md` | Dockerfile e scripts: mise, pins PHP/Node, instalação das CLIs de IA. |
| `tool-versions.md` | Versões lógicas aceites (major/minor) e verificação. |

Implementação deve manter estes contratos ou atualizar o contract + `plan.md` em conjunto.
