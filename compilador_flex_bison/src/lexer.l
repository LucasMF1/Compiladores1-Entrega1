
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "parser.tab.h"

int yycolumn = 1;

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

    char *out = (char *)malloc(len - 1);
    if (!out) {
        perror("malloc");
        exit(EXIT_FAILURE);
    }

    memcpy(out, text + 1, len - 2);
    out[len - 2] = '\0';
    return out;
}

#define RET(tok) do { yycolumn += yyleng; return tok; } while (0)

#define YY_USER_ACTION                                  \
    yylloc.first_line   = yylineno;                     \
    yylloc.first_column = yycolumn;                     \
    yylloc.last_line    = yylineno;                     \
    yylloc.last_column  = yycolumn + yyleng - 1;

extern void lex_error(const char *lexeme, int line, int column);
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput
%option nodefault

%x COMMENT

digit      [0-9]
letter     [A-Za-z_$]
ident      {letter}({letter}|{digit})*
number     (({digit}+\.{digit}*)|(\.{digit}+)|({digit}+))([eE][+-]?{digit}+)?
str_dq     \"([^\"\\\n]|\\.)*\"
str_sq     \'([^\'\\\n]|\\.)*\'
template   \`([^\\`]|\\.|\n)*\`
ws         [ \t\f\r]+

%%

"//"[^\n]*                 { yycolumn += yyleng; }

"/*"                       { yycolumn += yyleng; BEGIN(COMMENT); }

<COMMENT>"*/"              { yycolumn += yyleng; BEGIN(INITIAL); }
<COMMENT>\n                { yycolumn = 1; }
<COMMENT>.                 { yycolumn += yyleng; }
<COMMENT><<EOF>>           {
                              lex_error("comentário de bloco não finalizado", yylineno, yycolumn);
                              return 0;
                           }

{ws}                       { yycolumn += yyleng; }

\n                         { yycolumn = 1; }

{ident}                    {
                              int kw = keyword_token(yytext);
                              if (kw) {
                                  RET(kw);
                              }

                              yylval.sval = strdup(yytext);
                              RET(IDENTIFIER);
                          }

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

.                          {
                              lex_error(yytext, yylineno, yycolumn);
                              yycolumn += yyleng;
                          }

%%