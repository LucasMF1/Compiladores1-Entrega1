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
} SymbolTable;

typedef struct Scope {
    SymbolTable table;
    struct Scope *parent;
} Scope;

/* protótipos */
//para tabela
void sym_init(SymbolTable *t);
void sym_insert(SymbolTable *t, const char *name, SymbolCategory cat);
Symbol *sym_lookup(SymbolTable *t, const char *name);
void sym_destroy(SymbolTable *t);

//para escopos diferentes
void scope_enter(void);
void scope_exit(void);
Symbol *scope_lookup(const char *name);
void scope_insert(const char *name, SymbolCategory category);
//verificar se ja tem variavel de mesmo nome declarada no escopo
Symbol *scope_lookup_current(const char *name);


#endif
