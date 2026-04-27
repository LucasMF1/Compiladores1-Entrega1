/*
 * ===========================================================================
 * ast.c  --  Implementacao da AST
 * ===========================================================================
 */

#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "parser.tab.h"   /* codigos de token usados em ast_print */

AstNode *ast_root = NULL;

/* ------------------------------------------------------------------------- */
/* Infra                                                                      */
/* ------------------------------------------------------------------------- */

AstNode *ast_new(AstKind kind, int line, int column) {
    AstNode *n = (AstNode *)calloc(1, sizeof(AstNode));
    n->kind   = kind;
    n->line   = line;
    n->column = column;
    return n;
}

void ast_add_child(AstNode *parent, AstNode *child) {
    if (!parent || !child) return;
    if (parent->child_count == parent->child_cap) {
        int new_cap = parent->child_cap ? parent->child_cap * 2 : 4;
        parent->children = (AstNode **)realloc(parent->children,
                                               (size_t)new_cap * sizeof(AstNode *));
        parent->child_cap = new_cap;
    }
    parent->children[parent->child_count++] = child;
}

void ast_free(AstNode *node) {
    if (!node) return;
    ast_free(node->a);
    ast_free(node->b);
    ast_free(node->c);
    ast_free(node->d);
    for (int i = 0; i < node->child_count; ++i) ast_free(node->children[i]);
    free(node->children);
    free(node->sval);
    free(node);
}

/* ------------------------------------------------------------------------- */
/* Construtores                                                               */
/* ------------------------------------------------------------------------- */

AstNode *ast_program(AstNode *body, int line, int col) {
    AstNode *n = ast_new(AST_PROGRAM, line, col);
    n->a = body;
    return n;
}

AstNode *ast_block(AstNode *body, int line, int col) {
    AstNode *n = ast_new(AST_BLOCK, line, col);
    n->a = body;
    return n;
}

AstNode *ast_list(int line, int col) {
    return ast_new(AST_LIST, line, col);
}

AstNode *ast_var_decl(int decl_kind, char *name, AstNode *init, int line, int col) {
    AstNode *n = ast_new(AST_VAR_DECL, line, col);
    n->decl_kind = decl_kind;
    n->sval      = name;     /* posse transferida */
    n->a         = init;
    return n;
}

AstNode *ast_if(AstNode *cond, AstNode *then_s, AstNode *else_s, int line, int col) {
    AstNode *n = ast_new(AST_IF, line, col);
    n->a = cond; n->b = then_s; n->c = else_s;
    return n;
}

AstNode *ast_while(AstNode *cond, AstNode *body, int line, int col) {
    AstNode *n = ast_new(AST_WHILE, line, col);
    n->a = cond; n->b = body;
    return n;
}

AstNode *ast_for(AstNode *init, AstNode *cond, AstNode *update, AstNode *body,
                 int line, int col) {
    AstNode *n = ast_new(AST_FOR, line, col);
    n->a = init; n->b = cond; n->c = update; n->d = body;
    return n;
}

AstNode *ast_return(AstNode *value, int line, int col) {
    AstNode *n = ast_new(AST_RETURN, line, col);
    n->a = value;
    return n;
}

AstNode *ast_break(int line, int col)    { return ast_new(AST_BREAK, line, col); }
AstNode *ast_continue(int line, int col) { return ast_new(AST_CONTINUE, line, col); }

AstNode *ast_expr_stmt(AstNode *expr, int line, int col) {
    AstNode *n = ast_new(AST_EXPR_STMT, line, col);
    n->a = expr;
    return n;
}

AstNode *ast_empty_stmt(int line, int col) {
    return ast_new(AST_EMPTY_STMT, line, col);
}

AstNode *ast_binary(int op, AstNode *left, AstNode *right, int line, int col) {
    AstNode *n = ast_new(AST_BINARY, line, col);
    n->op = op; n->a = left; n->b = right;
    return n;
}

AstNode *ast_unary(int op, AstNode *operand, int line, int col) {
    AstNode *n = ast_new(AST_UNARY, line, col);
    n->op = op; n->a = operand;
    return n;
}

AstNode *ast_assign(int op, char *target, AstNode *value, int line, int col) {
    AstNode *n = ast_new(AST_ASSIGN, line, col);
    n->op = op; n->sval = target; n->b = value;
    return n;
}

AstNode *ast_call(AstNode *callee, AstNode *args, int line, int col) {
    AstNode *n = ast_new(AST_CALL, line, col);
    n->a = callee;
    if (args) {
        /* Move filhos da lista de argumentos para o no de chamada e descarta
         * o no LIST temporario. */
        n->children    = args->children;
        n->child_count = args->child_count;
        n->child_cap   = args->child_cap;
        args->children    = NULL;
        args->child_count = 0;
        args->child_cap   = 0;
        ast_free(args);
    }
    return n;
}

AstNode *ast_member(AstNode *object, char *prop, int line, int col) {
    AstNode *n = ast_new(AST_MEMBER, line, col);
    n->a = object; n->sval = prop;
    return n;
}

AstNode *ast_index(AstNode *object, AstNode *index, int line, int col) {
    AstNode *n = ast_new(AST_INDEX, line, col);
    n->a = object; n->b = index;
    return n;
}

AstNode *ast_ident(char *name, int line, int col) {
    AstNode *n = ast_new(AST_IDENT, line, col);
    n->sval = name;
    return n;
}

AstNode *ast_number(double value, int line, int col) {
    AstNode *n = ast_new(AST_NUMBER, line, col);
    n->nval = value;
    return n;
}

AstNode *ast_string(char *value, int line, int col) {
    AstNode *n = ast_new(AST_STRING, line, col);
    n->sval = value;
    return n;
}

AstNode *ast_bool(int value, int line, int col) {
    AstNode *n = ast_new(AST_BOOL, line, col);
    n->bval = value ? 1 : 0;
    return n;
}

AstNode *ast_null(int line, int col)      { return ast_new(AST_NULL, line, col); }
AstNode *ast_undefined(int line, int col) { return ast_new(AST_UNDEFINED, line, col); }

/* ------------------------------------------------------------------------- */
/* Impressao (s-expression indentada para depuracao)                          */
/* ------------------------------------------------------------------------- */

static const char *op_name(int op) {
    switch (op) {
        case PLUS: return "+";   case MINUS: return "-";
        case TIMES: return "*";  case DIVIDE: return "/";
        case MOD: return "%";
        case EQ: return "==";    case NEQ: return "!=";
        case STRICT_EQ: return "==="; case STRICT_NEQ: return "!==";
        case LT: return "<";     case GT: return ">";
        case LE: return "<=";    case GE: return ">=";
        case AND: return "&&";   case OR: return "||";
        case NOT: return "!";
        case ASSIGN: return "=";
        case PLUS_ASSIGN: return "+=";   case MINUS_ASSIGN: return "-=";
        case TIMES_ASSIGN: return "*=";  case DIV_ASSIGN: return "/=";
        case MOD_ASSIGN: return "%=";
        default: return "?";
    }
}

static const char *decl_name(int decl_kind) {
    switch (decl_kind) {
        case LET:   return "let";
        case CONST: return "const";
        case VAR:   return "var";
        default:    return "?";
    }
}

static void indent(FILE *out, int level) {
    for (int i = 0; i < level; ++i) fputs("  ", out);
}

static void print_rec(const AstNode *n, FILE *out, int level) {
    if (!n) { indent(out, level); fputs("(nil)\n", out); return; }
    indent(out, level);
    switch (n->kind) {
        case AST_PROGRAM:    fputs("(program\n", out);  print_rec(n->a, out, level + 1); break;
        case AST_BLOCK:      fputs("(block\n", out);    print_rec(n->a, out, level + 1); break;
        case AST_LIST:
            fputs("(list\n", out);
            for (int i = 0; i < n->child_count; ++i) print_rec(n->children[i], out, level + 1);
            break;
        case AST_VAR_DECL:
            fprintf(out, "(var-decl %s %s\n", decl_name(n->decl_kind), n->sval ? n->sval : "?");
            print_rec(n->a, out, level + 1);
            break;
        case AST_IF:
            fputs("(if\n", out);
            print_rec(n->a, out, level + 1);
            print_rec(n->b, out, level + 1);
            if (n->c) print_rec(n->c, out, level + 1);
            break;
        case AST_WHILE:
            fputs("(while\n", out);
            print_rec(n->a, out, level + 1);
            print_rec(n->b, out, level + 1);
            break;
        case AST_FOR:
            fputs("(for\n", out);
            print_rec(n->a, out, level + 1);
            print_rec(n->b, out, level + 1);
            print_rec(n->c, out, level + 1);
            print_rec(n->d, out, level + 1);
            break;
        case AST_RETURN:
            fputs("(return\n", out);
            if (n->a) print_rec(n->a, out, level + 1);
            break;
        case AST_BREAK:      fputs("(break)\n", out);     return;
        case AST_CONTINUE:   fputs("(continue)\n", out);  return;
        case AST_EXPR_STMT:
            fputs("(expr-stmt\n", out);
            print_rec(n->a, out, level + 1);
            break;
        case AST_EMPTY_STMT: fputs("(empty-stmt)\n", out); return;
        case AST_BINARY:
            fprintf(out, "(binary %s\n", op_name(n->op));
            print_rec(n->a, out, level + 1);
            print_rec(n->b, out, level + 1);
            break;
        case AST_UNARY:
            fprintf(out, "(unary %s\n", op_name(n->op));
            print_rec(n->a, out, level + 1);
            break;
        case AST_ASSIGN:
            fprintf(out, "(assign %s %s\n", op_name(n->op), n->sval ? n->sval : "?");
            print_rec(n->b, out, level + 1);
            break;
        case AST_CALL:
            fputs("(call\n", out);
            print_rec(n->a, out, level + 1);
            indent(out, level + 1); fputs("(args\n", out);
            for (int i = 0; i < n->child_count; ++i) print_rec(n->children[i], out, level + 2);
            indent(out, level + 1); fputs(")\n", out);
            break;
        case AST_MEMBER:
            fprintf(out, "(member .%s\n", n->sval ? n->sval : "?");
            print_rec(n->a, out, level + 1);
            break;
        case AST_INDEX:
            fputs("(index\n", out);
            print_rec(n->a, out, level + 1);
            print_rec(n->b, out, level + 1);
            break;
        case AST_IDENT:      fprintf(out, "(ident %s)\n", n->sval ? n->sval : "?"); return;
        case AST_NUMBER:     fprintf(out, "(number %g)\n", n->nval); return;
        case AST_STRING:     fprintf(out, "(string %s)\n", n->sval ? n->sval : ""); return;
        case AST_BOOL:       fprintf(out, "(bool %s)\n", n->bval ? "true" : "false"); return;
        case AST_NULL:       fputs("(null)\n", out); return;
        case AST_UNDEFINED:  fputs("(undefined)\n", out); return;
    }
    indent(out, level);
    fputs(")\n", out);
}

void ast_print(const AstNode *node, FILE *out) {
    print_rec(node, out, 0);
}
