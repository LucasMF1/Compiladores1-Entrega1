#include "common.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void sym_init(SymbolTable *t, unsigned size) {
    t->size = size;
    t->buckets = calloc(size, sizeof(Symbol *));

    if (!t->buckets) {
        fprintf(stderr, "Erro de memoria ao alocar tabela de simbolos\n");
        exit(1);
    }
}

static unsigned hash(const char *str, unsigned size) {
    unsigned h = 0;

    while (*str) {
        h = h * 31 + (unsigned char)*str;
        str++;
    }

    return h % size;
}

void sym_insert(SymbolTable *t, const char *name, SymbolCategory cat) {
    unsigned index = hash(name, t->size);

    Symbol *sym = malloc(sizeof(Symbol));
    if (!sym) {
        fprintf(stderr, "Erro de memoria ao alocar simbolo\n");
        exit(1);
    }

    sym->name = strdup(name);
    if (!sym->name) {
        fprintf(stderr, "Erro de memoria ao duplicar nome do simbolo\n");
        free(sym);
        exit(1);
    }

    sym->category = cat;
    sym->type = TYPE_NONE;
    sym->line = yylineno;
    sym->next = t->buckets[index];
    t->buckets[index] = sym;
}

Symbol *sym_lookup(SymbolTable *t, const char *name) {
    unsigned index = hash(name, t->size);
    Symbol *current = t->buckets[index];

    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }

    return NULL;
}

void sym_destroy(SymbolTable *t) {
    for (unsigned i = 0; i < t->size; i++) {
        Symbol *current = t->buckets[i];

        while (current != NULL) {
            Symbol *next = current->next;
            free(current->name);
            free(current);
            current = next;
        }

        t->buckets[i] = NULL;
    }

    free(t->buckets);
    t->buckets = NULL;
    t->size = 0;
}

void sym_set_type(Symbol *s, SymbolType t) {
    if (s) s->type = t;
}

static Scope *current_scope = NULL;

void scope_enter(void) {
    Scope *scope = malloc(sizeof(Scope));
    if (!scope) {
        fprintf(stderr, "Erro de memoria ao alocar escopo\n");
        exit(1);
    }

    /* Primeiro escopo aberto (current_scope == NULL) é o global:
       recebe a tabela grande. Os demais (blocos, funções) recebem
       uma tabela bem menor, já que costumam ter poucos simbolos. */
    unsigned size = (current_scope == NULL) ? GLOBAL_TABLE_SIZE
                                             : LOCAL_TABLE_SIZE;

    sym_init(&scope->table, size);
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
        sym_destroy(&old->table);  /* libera Symbols, nomes e buckets */
        free(old);
    }
}