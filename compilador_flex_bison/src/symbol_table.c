#include "symbol_table.h"
#include <stdlib.h>

/* Inicialização da tabela */
void sym_init(SymbolTable *t) {
    t->current_scope = 0;
    for (int i = 0; i < TABLE_SIZE; i++) {
        t->buckets[i] = NULL;
    }
}

/* Inserção de símbolo 
   TODO: Implementar lógica de verificação de escopo para let/const/var */
void sym_insert(SymbolTable *t, const char *name, SymbolCategory cat) {
    // Por enquanto apenas um esqueleto de inserção
    printf("Inserindo simbolo: %s\n", name);
}

/* Busca de símbolo 
   TODO: Implementar busca recursiva nos escopos */
Symbol *sym_lookup(SymbolTable *t, const char *name) {
    return NULL; 
}

/* Liberação de memória */
void sym_destroy(SymbolTable *t) {
    // TODO: Percorrer a tabela e dar free em todos os símbolos e nomes
}