/* Categorias e Tipos para futuras fases */
typedef enum { CAT_VAR, CAT_CONST, CAT_FUNC } SymbolCategory;
typedef enum { TYPE_NUMBER, TYPE_STRING, TYPE_BOOL, TYPE_NONE } SymbolType;

#define TABLE_SIZE 101

typedef struct Symbol {
    char *name;
    SymbolCategory category;
    SymbolType type;
    int scope;          /* Nível de escopo (0 para global) */
    int line;           /* Linha da declaração para erros */
    struct Symbol *next; /* Para colisões na hash table */
} Symbol;

typedef struct {
    Symbol *buckets[TABLE_SIZE];
    int current_scope;
} SymbolTable;