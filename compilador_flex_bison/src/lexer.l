/*
 * ===========================================================================
 * lexer.l  --  Template do analisador lexico (Flex)
 * ===========================================================================
 *
 * Objetivo do projeto:
 *   Construir um compilador que recebe codigo-fonte em JavaScript e gera
 *   codigo equivalente em Python. Este arquivo e a porta de entrada: o
 *   analisador lexico, responsavel por quebrar o texto de entrada em tokens
 *   (palavras-chave, identificadores, literais, operadores, pontuacao).
 *
 * O que precisa ser feito aqui:
 *   1. Declarar as expressoes regulares para cada categoria de token do
 *      subconjunto de JavaScript que sera suportado (ex.: let, const, var,
 *      function, if, else, for, while, return, operadores +, -, *, /, ==,
 *      ===, !=, !==, =, +=, etc., literais numericos, strings com "", ''
 *      e template literals `...`).
 *   2. Para cada regra, devolver o token correspondente (definido em
 *      parser.y) e, quando aplicavel, preencher yylval com o valor
 *      semantico (nome do identificador, valor numerico, conteudo da
 *      string, etc.).
 *   3. Descartar espacos em branco e comentarios (// e de bloco).
 *   4. Reportar tokens invalidos com linha e coluna via lex_error().
 *
 * Integracao:
 *   - Bison gera parser.tab.h com os codigos dos tokens e o tipo YYSTYPE.
 *   - O driver em main.c abre o arquivo de entrada e chama yyparse(), que
 *     por sua vez chama yylex() a cada token solicitado.
 * ===========================================================================
 */

%{
#include "common.h"
#include "parser.tab.h"
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

/* -------------------------------------------------------------------------
 * Definicoes auxiliares (atalhos de regex)
 *   Adicionar aqui padroes reutilizaveis, por exemplo:
 *     digit   [0-9]
 *     letter  [a-zA-Z_$]
 *     ident   {letter}({letter}|{digit})*
 *     number  {digit}+(\.{digit}+)?
 *     string  \"([^\"\\\n]|\\.)*\"
 * ------------------------------------------------------------------------- */


%%

 /* -------------------------------------------------------------------------
  * Regras do analisador lexico
  *
  * Estrutura esperada (exemplos, ainda nao implementados):
  *
  *   "let"         { return LET; }
  *   "const"       { return CONST; }
  *   "function"    { return FUNCTION; }
  *   "return"      { return RETURN; }
  *
  *   {ident}       { yylval.sval = strdup(yytext); return IDENTIFIER; }
  *   {number}      { yylval.fval = atof(yytext);   return NUMBER; }
  *   {string}      { yylval.sval = strdup(yytext); return STRING; }
  *
  *   "=="          { return EQ; }
  *   "==="         { return SEQ; }
  *
  *   [ \t\r\n]+    { -- ignorar espacos em branco -- }
  *   "//"[^\n]*    { -- comentario de linha        -- }
  *
  *   .             { lex_error(yytext, yylineno, yycolumn); }
  * ------------------------------------------------------------------------- */

%%

/*
 * Funcoes auxiliares (opcional): podem ir aqui ou em um .c separado.
 * Ex.: tratamento fino de strings, conversao de escapes, tabela de
 * palavras-chave, etc.
 */
