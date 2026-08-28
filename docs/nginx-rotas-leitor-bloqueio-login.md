# Bloqueio do login do Alexandria: nginx não encaminha as rotas do leitor

**Data:** 2026-08-06  
**Para:** time do painel (`adm-libares-new-main`)  
**De:** time Alexandria (app Flutter)  
**Host:** `https://admin.alenxandriaglobaltec.com`

---

## Em uma frase

O código Kotlin do login do **leitor** já existe; no servidor o pedido **não chega no Spring** porque o **nginx do frontend** não faz proxy das rotas do app.

---

## Contexto

O Alexandria (app leitor) precisa destas rotas (espelho PHP no Kotlin — Opção A):

| Rota | Uso |
|------|-----|
| `/user_login_api.php` | Login com **e-mail** + senha (`tbl_users`) |
| `/api.php?method_name=…` | Home, livros, categorias, etc. |
| `/user_profile_api.php` (e correlatas) | Perfil / update |

Resposta esperada: JSON com envelope **`EBOOK_APP`**.

Isso **não** é o login do painel admin (`POST /api/v1/auth/login` com `username`).

---

## O que já está pronto no backend

No repositório novo (`adm-libares-new-main`) já existem, entre outros:

- `UserLoginController` → `/user_login_api.php`
- `ApiPhpController` → `/api.php`
- Controllers de perfil / register / forgot
- `SecurityConfig` com `permitAll` nessas rotas

Ou seja: a implementação Kotlin da Opção A está no código. O gap atual é de **exposição no servidor**.

---

## O problema (nginx)

Arquivo: `frontend-admin/nginx.conf`

Hoje o nginx encaminha para o Spring basicamente:

- `/api/` (API admin)
- `/legacy/assets/`
- `/api_sites.php`
- health / swagger

**Não encaminha:**

- `/user_login_api.php`
- `/api.php`
- `/user_register_api.php`
- `/user_forgot_pass_api.php`
- `/user_profile_api.php`
- `/user_profile_update_api.php`
- (e variantes como `user_register_galileu.php`)

Esses pedidos caem no `location /` do **React (SPA)** e voltam **HTML** da tela do painel — não JSON da API.

### Analogia

Nginx = porteiro.  
Spring = API.  
React = página do painel.

O porteiro só manda “admin” e “api_sites” para a API. Pedidos do app leitor vão para a página do painel.

---

## Evidência no servidor (smoke atual)

| URL | Resultado observado |
|-----|---------------------|
| `/actuator/health` | OK |
| `/api_sites.php` | OK (JSON `Galileu`) |
| `/api/v1/auth/login` | OK como **admin** |
| `/user_login_api.php` | HTML do React / POST 405 |
| `/api.php?method_name=home` | HTML do React |

---

## O que o time do painel precisa fazer

### 1. Atualizar `frontend-admin/nginx.conf`

Adicionar `location` com `proxy_pass` para o `backend:8080`, no **mesmo padrão** do `api_sites.php`, **antes** do `location /` do SPA. Exemplo:

```nginx
location = /api.php {
    proxy_pass http://backend:8080/api.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /user_login_api.php {
    proxy_pass http://backend:8080/user_login_api.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /user_register_api.php {
    proxy_pass http://backend:8080/user_register_api.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /user_register_galileu.php {
    proxy_pass http://backend:8080/user_register_galileu.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /user_forgot_pass_api.php {
    proxy_pass http://backend:8080/user_forgot_pass_api.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /user_profile_api.php {
    proxy_pass http://backend:8080/user_profile_api.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

location = /user_profile_update_api.php {
    proxy_pass http://backend:8080/user_profile_update_api.php;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

> Importante: essas rules precisam ficar **acima** do bloco SPA (`location / { try_files ... }`).

### 2. Rebuild / redeploy do frontend

Para o container nginx passar a usar o conf novo.

### 3. Confirmar que o backend em produção é o build com `modules/reader`

Sem esse módulo, mesmo com proxy correto as rotas não existirão no Spring.

### 4. Smoke de aceite

Deve retornar **JSON** com `EBOOK_APP` (não HTML do painel):

```text
https://admin.alenxandriaglobaltec.com/user_login_api.php?email=EMAIL&password=SENHA&type=Normal
https://admin.alenxandriaglobaltec.com/api.php?method_name=home
```

---

## O que o Alexandria faz depois (lado app)

Quando o smoke acima passar:

1. Parar de usar `POST /api/v1/auth/login` (isso é login de **admin**).
2. Voltar o cliente para:
   - login → `user_login_api.php` (`email` + `password` + `type=Normal`)
   - catálogo → `api.php?method_name=…`
3. Manter `EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/`

Enquanto o nginx não estiver corrigido, mudar só o app **não resolve**.

---

## Opcional: rotas limpas (sem `.php`)

O sufixo `.php` era só **compatibilidade** com o legado (Opção A: app só troca o host).

Como o repositório **Alexandria** também será compartilhado com o time do painel, é **opcional** criar rotas mais corretas no Kotlin, por exemplo:

| Legado (espelho) | Exemplo limpo (opcional) |
|------------------|---------------------------|
| `/user_login_api.php` | `/api/v1/reader/login` |
| `/api.php?method_name=home` | `/api/v1/reader/home` (ou recursos REST) |
| `/user_profile_api.php` | `/api/v1/reader/me` |

### Se escolher esse caminho

1. Backend: expor as rotas novas (login de **leitor** em `tbl_users` + e-mail — **não** reutilizar `/api/v1/auth/login` de admin).
2. Nginx: proxyar o prefixo novo (ex.: `location /api/v1/reader/` → Spring). Se ficar sob `/api/`, o `location /api/` atual já pode cobrir.
3. Alexandria: apontar o cliente para esses paths e combinar o contrato (body + formato da resposta).
4. Documentar o contrato acordado (URL, campos, JSON de sucesso/erro).

### Comparativo rápido

| | Espelho `.php` (padrão do doc) | Rotas limpas (opcional) |
|--|--------------------------------|-------------------------|
| Paths | `/user_login_api.php`, `/api.php` | `/api/v1/reader/...` |
| Esforço | Menor no app se o contrato legado for mantido | Backend **e** Alexandria juntos |
| Resultado | Compatível com o plano Opção A | API mais clara a longo prazo |

**Não é obrigatório** para desbloquear o login. O bloqueio imediato continua sendo: nginx (e deploy) fazendo a API do leitor responder JSON no host admin — seja com `.php` ou com paths limpos.

---

## Resumo para ação

| Quem | Ação |
|------|------|
| Painel / ops | Proxy no `nginx.conf` + deploy (paths `.php` **ou** prefixo limpo, se adotarem o opcional) |
| Painel / ops | Validar smoke no host admin (JSON de leitor, não HTML do painel) |
| Alexandria | Adaptar cliente para as rotas acordadas **depois** do smoke OK |
| Opcional | Time painel + Alexandria: rotas sem `.php` (`/api/v1/reader/...`) se forem alterar os dois lados |

---

## Referências

- Pedido original: `alexandria/docs/integracao-login-alexandria-painel.md`
- Resposta painel (Opção A): `adm-libares-new-main/docs/superpowers/specs/2026-08-03-alexandria-login-integration-response.md`
- Cutover: `adm-libares-new-main/docs/superpowers/plans/2026-08-04-reader-api-cutover-checklist.md`
- Nginx atual: `adm-libares-new-main/frontend-admin/nginx.conf`
