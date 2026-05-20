#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

typedef enum { CAT_VAR, CAT_CONST, CAT_FUNC } SymbolCategory;
typedef enum { TYPE_NUMBER, TYPE_STRING, TYPE_BOOL, TYPE_NONE } SymbolType;

#define TABLE_SIZE 101

typedef struct Symbol {
    char *name;
    SymbolCategory category;
    SymbolType type;
    int scope;
    int line;
    struct Symbol *next;
} Symbol;

typedef struct {
    Symbol *buckets[TABLE_SIZE];
    int current_scope;
} SymbolTable;

/* protótipos */
void sym_init(SymbolTable *t);
void sym_insert(SymbolTable *t, const char *name, SymbolCategory cat);
Symbol *sym_lookup(SymbolTable *t, const char *name);
void sym_destroy(SymbolTable *t);

#endif