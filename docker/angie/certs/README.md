# Certificados TLS para o Angie (local)

**Não commits** ficheiros `.pem` nem chaves privadas — estão no `.gitignore`.

## Nomes esperados pelo exemplo

O virtual host em `sites/example-app.test.conf` usa:

| Ficheiro no contentor (montado a partir desta pasta) | Função        |
|------------------------------------------------------|---------------|
| `example-app.test.pem`                               | Certificado   |
| `example-app.test-key.pem`                           | Chave privada |

## Gerar com mkcert (recomendado)

No **host** (fora do contentor):

```bash
mkcert -install
cd /caminho/para/o/repo/docker/angie/certs
mkcert -cert-file example-app.test.pem -key-file example-app.test-key.pem example-app.test "*.test" localhost 127.0.0.1 ::1
```

Ajusta o `cd` para o teu clone (ex.: `docker/angie/certs` na raiz do repositório).

Se gerares com `mkcert "*.test"` sem `-cert-file`, renomeia ou cria symlinks para coincidir com os nomes acima.

## Verificação

Com o volume montado, o Angie deve conseguir ler os PEM em `/etc/angie/certs/` dentro do contentor.
