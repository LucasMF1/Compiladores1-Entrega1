/*
 * ===========================================================================
 * common.h  --  Declaracoes compartilhadas entre lexer, parser e driver
 * ===========================================================================
 *
 * Objetivo:
 *   Concentrar includes e prototipos usados por mais de um modulo do
 *   compilador JavaScript -> Python. Assim, tanto o codigo gerado pelo
 *   Flex (lexer.l) quanto o gerado pelo Bison (parser.y) e o driver
 *   (main.c) podem enxergar os mesmos simbolos.
 *
 * O que deve ser adicionado aqui no futuro:
 *   - O tipo (struct) da AST e seus construtores.
 *   - Tabela de simbolos / escopos, caso seja mantida global.
 *   - Utilitarios de log/erro reutilizaveis.
 * ===========================================================================
 */

#ifndef COMPILADOR_COMMON_H
#define COMPILADOR_COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Variaveis fornecidas pelo Flex/Bison. */
extern int   yylineno;
extern int   yycolumn;
extern char *yytext;
extern FILE *yyin;

/* Funcoes geradas pelo Flex/Bison. */
int  yylex(void);
int  yyparse(void);

/* Tratamento de erros - implementadas em parser.y. */
void yyerror(const char *msg);
void lex_error(const char *lexeme, int line, int column);

#endif /* COMPILADOR_COMMON_H */
