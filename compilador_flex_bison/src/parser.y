/*
 * ===========================================================================
 * parser.y  --  Template do analisador sintatico (Bison)
 * ===========================================================================
 *
 * Objetivo do projeto:
 *   Compilador de JavaScript para Python. Este arquivo define a gramatica
 *   do subconjunto de JavaScript aceito e, a partir dela, constroi a arvore
 *   sintatica (AST) que sera usada pela fase de geracao de codigo Python.
 *
 * O que precisa ser feito aqui:
 *   1. Declarar todos os tokens terminais que o lexer (lexer.l) vai
 *      devolver: palavras-chave (LET, CONST, FUNCTION, IF, ELSE, FOR, ...),
 *      IDENTIFIER, NUMBER, STRING, operadores compostos (EQ, NEQ, SEQ,
 *      SNEQ, PLUS_ASSIGN, ...) e quaisquer outros necessarios.
 *   2. Declarar precedencia e associatividade dos operadores (%left, %right)
 *      para resolver ambiguidades em expressoes aritmeticas/logicas.
 *   3. Escrever as producoes da gramatica cobrindo:
 *        - declaracoes: let/const/var
 *        - definicao de funcoes (function e arrow functions, se escolhido)
 *        - comandos: if/else, while, for, return, break, continue
 *        - expressoes: aritmeticas, logicas, de comparacao, chamadas de
 *          funcao, acessos a propriedade, literais de array/objeto
 *   4. Em cada acao semantica ({ ... }), construir o no correspondente da
 *      AST e propagar via $$ = ...; A AST sera consumida em uma etapa
 *      posterior para gerar o codigo Python equivalente.
 *   5. Implementar yyerror() para reportar erros sintaticos com posicao.
 *
 * Integracao:
 *   - bison -d parser.y  ->  gera parser.tab.c e parser.tab.h
 *   - O header e incluido em lexer.l para que as regras retornem os
 *     codigos de token corretos.
 *   - main.c chama yyparse() que roda o loop lexer <-> parser.
 * ===========================================================================
 */

%{
#include "common.h"
%}

%locations
%define parse.error verbose

/* -------------------------------------------------------------------------
 * Tipos semanticos dos tokens e nao-terminais.
 * Adicionar aqui um ponteiro para o tipo do no da AST quando ela existir,
 * por exemplo:
 *     struct AstNode *node;
 * ------------------------------------------------------------------------- */
%union {
    int     ival;
    double  fval;
    char   *sval;
    /* struct AstNode *node;   <- adicionar com a AST */
}

/* Tokens com valor semantico (lexer preenche yylval). */
%token <sval> IDENTIFIER STRING TEMPLATE_STRING
%token <fval> NUMBER

/* Palavras-chave. */
%token LET CONST VAR FUNCTION RETURN
%token IF ELSE WHILE DO FOR BREAK CONTINUE
%token SWITCH CASE DEFAULT TRY CATCH FINALLY THROW
%token CLASS EXTENDS IMPORT FROM EXPORT NEW THIS
%token IN OF INSTANCEOF TYPEOF VOID_TOK DELETE
%token ASYNC AWAIT
%token TRUE_TOK FALSE_TOK NULL_TOK UNDEFINED_TOK

/* Operadores compostos. */
%token EQ NEQ STRICT_EQ STRICT_NEQ LE GE
%token AND OR SHL SHR INCREMENT DECREMENT
%token PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token ARROW

/* Operadores simples. */
%token ASSIGN PLUS MINUS TIMES DIVIDE MOD
%token NOT LT GT BIT_AND BIT_OR BIT_XOR BIT_NOT

/* Pontuacao. */
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token COMMA SEMI COLON DOT QUESTION


/* Precedencia e associatividade. Linhas posteriores ligam mais forte.
 * UMINUS e um token ficticio usado apenas via %prec para dar a precedencia
 * do menos unario. */
%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIV_ASSIGN MOD_ASSIGN
%left  OR
%left  AND
%left  BIT_OR
%left  BIT_XOR
%left  BIT_AND
%left  EQ NEQ STRICT_EQ STRICT_NEQ
%left  LT GT LE GE
%left  SHL SHR
%left  PLUS MINUS
%left  TIMES DIVIDE MOD
%right NOT BIT_NOT UMINUS

%start program

%%

program
    : stmt_list                                 { /* TODO AST: raiz */ }
    ;

stmt_list
    : /* vazio */
    | stmt_list statement
    ;

statement
    : var_decl
    | expr_stmt
    | block
    | SEMI                                      /* statement vazio */
    ;

block
    : LBRACE stmt_list RBRACE
    ;

var_decl
    : LET   IDENTIFIER ASSIGN expression SEMI   { free($2); }
    | CONST IDENTIFIER ASSIGN expression SEMI   { free($2); }
    | VAR   IDENTIFIER ASSIGN expression SEMI   { free($2); }
    | LET   IDENTIFIER SEMI                     { free($2); }
    | VAR   IDENTIFIER SEMI                     { free($2); }
    ;

expr_stmt
    : expression SEMI
    ;

expression
    : expression PLUS       expression          { /* TODO AST: + */ }
    | expression MINUS      expression          { /* TODO AST: - */ }
    | expression TIMES      expression          { /* TODO AST: * */ }
    | expression DIVIDE     expression          { /* TODO AST: / */ }
    | expression MOD        expression          { /* TODO AST: % */ }
    | expression EQ         expression          { /* TODO AST: == */ }
    | expression NEQ        expression          { /* TODO AST: != */ }
    | expression STRICT_EQ  expression          { /* TODO AST: === */ }
    | expression STRICT_NEQ expression          { /* TODO AST: !== */ }
    | expression LT         expression          { /* TODO AST: < */ }
    | expression GT         expression          { /* TODO AST: > */ }
    | expression LE         expression          { /* TODO AST: <= */ }
    | expression GE         expression          { /* TODO AST: >= */ }
    | expression AND        expression          { /* TODO AST: && */ }
    | expression OR         expression          { /* TODO AST: || */ }
    | MINUS expression  %prec UMINUS            { /* TODO AST: unario - */ }
    | NOT   expression                          { /* TODO AST: ! */ }
    | IDENTIFIER ASSIGN expression              { free($1); }
    | primary
    ;

primary
    : IDENTIFIER                                { free($1); }
    | NUMBER
    | STRING                                    { free($1); }
    | TRUE_TOK
    | FALSE_TOK
    | NULL_TOK
    | UNDEFINED_TOK
    | LPAREN expression RPAREN
    ;

%%

/*
 * Tratamento de erros sintaticos. Deve ser refinado para mostrar contexto
 * util (trecho do arquivo, sugestoes, etc.) quando a gramatica estiver
 * completa.
 */
void yyerror(const char *msg) {
    fprintf(stderr, "Erro sintatico na linha %d, coluna %d: %s\n",
            yylloc.first_line, yylloc.first_column, msg);
}

/*
 * Reporta tokens nao reconhecidos pelo lexer. Chamado a partir de lexer.l
 * quando nenhuma regra casa com a entrada.
 */
void lex_error(const char *lexeme, int line, int column) {
    fprintf(stderr, "Token invalido \"%s\" na linha %d, coluna %d\n",
            lexeme, line, column);
}
