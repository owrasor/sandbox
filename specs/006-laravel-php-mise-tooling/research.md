# Research: Suporte Laravel no runtime PHP (006-laravel-php-mise-tooling)

**Data**: 2026-04-06

## 1. Fonte de verdade dos requisitos PHP do Laravel

**Decision**: Usar a secção **Server Requirements** da documentação oficial **Laravel 12.x** — [Deployment → Server Requirements](https://laravel.com/docs/12.x/deployment#server-requirements) (consultada em 2026-04-06).

**Lista mínima (documentação)**:

- PHP >= 8.2  
- Extensões: Ctype, cURL, DOM, Fileinfo, Filter, Hash, Mbstring, OpenSSL, PCRE, PDO, Session, Tokenizer, XML  

**Rationale**: Alinha FR-001 da spec à versão major estável actual do framework; a spec assume «versão major estável à data do plano».

**Alternatives considered**:

- **Laravel 11.x docs**: Rejeitado como primário — 12.x é a linha documentada como actual no mesmo corte temporal; se o projecto pinar 11.x, actualizar apenas a referência de URL e revalidar (requisitos de extensões são equivalentes na prática).
- **Apenas «o que o projeto precisa» sem doc oficial**: Rejeitado — quebra testabilidade e auditoria (SC-001 exige lista verificável).

## 2. Estado observado da imagem `dev` (PHP mise)

**Decision**: Tratar a imagem **actual** como **já conforme** com a lista mínima de extensões do Laravel 12.x, com base num inventário obtido com:

`docker compose run --rm dev bash -lc 'php -m'`

**Rationale**: Em 2026-04-06 o output inclui, entre outras: `ctype`, `curl`, `dom`, `fileinfo`, `filter`, `hash`, `mbstring`, `openssl`, `pdo`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `session`, `tokenizer`, `xml`, `xmlreader`, `xmlwriter`, `SimpleXML`, `json`, `zip`, `bcmath`, `intl`, `gd`, etc. Isto cobre explicitamente os requisitos mínimos da documentação.

**Implicação para implementação**: O trabalho principal **não** é recompilar PHP por defeito, mas **(a)** manter/validar essa conformidade de forma **repetível** (contrato + possível script ou checklist), **(b)** entregar Composer/`laravel` conforme FR-002/FR-003, **(c)** documentar e registar no inventário.

**Alternatives considered**:

- **Forçar reinstalação PHP com flags extra**: Desnecessário se `php -m` já cumpre; reservado para regressões futuras ou se uma extensão for removida upstream no binário mise.
- **Instalar pacotes `php8.4-*` do Ubuntu em paralelo**: Rejeitado — duplica interpretadores e quebra o princípio «um PHP via mise» salvo excepção documentada.

## 3. Composer

**Decision**: Considerar **Composer satisfeito** quando o binário do **prefixo PHP do mise** está no PATH da shell de login (já configurado em `/etc/profile.d/mise-system-runtimes.sh` e `/etc/zsh/zprofile`). Na imagem observada: `composer` em `/usr/local/share/mise/installs/php/8.4.x/bin/composer`, versão **2.9.5**, a usar PHP **8.4.19**.

**Rationale**: Cumpre FR-002 sem duplicar canal de instalação; coerente com «seguir o que já foi feito para PHP 8.4».

**Melhoria recomendada**: O `composer diagnose` reporta **ausência de `unzip`** (e opcionalmente 7z). **Decision**: Adicionar o pacote **`unzip`** via `apt-get` no `Dockerfile` para suportar extração de pacotes e limpar avisos de diagnóstico.

**Alternatives considered**:

- **Instalador oficial getcomposer.org em `/usr/local/bin/composer`**: Possível mas redundante se o binário mise já existe e está actualizado; aumenta dois canais de actualização.
- **`mise install composer`**: Pode ser alternativa futura para unificar versionamento; fora de escopo mínimo se o Composer do prefixo PHP cumprir FR-002.

## 4. Laravel Installer (`laravel`)

**Decision**: Instalar o **Laravel Installer** com **Composer global** num **`COMPOSER_HOME`** partilhado (ex.: `/usr/local/share/composer`), durante passo `RUN` **como root** antes de `USER dev`, e expor o executável em **`/usr/local/bin/laravel`** (symlink ao `vendor/bin/laravel`).

**Rationale**: É o método oficial documentado pela comunidade Laravel; garante `laravel` no PATH para todos os utilizadores; evita depender de `~/.config/composer` do utilizador `dev` (que pode variar com volumes).

**Alternatives considered**:

- **Apenas `composer create-project`**: Cumpre criação de projectos mas **não** cumpre FR-003 literal (comando `laravel`).
- **Phar descarregado manualmente**: Mais passos de verificação de integridade; Composer global é mais idiomático.

## 5. Compatibilidade de versões

**Decision**: Aceitar as versões **patch** de PHP 8.4 e Composer **resolvidas pelo mise / Packagist** no momento do build; documentar no inventário as versões **observadas** após merge.

**Rationale**: A spec fixa **séries major** (PHP 8.4); pins finos podem seguir a política de «última patch estável» do repo.

**Alternatives considered**:

- **Pin explícito de versão do pacote `laravel/installer`** no `composer global require`: Opcional para builds mais reprodutíveis; pode ser tarefa de implementação.

## Resolução de NEEDS CLARIFICATION

Não havia marcadores NEEDS CLARIFICATION pendentes no contexto técnico após cruzar spec, documentação Laravel 12.x e observação da imagem; decisões acima fecham o desenho para implementação e testes.
