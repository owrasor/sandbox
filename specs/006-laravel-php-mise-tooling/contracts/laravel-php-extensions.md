# Contract: extensões PHP vs Laravel 12.x (Server Requirements)

**Feature**: `006-laravel-php-mise-tooling`  
**Fonte**: [Laravel 12.x — Server Requirements](https://laravel.com/docs/12.x/deployment#server-requirements) (snapshot de alinhamento: 2026-04-06)

## Requisito de versão

- **PHP**: >= 8.2 (ambiente alvo do repositório: **8.4.x** via mise)

## Mapa documentação → verificação (`php -m`)

A documentação lista capacidades; na prática verificam-se com `php -m` / extensões embutidas no Core:

| Documentação Laravel | Verificação mínima na imagem |
|----------------------|------------------------------|
| Ctype | módulo `ctype` |
| cURL | módulo `curl` |
| DOM | módulo `dom` |
| Fileinfo | módulo `fileinfo` |
| Filter | módulo `filter` |
| Hash | módulo `hash` |
| Mbstring | módulo `mbstring` |
| OpenSSL | módulo `openssl` |
| PCRE | motor incluído no Core (sem linha separada — aceitar `pcre` se listado ou Core presente) |
| PDO | módulo `PDO` |
| Session | módulo `session` |
| Tokenizer | módulo `tokenizer` |
| XML | módulos `xml` e, na prática, `libxml` / `dom` / `SimpleXML` conforme build |

## Comando canónico de verificação

```bash
php -r '$need=["ctype","curl","dom","fileinfo","filter","hash","mbstring","openssl","pdo","session","tokenizer","xml"]; foreach($need as $e){ echo $e,": ",extension_loaded($e)?"ok":"MISSING","\n"; }'
```

Exit code **0** esperado; nenhuma linha `MISSING`.

## Extensões adicionais recomendadas (fluxos típicos, não listadas como mínimo absoluto)

Para desenvolvimento local com bases de dados comuns:

- `pdo_mysql`, `pdo_sqlite` (e, se aplicável, `pdo_pgsql`)

Estas **devem** permanecer disponíveis se já fazem parte do runtime mise actual, pois suportam cenários de aceitação da spec (migrações, drivers).
