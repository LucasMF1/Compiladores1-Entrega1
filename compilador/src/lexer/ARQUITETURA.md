# Analisador Léxico — Arquitetura

Este documento descreve como o analisador léxico (lexer) funciona, qual é a
responsabilidade de cada arquivo e como novos tipos de token podem ser
adicionados no futuro.

## Visão geral

O lexer recebe o **código-fonte bruto** (uma `string`) e devolve uma **lista de
tokens**. Um token é a menor unidade sintática reconhecida pelo compilador —
por exemplo, a palavra `def`, o identificador `soma`, o número `3.14` ou o
operador `==`.

Em vez de usar uma única expressão regular gigante, a análise é feita
**caractere a caractere**, em uma **máquina de estados** onde cada estado é
representado por uma classe chamada `Reader`. A cada iteração, o `Lexer`
pergunta aos readers disponíveis "quem sabe ler o próximo caractere?" e delega
o trabalho ao reader certo.

### Por que máquina de estados?

- **Mensagens de erro com linha/coluna:** o cursor sabe exatamente onde está.
- **Extensibilidade:** adicionar suporte a comentários, indentação, f-strings
  ou números em hexadecimal vira "criar um novo Reader", sem tocar no resto.
- **Clareza:** cada classe cuida de UMA regra de formação de token. Mais fácil
  de testar, depurar e entender do que um regex monolítico.

## Estrutura de arquivos

```
compilador/src/lexer/
├── Lexer.ts                    # máquina de estados principal (cursor + loop)
├── Token.ts                    # representação de um token
├── TokenType.ts                # enum com os tipos possíveis
└── readers/
    ├── Reader.ts               # interface comum a todos os readers
    ├── IdentifierReader.ts     # identificadores + palavras reservadas
    ├── NumberReader.ts         # inteiros e floats
    ├── StringReader.ts         # "texto" e 'texto'
    ├── OperatorReader.ts       # =, ==, !=, +=, <, >, etc.
    └── PunctuationReader.ts    # ( ) [ ] { } , : .
```

## Modelo de token

Um `Token` carrega quatro informações:

| Campo    | Exemplo         | Para que serve                                     |
|----------|-----------------|----------------------------------------------------|
| `type`   | `KEYWORD`       | categoria sintática — usada pelo parser            |
| `lexeme` | `"def"`         | texto original que formou o token                  |
| `line`   | `3`             | linha onde o token começa (para mensagens de erro) |
| `column` | `5`             | coluna onde o token começa                         |

Os tipos possíveis estão em [TokenType.ts](TokenType.ts):

- `KEYWORD` — palavras reservadas (`def`, `if`, `while`, `return`, …)
- `IDENTIFIER` — nomes de variáveis, funções, parâmetros
- `NUMBER` — literais numéricos (inteiros ou floats)
- `STRING` — literais de string
- `OPERATOR` — operadores aritméticos, de comparação e de atribuição
- `PUNCTUATION` — parênteses, colchetes, chaves, vírgula, dois-pontos, ponto
- `NEWLINE` — fim de uma linha lógica (separador de instruções)
- `INDENT` — aumento no nível de indentação (abertura de bloco)
- `DEDENT` — redução no nível de indentação (fechamento de bloco)
- `EOF` — marcador de fim de arquivo, sempre o último da lista

## Como o Lexer funciona

O [`Lexer`](Lexer.ts) mantém cinco estados internos:

- `pos` — índice do próximo caractere a ser lido.
- `line` — linha atual (começa em 1).
- `column` — coluna atual (começa em 1).
- `indentStack` — pilha de níveis de indentação, em número de espaços.
  Começa em `[0]`.
- `atLineStart` — `true` quando estamos no início de uma linha lógica e ainda
  precisamos processar a indentação dela.

Além disso, tem uma lista de readers (um de cada tipo) e expõe métodos
utilitários que os readers consomem:

| Método                | O que faz                                                     |
|-----------------------|---------------------------------------------------------------|
| `peek(offset = 0)`    | retorna o caractere à frente SEM consumir                     |
| `advance()`           | consome o próximo caractere e atualiza `line`/`column`        |
| `match(expected)`     | consome o próximo caractere SÓ se ele for igual ao esperado   |
| `isAtEnd()`           | retorna true se chegamos ao fim da fonte                      |
| `getLine()`/`getColumn()` | leem a posição atual (úteis para os readers marcarem o início do token) |

### Loop principal (`tokenize`)

```text
enquanto não for fim do arquivo:
    1. se atLineStart → processar indentação (pode emitir INDENT/DEDENT)
    2. pular espaços/tabs INLINE (não afetam indentação)
    3. se o próximo caractere for '\n':
         emitir NEWLINE, consumir '\n', marcar atLineStart = true, continuar
    4. olhar o próximo caractere com peek()
    5. procurar o primeiro reader cujo canRead(char) retorne true
    6. se nenhum reader casar → erro léxico ("caractere inesperado")
    7. chamar reader.read(lexer), que consome e devolve um Token
    8. adicionar o token na lista

no final:
    - emitir um DEDENT para cada nível ainda aberto na indentStack
    - emitir EOF
    - retornar a lista
```

O ponto-chave é a **ordem dos readers**: o `Lexer` percorre a lista em ordem e
usa o primeiro que aceitar o caractere. Readers com condições mais específicas
devem vir antes dos mais genéricos (por exemplo, `StringReader` antes de
qualquer futuro reader que aceite aspas por outro motivo).

## Indentação: INDENT, DEDENT e NEWLINE

Python (diferente de C, JS, etc.) **não usa `{}` para delimitar blocos** — o
bloco é definido pela indentação. O lexer precisa traduzir essa estrutura
visual em tokens que o parser consiga consumir: `INDENT` quando um bloco abre,
`DEDENT` quando fecha, e `NEWLINE` para separar instruções.

### Onde essa lógica vive

Indentação NÃO é um `Reader`. Readers classificam caracteres; indentação
depende da *posição na linha*. Por isso a lógica fica dentro do próprio
`Lexer`, no método `handleIndentation`, chamado só no início de cada linha
lógica.

### Algoritmo

A cada início de linha:

1. Contar espaços/tabs na frente → `indent` atual.
2. Se a linha estiver vazia (ou for só comentário), **ignorar** — linhas em
   branco não mudam o nível.
3. Comparar `indent` com o topo da `indentStack`:
   - `indent > topo` → empilhar, emitir **um** `INDENT`.
   - `indent == topo` → nada a fazer.
   - `indent < topo` → desempilhar até encontrar um nível igual, emitindo **um
     `DEDENT` por pop**. Se nenhum nível na pilha bater com o atual, é erro
     léxico de "indentação inconsistente".

No EOF, a pilha ainda pode ter níveis abertos. O `tokenize` fecha todos com
`DEDENT`s antes de emitir o `EOF`.

### Exemplo

Entrada:

```python
if x:
    a = 1
    b = 2
c = 3
```

Tokens (apenas os estruturais destacados):

```
KEYWORD(if) IDENTIFIER(x) PUNCTUATION(:) NEWLINE
INDENT IDENTIFIER(a) OPERATOR(=) NUMBER(1) NEWLINE
       IDENTIFIER(b) OPERATOR(=) NUMBER(2) NEWLINE
DEDENT IDENTIFIER(c) OPERATOR(=) NUMBER(3) NEWLINE
EOF
```

O parser vê `INDENT` e sabe "abriu um bloco"; vê `DEDENT` e sabe "fechou".

## Como cada Reader funciona

Todos implementam a interface [`Reader`](readers/Reader.ts):

```ts
interface Reader {
  canRead(char: string): boolean;
  read(lexer: Lexer): Token;
}
```

A convenção é: **`canRead` não consome nada**, apenas olha. Quem avança o
cursor é o `read`, sempre usando os métodos do `Lexer`.

### IdentifierReader

- **Aceita:** caracteres que podem iniciar um identificador (letra ou `_`).
- **Consome:** letras, dígitos e underscores, enquanto houver.
- **Decide o tipo:** se o lexema final está no conjunto de palavras
  reservadas (`def`, `if`, `while`, …), emite `KEYWORD`; senão, `IDENTIFIER`.
- **Exemplo:** `soma` → `IDENTIFIER(soma)`, `return` → `KEYWORD(return)`.

### NumberReader

- **Aceita:** dígitos 0–9.
- **Consome:** todos os dígitos seguidos. Se encontrar `.` seguido de outro
  dígito, consome também a parte fracionária.
- **Cuidado:** um `.` sem dígito depois NÃO pertence ao número (ex.: em
  `obj.foo`, o ponto fica para o `PunctuationReader`).
- **Exemplo:** `42` → `NUMBER(42)`, `3.14` → `NUMBER(3.14)`.

### StringReader

- **Aceita:** aspas simples `'` ou aspas duplas `"`.
- **Consome:** a aspa de abertura, todo o conteúdo, e a **mesma** aspa de
  fechamento. Strings começadas com `"` só fecham com `"`, e vice-versa.
- **Erros:** se o arquivo terminar antes do fechamento, lança erro "string não
  terminada" apontando para a linha/coluna de abertura.
- **Exemplo:** `"ola"` → `STRING(ola)`.

### OperatorReader

- **Aceita:** `=`, `+`, `-`, `*`, `/`, `<`, `>`, `!`.
- **Consome com "maximal munch":** sempre prefere o operador mais longo. Se
  lê `=` e o próximo é `=`, junta os dois em `==`. Idem para `!=`, `<=`, `>=`,
  `+=`, `-=`, `*=`, `/=`.
- **Validação:** `!` sozinho não é operador válido em Python, então precisa
  necessariamente formar `!=`. Se não formar, é erro léxico.
- **Exemplo:** `==` → `OPERATOR(==)`, `+=` → `OPERATOR(+=)`.

### PunctuationReader

- **Aceita:** `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:`, `.`.
- **Consome:** exatamente um caractere. Sem combinações.
- **Exemplo:** `(` → `PUNCTUATION(()`.

## Fluxo de exemplo

Entrada:

```python
def soma(a, b):
    return a + b
```

Tokens produzidos (simplificado):

```
KEYWORD(def) @ 1:1
IDENTIFIER(soma) @ 1:5
PUNCTUATION(() @ 1:9
IDENTIFIER(a) @ 1:10
PUNCTUATION(,) @ 1:11
IDENTIFIER(b) @ 1:13
PUNCTUATION()) @ 1:14
PUNCTUATION(:) @ 1:15
KEYWORD(return) @ 2:5
IDENTIFIER(a) @ 2:12
OPERATOR(+) @ 2:14
IDENTIFIER(b) @ 2:16
EOF @ 2:17
```

## Tratamento de erros

Quando o `Lexer` encontra um caractere que nenhum reader reconhece, ele lança
uma exceção do tipo:

```
Caractere inesperado '<char>' em <linha>:<coluna>
```

Cada reader também pode lançar erros específicos — por exemplo,
`StringReader` lança para string não terminada, `OperatorReader` lança para
`!` sem `=` depois.

## Como adicionar um novo tipo de token

1. Adicionar a nova categoria no enum em [TokenType.ts](TokenType.ts) (se for
   realmente uma categoria nova — muitas vezes basta reutilizar uma existente).
2. Criar um novo arquivo em [readers/](readers/) implementando a interface
   `Reader`.
3. Registrar a instância do novo reader no array `readers` do
   [`Lexer`](Lexer.ts), na ordem correta de precedência.
4. Pronto — o loop principal já vai despachar para o reader novo.

## Próximos passos

1. Implementar cada um dos 5 readers (hoje são placeholders — `canRead`
   retorna `false` e `read` lança erro).
2. Escrever testes unitários por reader (casos felizes + erros).
3. Rodar contra os testes existentes em `compilador/src/tests/` e comparar com
   a saída esperada.
4. A partir da lista de tokens, construir o analisador sintático (próxima
   fase do compilador).
