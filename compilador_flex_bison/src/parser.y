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

/* -------------------------------------------------------------------------
 * Tokens (declarar aqui conforme o lexer for sendo implementado).
 * Exemplos:
 *   %token <sval> IDENTIFIER STRING
 *   %token <ival> INTEGER
 *   %token <fval> NUMBER
 *   %token LET CONST VAR FUNCTION RETURN IF ELSE WHILE FOR BREAK CONTINUE
 *   %token EQ NEQ SEQ SNEQ LE GE
 *   %token PLUS_ASSIGN MINUS_ASSIGN STAR_ASSIGN SLASH_ASSIGN
 *   %token ARROW
 * ------------------------------------------------------------------------- */


/* -------------------------------------------------------------------------
 * Precedencia e associatividade (exemplo, ajustar quando existir gramatica):
 *   %left  OR
 *   %left  AND
 *   %right '!'
 *   %left  EQ NEQ SEQ SNEQ '<' '>' LE GE
 *   %left  '+' '-'
 *   %left  '*' '/' '%'
 *   %right '='
 * ------------------------------------------------------------------------- */


%start program

%%

/* -------------------------------------------------------------------------
 * Gramatica (esqueleto).
 *
 * A regra inicial aceita, por enquanto, apenas um programa vazio. Conforme
 * o subconjunto de JavaScript suportado for definido, substituir por
 * producoes reais, por exemplo:
 *
 *   program
 *       : statement_list
 *       ;
 *
 *   statement_list
 *       : statement
 *       | statement_list statement
 *       ;
 *
 *   statement
 *       : var_decl
 *       | function_decl
 *       | if_stmt
 *       | while_stmt
 *       | return_stmt
 *       | expression_stmt
 *       ;
 *
 *   var_decl
 *       : LET IDENTIFIER '=' expression ';'
 *       ;
 *
 *   expression
 *       : expression '+' expression
 *       | expression '-' expression
 *       | primary
 *       ;
 *
 * Cada acao semantica devera construir o no da AST correspondente.
 * ------------------------------------------------------------------------- */

program
    : /* vazio - substituir pela producao real */
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
