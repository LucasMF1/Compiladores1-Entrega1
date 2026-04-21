/*
 * ===========================================================================
 * lexer.l  --  Analisador lexico (Flex)
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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "parser.tab.h"

int yycolumn = 1;

    /* struct da tabela e tabela de palavras chave (ver com o otavio pra alinhar com o parser.y) */
typedef struct {
    const char *lexeme;
    int token;
} Keyword;

static const Keyword keywords[] = {
    {"let",        LET},
    {"const",      CONST},
    {"var",        VAR},
    {"function",   FUNCTION},
    {"if",         IF},
    {"else",       ELSE},
    {"for",        FOR},
    {"while",      WHILE},
    {"do",         DO},
    {"switch",     SWITCH},
    {"case",       CASE},
    {"default",    DEFAULT},
    {"break",      BREAK},
    {"continue",   CONTINUE},
    {"return",     RETURN},
    {"try",        TRY},
    {"catch",      CATCH},
    {"finally",    FINALLY},
    {"throw",      THROW},
    {"class",      CLASS},
    {"extends",    EXTENDS},
    {"import",     IMPORT},
    {"from",       FROM},
    {"export",     EXPORT},
    {"new",        NEW},
    {"this",       THIS},
    {"in",         IN},
    {"of",         OF},
    {"instanceof", INSTANCEOF},
    {"typeof",     TYPEOF},
    {"void",       VOID_TOK},
    {"delete",     DELETE},
    {"async",      ASYNC},
    {"await",      AWAIT},
    {"true",       TRUE_TOK},
    {"false",      FALSE_TOK},
    {"null",       NULL_TOK},
    {"undefined",  UNDEFINED_TOK}
};

static int keyword_token(const char *lexeme) {
    size_t i;
    for (i = 0; i < sizeof(keywords) / sizeof(keywords[0]); ++i) {
        if (strcmp(lexeme, keywords[i].lexeme) == 0) {
            return keywords[i].token;
        }
    }
    return 0;
}

static char *copy_without_quotes(const char *text, size_t len) {
    if (len < 2) {
        return strdup("");
    }

    char *out = (char *)malloc(len - 1); /* (len - 2) chars + '\0' */
    if (!out) {
        perror("malloc");
        exit(EXIT_FAILURE);
    }

    memcpy(out, text + 1, len - 2);
    out[len - 2] = '\0';
    return out;
}

#define RET(tok) do { yycolumn += yyleng; return tok; } while (0)

extern void lex_error(const char *lexeme, int line, int column);
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput
%option nodefault

%x COMMENT

/* -------------------------------------------------------------------------
 * Definicoes auxiliares (atalhos de regex)
 *   Adicionar aqui padroes reutilizaveis, por exemplo:
 *     digit   [0-9]
 *     letter  [a-zA-Z_$]
 *     ident   {letter}({letter}|{digit})*
 *     number  {digit}+(\.{digit}+)?
 *     string  \"([^\"\\\n]|\\.)*\"
 * ------------------------------------------------------------------------- */

digit      [0-9]
letter     [A-Za-z_$]
ident      {letter}({letter}|{digit})*
number     (({digit}+\.{digit}*)|(\.{digit}+)|({digit}+))([eE][+-]?{digit}+)?
str_dq     \"([^\"\\\n]|\\.)*\"
str_sq     \'([^\'\\\n]|\\.)*\'
template   \`([^\\`\n]|\\.)*\`
ws         [ \t\f\r]+

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


    /* Comentário de linha */
"//"[^\n]*                 { yycolumn += yyleng; }

    /* Comentário de bloco */
"/*"                       { yycolumn += yyleng; BEGIN(COMMENT); }

<COMMENT>"*/"              { yycolumn += yyleng; BEGIN(INITIAL); }
<COMMENT>\n                { yycolumn = 1; }
<COMMENT>.                 { yycolumn += yyleng; }
<COMMENT><<EOF>>           {
                              lex_error("comentário de bloco não finalizado", yylineno, yycolumn);
                              return 0;
                           }

    /* Espaços e tabulações */
{ws}                       { yycolumn += yyleng; }

    /* Quebra de linha */
\n                         { yycolumn = 1; }

    /* Palavras-chave, identificadores e literais */
{ident}                    {
                              int kw = keyword_token(yytext);
                              if (kw) {
                                  RET(kw);
                              }

                              yylval.sval = strdup(yytext);
                              RET(IDENTIFIER);
                          }

    /* Números, strings e template literals */
{number}                   {
                              yylval.fval = strtod(yytext, NULL);
                              RET(NUMBER);
                          }

{str_dq}                   {
                              yylval.sval = copy_without_quotes(yytext, yyleng);
                              RET(STRING);
                          }

{str_sq}                   {
                              yylval.sval = copy_without_quotes(yytext, yyleng);
                              RET(STRING);
                          }

{template}                 {
                              yylval.sval = copy_without_quotes(yytext, yyleng);
                              RET(TEMPLATE_STRING);
                          }

    /* Operadores */
"==="                      { RET(STRICT_EQ); }
"!=="                      { RET(STRICT_NEQ); }
"=="                       { RET(EQ); }
"!="                       { RET(NEQ); }
"<="                       { RET(LE); }
">="                       { RET(GE); }
"&&"                       { RET(AND); }
"||"                       { RET(OR); }
"<<"                       { RET(SHL); }
">>"                       { RET(SHR); }
"++"                       { RET(INCREMENT); }
"--"                       { RET(DECREMENT); }
"+="                       { RET(PLUS_ASSIGN); }
"-="                       { RET(MINUS_ASSIGN); }
"*="                       { RET(TIMES_ASSIGN); }
"/="                       { RET(DIV_ASSIGN); }
"%="                       { RET(MOD_ASSIGN); }
"=>"                       { RET(ARROW); }

"="                        { RET(ASSIGN); }
"+"                        { RET(PLUS); }
"-"                        { RET(MINUS); }
"*"                        { RET(TIMES); }
"/"                        { RET(DIVIDE); }
"%"                        { RET(MOD); }
"!"                        { RET(NOT); }
"<"                        { RET(LT); }
">"                        { RET(GT); }
"&"                        { RET(BIT_AND); }
"|"                        { RET(BIT_OR); }
"^"                        { RET(BIT_XOR); }
"~"                        { RET(BIT_NOT); }

    /* Pontuação / delimitadores */
"("                        { RET(LPAREN); }
")"                        { RET(RPAREN); }
"{"                        { RET(LBRACE); }
"}"                        { RET(RBRACE); }
"["                        { RET(LBRACKET); }
"]"                        { RET(RBRACKET); }
","                        { RET(COMMA); }
";"                        { RET(SEMI); }
":"                        { RET(COLON); }
"."                        { RET(DOT); }
"?"                        { RET(QUESTION); }

    /* Erros lexicos */
.                          {
                              lex_error(yytext, yylineno, yycolumn);
                              yycolumn += yyleng;
                          }

%%