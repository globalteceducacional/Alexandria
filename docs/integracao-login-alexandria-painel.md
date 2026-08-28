# Integração de login: Alexandria (app leitor) × Painel ADM Libare

**Data:** 2026-08-03  
**Origem:** app Flutter `alexandria`  
**Destinatário:** responsável pelo painel `adm-libares-new-main`  
**Objetivo:** alinhar por que o login do app não funciona com o painel novo e quais caminhos de integração existem.

---

## Resumo executivo

O **Alexandria** é o app **leitor** (contas em `tbl_users`, login por e-mail).  
O **painel novo** expõe login de **administrador** (`/api/v1/auth/login`, contas em `app_admin_users`, campo `username`).

Hoje o Alexandria aponta para o host do painel e chama o endpoint de **admin**. Por isso o login falha (HTTP 401), mesmo com e-mail/senha de leitor ou com mudanças só no formulário do app.

**Conclusão:** não é um bug de validação de campo no Flutter. É **mismatch de contrato/API e de tipo de usuário**.

---

## Como era antes (funcionava)

```
Alexandria (Flutter)
    → user_login_api.php          (email + password)
    → api.php?method_name=…       (home, livros, favoritos, etc.)
         ↓
   PHP legado + MySQL (tbl_users e demais tbl_*)
```

| Aspecto | Comportamento legado |
|--------|----------------------|
| Quem autentica | Leitor do app (`tbl_users`) |
| Credencial | **E-mail** + senha |
| Endpoint de login | `user_login_api.php` |
| Catálogo / listas | `api.php?method_name=…` |
| Formato de resposta | Envelope `EBOOK_APP` / campos tipo `success`, `user_id`, etc. |

Referência interna do app: entregas `8.5` / `8.7` do repositório Alexandria.

---

## Como está atualmente (quebrado)

```
Alexandria (Flutter)
    → POST /api/v1/auth/login     (username + password)
         ↓
   Backend Kotlin do painel
    → busca em usuários do PAINEL (app_admin_users)
    → NÃO consulta leitores (tbl_users)
```

Configuração atual do app (`.env`):

- `EBOOK_SITE_BASE_URL=https://admin.alenxandriaglobaltec.com/`
- Base API derivada: `{host}/api/v1`

No código do painel:

- `LoginRequest` exige **`username`** (não e-mail).
- `LoginUseCase` autentica **admin do painel**, não leitor.
- Comentário explícito em `CreateUserUseCase`: há **gap conhecido** no login do leitor (PHP legado vs hash BCrypt criado pelo painel).

| Tipo de conta no painel | Tabela | Serve para o app leitor? |
|-------------------------|--------|---------------------------|
| Admin / equipe do painel | `app_admin_users` | Não (é painel React) |
| Usuário / leitor | `tbl_users` | Sim — mas **não** há login de leitor pronto no Kotlin |

### Por que “trocar usuário por e-mail” no app não resolve

1. `/api/v1/auth/login` valida e usa o campo **`username`**.
2. Mesmo enviando e-mail, a busca continua na tabela de **admin**.
3. Contas criadas em **Usuários** no painel vão para `tbl_users` e **não entram** nesse endpoint.

---

## O que o painel novo já cobre vs o que falta para o app

| Capacidade | Status no `adm-libares-new-main` |
|------------|----------------------------------|
| Login JWT do painel admin | Pronto (`POST /api/v1/auth/login`) |
| CRUD / gestão de leitores (`tbl_users`) | Pronto (senhas em BCrypt) |
| APIs do **leitor** no Spring (`user_login_api.php`, `api.php`, perfil, etc.) | **Não implementado** (spec/plano existem; handoff indica implementação 0%) |
| Design aprovado do espelho PHP | `docs/superpowers/specs/2026-07-08-reader-api-php-mirror-design.md` |
| Plano / handoff | `docs/superpowers/plans/2026-07-08-reader-api-php-mirror.md` e `2026-07-09-reader-api-resume-handoff.md` |

Em outras palavras: o **painel administrativo** avançou; a **ponte para o Flutter** (API de leitor) ainda não.

---

## Opções de atualização / integração

### Opção A — Implementar API do leitor no Kotlin (caminho oficial do projeto)

Espelhar no Spring as rotas PHP do leitor (`/user_login_api.php`, `/api.php`, `/user_profile_*.php`, etc.), com o mesmo contrato (`EBOOK_APP`), conforme design já aprovado.

| | |
|--|--|
| **No Alexandria** | Em tese, só trocar o host (base URL) |
| **Prós** | Cutover limpo; permite desligar PHP; login por e-mail de novo; alinhado ao plano do painel |
| **Contras** | Esforço de backend (plano já escrito, ainda não executado) |
| **Recomendação** | **Preferencial** |

### Opção B — Alexandria voltar ao PHP legado (paliativo)

Restaurar no Flutter o cliente antigo apontando para o host que ainda serve `user_login_api.php` + `api.php`.

| | |
|--|--|
| **Prós** | App volta a autenticar leitores mais rápido |
| **Contras** | PHP continua no ar; risco de incompatibilidade de senha (painel grava BCrypt; PHP legado pode ainda comparar plaintext em alguns fluxos) |
| **Uso** | Ponte temporária até a Opção A |

### Opção C — Usar login admin dentro do app (não recomendado)

Testar com usuário do painel (ex.: local `admin` / `password` do README).

| | |
|--|--|
| **Prós** | Valida rede/host da API admin |
| **Contras** | Não autentica leitores reais; JWT/admin ≠ sessão de leitor; modelo errado para o produto |
| **Uso** | Apenas diagnóstico técnico |

### Opção D — API moderna só para o app (`/api/v1/reader/login`, etc.)

Novo contrato (e-mail + JWT de leitor + recursos REST).

| | |
|--|--|
| **Prós** | Modelo limpo a longo prazo |
| **Contras** | Exige reescrita maior no Flutter (mais esforço que A no curto prazo) |

---

## Pedido ao time do painel

1. Confirmar se a **Opção A** (espelho PHP no Kotlin) continua sendo a estratégia oficial.  
2. Informar **prazo / status** da implementação das rotas de leitor (`user_login_*`, `api.php`, …).  
3. Enquanto A não existir, indicar:
   - se o PHP legado de login/catálogo ainda está disponível em produção; e  
   - qual **base URL** o Alexandria deve usar nesse período (Opção B).  
4. Esclarecer comportamento de senha dos leitores criados no painel novo (BCrypt) vs login legado, para evitar falso “credenciais inválidas”.

---

## Contato / contexto técnico do app

- Repositório app: `alexandria`  
- Cliente atual: `lib/core/api/ebook_api_client.dart` → `POST …/api/v1/auth/login`  
- Config: `.env` → `EBOOK_SITE_BASE_URL`  

Dúvidas sobre o lado Flutter podem ser alinhadas com quem mantém o Alexandria; o bloqueio atual de login de **leitor** depende da API de leitor no backend do painel (ou do PHP legado ainda ativo).
