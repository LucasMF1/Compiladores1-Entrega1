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
 * O que precisa ser feito aqui (em etapas futuras):
 *   1. Tratar argumentos de linha de comando (arquivo de entrada, arquivo
 *      de saida, flags como -o, --verbose, etc.).
 *   2. Apos yyparse() retornar com sucesso, percorrer a AST e emitir o
 *      codigo Python equivalente em stdout ou em um arquivo .py.
 *   3. Padronizar codigos de retorno: 0 em caso de sucesso, !=0 para
 *      erros lexicos/sintaticos/semanticos.
 * ===========================================================================
 */

#include "common.h"

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo.js>\n", argv[0]);
        return 2;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Nao foi possivel abrir: %s\n", argv[1]);
        return 2;
    }

    int rc = yyparse();
    fclose(yyin);

    /*
     * TODO: se rc == 0, chamar a rotina de geracao de codigo Python
     *       a partir da AST construida durante o parsing.
     */

    return rc;
}
