# Registro de evidências visuais (prints)

**Projeto:** Alexandria — Biblioteca Digital (Globaltec Educacional)  
**Objetivo:** Evitar **prints duplicados** entre entregas e deixar **explícito** quais entregáveis exigem capturas de tela.

---

## Convenção — entregáveis com prints

Quando um passo **exigir anexar prints** (capturas de tela) junto ao `.md`:

### 1. Título do documento (H1)

Incluir **`(prints)`** no final do título:

```markdown
# 8.4.4 — Passo 4: Protótipo de telas (prints)
```

### 2. Nome do arquivo

Incluir **`(prints)`** antes da extensão:

```
8.4.4-prototipo-telas (prints).md
```

### 3. Pasta das imagens

Salvar capturas em:

```
entregas/evidencias/{codigo}-{descricao}.jpeg
```

Exemplo: `entregas/evidencias/E-003-home-inicio.jpeg`

### 4. Numeração E-XXX

| Regra | Detalhe |
|-------|---------|
| Sequência | E-001, E-002, E-003… **sem pular** dentro da mesma entrega |
| Ordem | Códigos seguem o **fluxo do usuário** (não a ordem de captura no disco) |
| Novas telas | Próximo número livre (ex.: E-008 para Home com busca ativa) |

### 5. Corpo do documento

No início do `.md`, seção obrigatória:

```markdown
## Evidências visuais (prints)

| Código | Arquivo | Tela | Entrega |
|--------|---------|------|---------|
| E-001 | evidencias/E-001-splash.jpeg | Splash | 8.4.x |
```

---

## Registro atual (etapa 8.3)

| Código | Arquivo | Tela | Entrega | Status |
|--------|---------|------|---------|--------|
| E-001 | `E-001-splash.jpeg` | Splash | 8.3.4 | ✓ |
| E-002 | `E-002-login.jpeg` | Login | 8.3.4 | ✓ |
| E-003 | `E-003-home-inicio.jpeg` | Início | 8.3.4 | ✓ |
| E-004 | `E-004-explorar.jpeg` | Explorar | 8.3.4 | ✓ |
| E-005 | `E-005-perfil.jpeg` | Perfil | 8.3.4 | ✓ |
| E-006 | `E-006-detalhe-livro.jpeg` | Detalhe do livro | 8.3.4 | ✓ |
| E-007 | `E-007-leitor.jpeg` | Leitor | 8.3.4 | ✓ |
| E-008 | `E-008-config-perfil.jpeg` | Configurar perfil | 8.3.4 | ✓ |

> **Regra:** prints ficam **somente** em `8.3.4-prototipo-telas (prints).md`. A etapa **8.6** e demais referenciam E-XXX sem duplicar imagens.

---

## Entregas textuais (sem prints no nome do arquivo)

| Etapa | Tema |
|-------|------|
| **8.1** | Menu, perfis, permissões |
| **8.2** | Fluxos, regras, integrações |
| **8.3** | UX — prints **apenas** no passo 8.3.4 |
| **8.6** | Frontend — referencia prints da 8.3.4 |
| **8.9+** | Homologação — referencia E-XXX; sem novas capturas |

---

**Última atualização:** 09/07/2026 — E-001…E-008 capturados; etapas 8.9 e 8.10 documentadas
