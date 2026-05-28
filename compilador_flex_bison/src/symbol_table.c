#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Inicialização da tabela */
void sym_init(SymbolTable *t) {
    //t->current_scope = 0;
    for (int i = 0; i < TABLE_SIZE; i++) {
        t->buckets[i] = NULL;
    }
}

static unsigned hash(const char *str) {
    unsigned h = 0;

    while (*str) {
        h = h * 31 + *str;
        str++;
    }

    return h % TABLE_SIZE;
}

 
   
void sym_insert(SymbolTable *t, const char *name, SymbolCategory cat) {


    unsigned index = hash(name);

    Symbol *sym = malloc(sizeof(Symbol));
    if (!sym) {
        fprintf(stderr, "Erro de memoria ao alocar simbolo\n");
        exit(1);
    }

    sym->name = strdup(name);
    sym->category = cat;

    /* Valores temporários/default */
    sym->type = TYPE_NONE;
    //sym->scope = t->current_scope;
    sym->line = yylineno;

    /* Inserção na cabeça da lista */
    sym->next = t->buckets[index];

    /* Agora o bucket aponta para o novo símbolo */
    t->buckets[index] = sym;

    //printf("Inserindo simbolo '%s' no bucket %u\n", name, index);
}

Symbol *sym_lookup(SymbolTable *t, const char *name) {

    /* Descobre o bucket onde o símbolo deveria estar */
    unsigned index = hash(name);

    /* Começa no início da lista encadeada */
    Symbol *current = t->buckets[index];

    /* Percorre a lista */
    while (current != NULL) {

        /* Compara os nomes */
        if (strcmp(current->name, name) == 0) {
            return current;
        }

        /* Vai para o próximo símbolo da lista */
        current = current->next;
    }

    /* Não encontrou */
    return NULL;
}

/* Liberação de memória */
void sym_destroy(SymbolTable *t) {

    /* Percorre todos os buckets */
    for (int i = 0; i < TABLE_SIZE; i++) {

        /* Começa no início da lista */
        Symbol *current = t->buckets[i];

        /* Percorre a linked list */
        while (current != NULL) {

            /* Guarda o próximo antes de liberar */
            Symbol *next = current->next;

            /* Libera a string do nome */
            free(current->name);

            /* Libera o símbolo */
            free(current);

            /* Vai para o próximo */
            current = next;
        }

        /* Bucket agora está vazio */
        t->buckets[i] = NULL;
    }
}


static Scope *current_scope = NULL;

void scope_enter(void) {
    Scope *scope = malloc(sizeof(Scope));

    sym_init(&scope->table);

    scope->parent = current_scope;

    current_scope = scope;
}

void scope_insert(const char *name, SymbolCategory category) {
    if (current_scope == NULL) {
        return;
    }

    if (scope_lookup_current(name) != NULL) {
        semantic_error("variavel ja declarada", name, yylineno, yycolumn);
        return;
    }

    sym_insert(&current_scope->table, name, category);
}

Symbol *scope_lookup(const char *name) {
    Scope *scope = current_scope;

    while (scope != NULL) {
        Symbol *sym = sym_lookup(&scope->table, name);

        if (sym != NULL) {
            return sym;
        }

        scope = scope->parent;
    }

    return NULL;
}

Symbol *scope_lookup_current(const char *name) {
    if (current_scope == NULL) {
        return NULL;
    }

    return sym_lookup(&current_scope->table, name);
}

void scope_exit(void) {
    Scope *old = current_scope;

    if (current_scope != NULL) {
        current_scope = current_scope->parent;
        free(old);
    }
}