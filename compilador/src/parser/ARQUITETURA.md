# Analisador Sintático — Arquitetura

Este documento descreve o esqueleto do parser: como ele consome a lista de
tokens produzida pelo [lexer](../lexer/ARQUITETURA.md) e monta a **AST**
(Abstract Syntax Tree) que as fases seguintes do compilador vão usar.

## Visão geral

Enquanto o lexer trabalha **caractere a caractere**, o parser trabalha
**token a token**. Ele:

1. Recebe uma `Token[]` (incluindo `NEWLINE`, `INDENT`, `DEDENT`, `EOF`).
2. Usa **descida recursiva** para reconhecer a gramática da linguagem.
3. Devolve uma árvore de nós tipados (AST).

O padrão de organização é **idêntico ao do lexer**: uma classe central
([`Parser`](Parser.ts)) com cursor sobre os tokens, e parsers especializados
por tipo de statement (um arquivo por keyword estrutural).

## Estrutura de arquivos

```
compilador/src/parser/
├── Parser.ts                      # cursor + dispatch loop
├── ExpressionParser.ts            # parsing de expressões (precedência)
├── ast/
│   ├── Node.ts                    # Node base + Program
│   ├── Expressions.ts             # Literal, Identifier, BinaryOp, ...
│   └── Statements.ts              # If, While, Def, Return, ...
└── statements/
    ├── StatementParser.ts         # interface canParse/parse
    ├── IfParser.ts
    ├── WhileParser.ts
    ├── ForParser.ts
    ├── FunctionDefParser.ts
    ├── ReturnParser.ts
    ├── MatchParser.ts
    ├── TryParser.ts
    ├── ImportParser.ts
    └── SimpleStatementParser.ts   # break, pass, atribuições, expression stmts
```

## AST — o que o parser produz

Um nó da AST segue o contrato de [`Node`](ast/Node.ts):

```ts
interface Node {
  readonly kind: string;     // discriminador — "IfStatement", "BinaryOp", ...
  readonly line: number;
  readonly column: number;
}
```

Os nós são divididos em dois grupos:

- **Expressões** (`Expression`) em [ast/Expressions.ts](ast/Expressions.ts) —
  produzem um valor: `Literal`, `Identifier`, `BinaryOp`, `UnaryOp`, `Call`,
  `Attribute`, `Subscript`.
- **Statements** (`Statement`) em [ast/Statements.ts](ast/Statements.ts) —
  executam uma ação: `Assignment`, `ExpressionStatement`, `IfStatement`,
  `WhileStatement`, `ForStatement`, `FunctionDef`, `ReturnStatement`,
  `BreakStatement`, `PassStatement`, `MatchStatement`, `TryStatement`,
  `ImportStatement`.

A raiz é um `Program` — uma lista de `Statement`s de topo.

## Como o Parser funciona

O [`Parser`](Parser.ts) mantém:

- `pos` — índice do próximo token.
- Uma lista de `statementParsers`, um por tipo de statement.
- Uma instância de `ExpressionParser` (parsing de expressões é uma lógica
  diferente da de statements — precedência e associatividade).

### Métodos utilitários do cursor

| Método                    | O que faz                                                    |
|---------------------------|--------------------------------------------------------------|
| `peek(offset = 0)`        | olha um token à frente SEM consumir                          |
| `advance()`               | consome e devolve o token atual                              |
| `check(type, lexeme?)`    | true se o próximo token casa (sem consumir)                  |
| `match(type, lexeme?)`    | consome SE casar, devolve bool                               |
| `expect(type, lexeme?)`   | consome EXIGINDO casamento — lança erro se não casar         |
| `isAtEnd()`               | true se o próximo token é `EOF`                              |

Esses métodos são a "linguagem interna" que os statement parsers usam para
consumir tokens. Eles são o equivalente dos métodos do `Lexer`
(`peek`/`advance`/`match`) que os `Reader`s usam.

### Loop principal (`parse`)

```text
enquanto não for EOF:
    1. se o próximo token é NEWLINE sozinho → pular (linha em branco)
    2. achar o primeiro statementParser com canParse(token atual)
    3. se nenhum casar → erro sintático
    4. chamar sp.parse(this), empurrar o Statement resultante no body

devolver Program { body }
```

### parseBlock — consumo de blocos indentados

Todos os statements compostos (if, while, def, ...) têm um corpo delimitado
por `INDENT`/`DEDENT`. Em vez de cada parser reimplementar isso,
[`Parser.parseBlock()`](Parser.ts) centraliza:

```text
consumir NEWLINE
consumir INDENT
enquanto o próximo NÃO for DEDENT:
    parsear um statement (mesma lógica do loop principal)
consumir DEDENT
```

### parseExpression

Delegado para [`ExpressionParser`](ExpressionParser.ts), que implementa
**precedence climbing** (Pratt parsing). A cascata de precedência fica, da
mais fraca para a mais forte:

```
or  →  and  →  not  →  comparação  →  +/-  →  *//  →  unário  →  chamada  →  primário
```

Cada nível é uma função que chama a próxima mais apertada em loop e monta
`BinaryOp`/`UnaryOp` conforme encontra operadores do seu nível.

## Como cada StatementParser funciona

Todos implementam [`StatementParser`](statements/StatementParser.ts):

```ts
interface StatementParser {
  canParse(token: Token): boolean;
  parse(parser: Parser): Statement;
}
```

A convenção é igual à dos `Reader`s do lexer:

- `canParse` olha SEM consumir.
- `parse` avança o cursor do `Parser` e devolve o nó AST.
- Consome também o `NEWLINE`/`DEDENT` que fecha o statement.

### Resumo por parser

| Parser                    | Aceita           | Gramática simplificada                           |
|---------------------------|------------------|--------------------------------------------------|
| `IfParser`                | `if`             | `'if' expr ':' block ('elif' ...)? ('else' ...)?`|
| `WhileParser`             | `while`          | `'while' expr ':' block`                         |
| `ForParser`               | `for`            | `'for' ID 'in' expr ':' block`                   |
| `FunctionDefParser`       | `def`            | `'def' ID '(' params? ')' ':' block`             |
| `ReturnParser`            | `return`         | `'return' expr? NEWLINE`                         |
| `MatchParser`             | `match`          | `'match' expr ':' INDENT case+ DEDENT`           |
| `TryParser`               | `try`            | `'try' ':' block 'except' ':' block`             |
| `ImportParser`            | `import`         | `'import' ID ('as' ID)? NEWLINE`                 |
| `SimpleStatementParser`   | resto            | `break | pass | assignment | expr_stmt`         |

A ordem na lista importa: os keyword-gated vêm antes do
`SimpleStatementParser` (fallback para tudo que não é keyword estrutural).

## Exemplo de fluxo

Entrada:

```python
def f(x):
    return x + 1
```

Tokens produzidos pelo lexer (simplificado):

```
KEYWORD(def) IDENTIFIER(f) PUNCTUATION(() IDENTIFIER(x) PUNCTUATION())
PUNCTUATION(:) NEWLINE INDENT
KEYWORD(return) IDENTIFIER(x) OPERATOR(+) NUMBER(1) NEWLINE
DEDENT EOF
```

AST produzida pelo parser:

```
Program
 └── FunctionDef("f", params=[Identifier("x")])
      └── body:
           └── ReturnStatement
                └── BinaryOp("+")
                     ├── left:  Identifier("x")
                     └── right: Literal(1)
```

## Tratamento de erros

- **Token inesperado** no loop principal: nenhum `StatementParser` aceitou o
  token atual. Erro com `lexeme`, linha e coluna.
- **Casamento obrigatório falhou**: `expect()` lança com mensagem
  `Esperado X, encontrado Y em L:C`.
- Parsers individuais podem lançar erros mais específicos (ex.: `elif` sem
  `if` correspondente, `case` sem `match`).

## Como adicionar um novo tipo de statement

1. Adicionar a interface do nó em [ast/Statements.ts](ast/Statements.ts) e
   incluí-la na união `Statement`.
2. Criar um arquivo novo em [statements/](statements/) implementando
   `StatementParser`.
3. Registrar a instância no array `statementParsers` do
   [`Parser`](Parser.ts), respeitando a ordem (keyword-gated ANTES do
   `SimpleStatementParser`).

## Próximos passos

1. Implementar `Parser.parseBlock()` (consumo de `NEWLINE`/`INDENT`/`DEDENT`).
2. Implementar `ExpressionParser.parse()` com a cascata de precedência.
3. Implementar os 9 statement parsers (placeholders hoje).
4. Rodar contra os programas de teste em `compilador/src/tests/` e validar
   a AST produzida.
5. A partir da AST, partir para a **análise semântica** e depois para a
   **geração de código** (Python → JavaScript).
