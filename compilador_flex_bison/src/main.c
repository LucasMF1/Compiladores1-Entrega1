/*
 * ===========================================================================
 * main.c  --  Driver do compilador JavaScript -> Python
 * ===========================================================================
 *
 * Objetivo:
 *   Ponto de entrada do executavel. Recebe o caminho de um arquivo .js,
 *   abre o arquivo, dispara o analisador sintatico (yyparse) - que por
 *   sua vez consome os tokens produzidos pelo lexer - e, em seguida,
 *   deve invocar a geracao de codigo Python a partir da AST construida.
 *
 * Modos de execucao:
 *   ./compilador arquivo.js          -> roda parser (yyparse).
 *   ./compilador --lex arquivo.js    -> roda apenas o lexer e imprime os
 *                                        tokens em stdout no formato
 *                                        TOKEN(lexema) @ linha:coluna
 *                                        util para depurar o lexer sem
 *                                        depender do parser.
 * ===========================================================================
 */

#include "common.h"
#include "parser.tab.h"

typedef struct {
    int         token;
    const char *name;
} TokenName;

static const TokenName token_names[] = {
    {IDENTIFIER, "IDENTIFIER"}, {STRING, "STRING"}, {TEMPLATE_STRING, "TEMPLATE_STRING"},
    {NUMBER, "NUMBER"},
    {LET, "LET"}, {CONST, "CONST"}, {VAR, "VAR"}, {FUNCTION, "FUNCTION"}, {RETURN, "RETURN"},
    {IF, "IF"}, {ELSE, "ELSE"}, {WHILE, "WHILE"}, {DO, "DO"}, {FOR, "FOR"},
    {BREAK, "BREAK"}, {CONTINUE, "CONTINUE"},
    {SWITCH, "SWITCH"}, {CASE, "CASE"}, {DEFAULT, "DEFAULT"},
    {TRY, "TRY"}, {CATCH, "CATCH"}, {FINALLY, "FINALLY"}, {THROW, "THROW"},
    {CLASS, "CLASS"}, {EXTENDS, "EXTENDS"},
    {IMPORT, "IMPORT"}, {FROM, "FROM"}, {EXPORT, "EXPORT"},
    {NEW, "NEW"}, {THIS, "THIS"},
    {IN, "IN"}, {OF, "OF"}, {INSTANCEOF, "INSTANCEOF"}, {TYPEOF, "TYPEOF"},
    {VOID_TOK, "VOID"}, {DELETE, "DELETE"},
    {ASYNC, "ASYNC"}, {AWAIT, "AWAIT"},
    {TRUE_TOK, "TRUE"}, {FALSE_TOK, "FALSE"}, {NULL_TOK, "NULL"}, {UNDEFINED_TOK, "UNDEFINED"},
    {EQ, "EQ"}, {NEQ, "NEQ"}, {STRICT_EQ, "STRICT_EQ"}, {STRICT_NEQ, "STRICT_NEQ"},
    {LE, "LE"}, {GE, "GE"},
    {AND, "AND"}, {OR, "OR"}, {SHL, "SHL"}, {SHR, "SHR"},
    {INCREMENT, "INCREMENT"}, {DECREMENT, "DECREMENT"},
    {PLUS_ASSIGN, "PLUS_ASSIGN"}, {MINUS_ASSIGN, "MINUS_ASSIGN"},
    {TIMES_ASSIGN, "TIMES_ASSIGN"}, {DIV_ASSIGN, "DIV_ASSIGN"}, {MOD_ASSIGN, "MOD_ASSIGN"},
    {ARROW, "ARROW"},
    {ASSIGN, "ASSIGN"}, {PLUS, "PLUS"}, {MINUS, "MINUS"},
    {TIMES, "TIMES"}, {DIVIDE, "DIVIDE"}, {MOD, "MOD"},
    {NOT, "NOT"}, {LT, "LT"}, {GT, "GT"},
    {BIT_AND, "BIT_AND"}, {BIT_OR, "BIT_OR"}, {BIT_XOR, "BIT_XOR"}, {BIT_NOT, "BIT_NOT"},
    {LPAREN, "LPAREN"}, {RPAREN, "RPAREN"},
    {LBRACE, "LBRACE"}, {RBRACE, "RBRACE"},
    {LBRACKET, "LBRACKET"}, {RBRACKET, "RBRACKET"},
    {COMMA, "COMMA"}, {SEMI, "SEMI"}, {COLON, "COLON"},
    {DOT, "DOT"}, {QUESTION, "QUESTION"},
};

static const char *token_name(int tok) {
    size_t i;
    for (i = 0; i < sizeof(token_names) / sizeof(token_names[0]); ++i) {
        if (token_names[i].token == tok) {
            return token_names[i].name;
        }
    }
    return "UNKNOWN";
}

static void print_escaped(const char *s, unsigned long len) {
    unsigned long i;
    for (i = 0; i < len; ++i) {
        unsigned char c = (unsigned char)s[i];
        switch (c) {
            case '\n': fputs("\\n", stdout); break;
            case '\r': fputs("\\r", stdout); break;
            case '\t': fputs("\\t", stdout); break;
            case '\\': fputs("\\\\", stdout); break;
            default:   fputc(c, stdout);     break;
        }
    }
}

static int run_lex_only(void) {
    int tok;
    while ((tok = yylex()) != 0) {
        printf("%s(", token_name(tok));
        print_escaped(yytext, yyleng);
        printf(") @ %d:%d\n", yylloc.first_line, yylloc.first_column);
    }
    return lex_error_count > 0 ? 1 : 0;
}

static void usage(const char *prog) {
    fprintf(stderr, "Uso: %s [--lex] <arquivo.js>\n", prog);
}

int main(int argc, char **argv) {
    int         lex_only = 0;
    const char *path     = NULL;
    int         i;

    for (i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--lex") == 0 || strcmp(argv[i], "-l") == 0) {
            lex_only = 1;
        } else if (argv[i][0] == '-') {
            fprintf(stderr, "Flag desconhecida: %s\n", argv[i]);
            usage(argv[0]);
            return 2;
        } else if (path == NULL) {
            path = argv[i];
        } else {
            fprintf(stderr, "Argumento extra: %s\n", argv[i]);
            usage(argv[0]);
            return 2;
        }
    }

    if (path == NULL) {
        usage(argv[0]);
        return 2;
    }

    yyin = fopen(path, "r");
    if (!yyin) {
        fprintf(stderr, "Nao foi possivel abrir: %s\n", path);
        return 2;
    }

    int rc = lex_only ? run_lex_only() : yyparse();
    fclose(yyin);

    /*
     * TODO: se rc == 0 e nao for modo --lex, chamar a rotina de geracao de
     *       codigo Python a partir da AST construida durante o parsing.
     */

    return rc;
}
