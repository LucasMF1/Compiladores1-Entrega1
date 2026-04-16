# Sobre o Projeto

> Compilador JavaScript → Python | Disciplina de Compiladores 1 | PBL | Professor Sérgio Freitas.

---

## Visão Geral

O objetivo deste projeto é construir um **compilador** que recebe um programa escrito em um subconjunto de JavaScript e produz código Python equivalente e funcionalmente correto.

O projeto é desenvolvido no contexto da disciplina de **Compiladores 1**, aplicando a metodologia ágil **Scrum** com sprints semanais. Todas as decisões técnicas são documentadas e justificadas ao longo do desenvolvimento.

O fluxo completo do compilador é:

#### Pipeline de compilação

```
programa.js
    │
    ▼
┌─────────────┐
│  Flex/Lexer │  lê o texto e quebra em tokens
│  (lexer.l)  │  ex: "let x = 5" → [LET, ID("x"), ASSIGN, NUM(5)]
└─────────────┘
    │
    ▼ fluxo de tokens
┌─────────────┐
│    Bison    │  verifica a gramática e monta a árvore
│  (parser.y) │  ex: tokens → nó "declaração de variável"
└─────────────┘
    │
    ▼ AST (Árvore Sintática Abstrata)
┌─────────────┐
│  Gerador de │  percorre a árvore e escreve Python
│   código    │  ex: nó "declaração" → "x = 5"
└─────────────┘
    │
    ▼
programa.py
```

---

## Objetivo do Compilador

Traduzir programas escritos em um **subconjunto de JavaScript** para **Python** equivalente, cobrindo diversas insturções. As instrções imaginadas e abordadas no projeot, atualmente, são:

| Construção JS | Equivalente Python | Status |
|---|---|---|
| `let x = 5` / `const x = 5` | `x = 5` | ✅ Implementado |
| `if / else` | `if / else:` | 🔄 Em progresso |
| `while (cond)` | `while cond:` | 🔄 Em progresso |
| `for (let i = 0; i < n; i++)` | `for i in range(...)` | 🔄 Em progresso |
| `function nome(params)` | `def nome(params):` | 🔄 Em progresso |
| `console.log(x)` | `print(x)` | 🔄 Em progresso |
| Operadores aritméticos e lógicos | Equivalentes diretos | 🔄 Em progresso |

> Esta tabela será atualizada conforme o avanço das sprints.

---

## Tecnologias Utilizadas

### Linguagem principal
- **C** — implementação do driver, estruturas da AST e gerador de código

### Ferramentas de geração de compilador
- **Flex** — gerador de analisador léxico. Recebe um arquivo `.l` com expressões regulares e produz o código C do lexer automaticamente.
- **Bison** — gerador de analisador sintático. Recebe um arquivo `.y` com uma gramática livre de contexto e produz o parser LALR(1) em C.

### Infraestrutura
- **GitHub** — repositório, controle de versão e hospedagem da documentação
- **GitHub Pages** — site do projeto
- **Shell Script** — automação de build e testes (`build.sh`, `test.sh`)

---

## Estrutura do Repositório

```
compilador_flex_bison/
│
├── build.sh          # Compila tudo (verifica flex/bison instalados)
├── test.sh           # Roda o binário nos casos de teste
│
├── src/
│   ├── common.h      # Declarações compartilhadas (tokens, nós da AST)
│   ├── lexer.l       # Flex: análise léxica (tokens do JS)
│   ├── parser.y      # Bison: gramática + ações semânticas (construção da AST)
│   └── main.c        # Driver: abre o arquivo fonte e chama yyparse()
│
├── build/            # Artefatos gerados automaticamente
│   ├── parser.tab.c  # Código C do parser (gerado pelo Bison)
│   ├── parser.tab.h  # Cabeçalho do parser
│   ├── lexer.yy.c    # Código C do lexer (gerado pelo Flex)
│   └── compilador    # Binário final
│
├── tests/            # Casos de teste (.js de entrada + .py esperado)
│
└── docs/             # Documentação do projeto
    ├── paginas/
    ├── index.html
```

---

## Fases do Compilador

### 1. Análise Léxica (Flex) 
O arquivo `lexer.l` define as expressões regulares para todos os tokens suportados: palavras-reservadas (`let`, `const`, `if`, `else`, `while`, `for`, `function`, `return`), identificadores, literais numéricos e strings, operadores e delimitadores.

### 2. Análise Sintática (Bison) 
O arquivo `parser.y` define a gramática livre de contexto do subconjunto JavaScript suportado. O Bison gera um parser LALR(1) que consome o fluxo de tokens do Flex e constrói a **Árvore Sintática Abstrata (AST)**.

### 3. Análise Semântica 
Verificação de tipos, escopos e uso correto de variáveis e funções. A ser integrada na AST.

### 4. Geração de Código 
Percorre a AST e emite código Python equivalente. Será implementada em entrega posterior.

---

## Equipe

| Membro | Responsabilidade principal |
|---|---|
| Manuella Perlin | Análise léxica (Flex) |
| Otávio | Análise sintática (Bison) |
| João | Tabela de símbolos|
| Lucas freitas | Testes |
| Gabriel Fae | Documentação e integração |


---

## Metodologia

O projeto segue o **Scrum** com sprints semanais. O planejamento, as atas de reuniao e o progresso de cada sprint estao documentados em [`sprints`](./sprints.html).

Commits frequentes são feitos no GitHub ao longo de cada sprint, refletindo o progresso incremental do projeto.

---

## Links Úteis

-  [Repositório no GitHub](https://github.com/LucasMF1/Compiladores1-Entrega1)
-  [Planejamento das Sprints](./sprints.html)
-  [Decisoes Tecnicas](./decisoes-tecnicas.html)
-  [Problemas e Solucoes](./problemas-solucoes.html)

---


### Tabela de atualizações

| Versão | Data | Descrição | Autor | Revisor |
| :--- | :--- | :--- | :--- | :--- |
| `1.0`    | 16/04/2026 | Criação da página e adição de informações principaius | [Gabriel Fae](https://github.com/faehzin)|  | 
