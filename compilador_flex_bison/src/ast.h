#ifndef COMPILADOR_AST_H
#define COMPILADOR_AST_H

#include <stdio.h>

typedef enum {
    AST_PROGRAM,
    AST_BLOCK,
    AST_LIST,
    AST_VAR_DECL,
    AST_FUNCTION,
    AST_IF,
    AST_WHILE,
    AST_FOR,
    AST_RETURN,
    AST_BREAK,
    AST_CONTINUE,
    AST_EXPR_STMT,
    AST_EMPTY_STMT,
    AST_BINARY,
    AST_UNARY,
    AST_ASSIGN,
    AST_CALL,
    AST_MEMBER,
    AST_INDEX,
    AST_IDENT,
    AST_NUMBER,
    AST_STRING,
    AST_BOOL,
    AST_NULL,
    AST_UNDEFINED
} AstKind;

typedef struct AstNode AstNode;

struct AstNode {
    AstKind  kind;
    int      line;
    int      column;
    int      op;            /* token code: BINARY/UNARY/ASSIGN */
    int      decl_kind;     /* token code: LET/CONST/VAR */
    char    *sval;          /* nome / string literal / propriedade */
    double   nval;          /* literal numerico */
    int      bval;          /* literal booleano */
    AstNode *a, *b, *c, *d; /* filhos com papel fixo */
    AstNode **children;     /* filhos de aridade variavel */
    int      child_count;
    int      child_cap;
};

/* Raiz da arvore, preenchida pela acao semantica de `program`. */
extern AstNode *ast_root;

/* Infra. */
AstNode *ast_new(AstKind kind, int line, int column);
void     ast_add_child(AstNode *parent, AstNode *child);
void     ast_free(AstNode *node);
void     ast_print(const AstNode *node, FILE *out);

/* Construtores. Veja tabela de slots no comentario do topo do arquivo. */
AstNode *ast_program(AstNode *body, int line, int col);
AstNode *ast_block(AstNode *body, int line, int col);
AstNode *ast_list(int line, int col);

AstNode *ast_var_decl(int decl_kind, char *name, AstNode *init, int line, int col);
AstNode *ast_function(char *name, AstNode *params, AstNode *body, int line, int col);
AstNode *ast_if(AstNode *cond, AstNode *then_s, AstNode *else_s, int line, int col);
AstNode *ast_while(AstNode *cond, AstNode *body, int line, int col);
AstNode *ast_for(AstNode *init, AstNode *cond, AstNode *update, AstNode *body, int line, int col);
AstNode *ast_return(AstNode *value, int line, int col);
AstNode *ast_break(int line, int col);
AstNode *ast_continue(int line, int col);
AstNode *ast_expr_stmt(AstNode *expr, int line, int col);
AstNode *ast_empty_stmt(int line, int col);

AstNode *ast_binary(int op, AstNode *left, AstNode *right, int line, int col);
AstNode *ast_unary(int op, AstNode *operand, int line, int col);
AstNode *ast_assign(int op, char *target, AstNode *value, int line, int col);
AstNode *ast_call(AstNode *callee, AstNode *args, int line, int col);
AstNode *ast_member(AstNode *object, char *prop, int line, int col);
AstNode *ast_index(AstNode *object, AstNode *index, int line, int col);

AstNode *ast_ident(char *name, int line, int col);
AstNode *ast_number(double value, int line, int col);
AstNode *ast_string(char *value, int line, int col);
AstNode *ast_bool(int value, int line, int col);
AstNode *ast_null(int line, int col);
AstNode *ast_undefined(int line, int col);

#endif /* COMPILADOR_AST_H */
