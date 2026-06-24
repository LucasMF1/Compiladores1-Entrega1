#include "optimizer.h"
#include "parser.tab.h"
#include <math.h>

AstNode *optimize(AstNode *node) {
    if (!node) return NULL;

    /* Otimiza filhos de baixo para cima antes de tentar dobrar o no atual. */
    node->a = optimize(node->a);
    node->b = optimize(node->b);
    node->c = optimize(node->c);
    node->d = optimize(node->d);
    for (int i = 0; i < node->child_count; ++i)
        node->children[i] = optimize(node->children[i]);

    /* Constant folding: binaria com dois literais numericos. */
    if (node->kind == AST_BINARY &&
        node->a && node->a->kind == AST_NUMBER &&
        node->b && node->b->kind == AST_NUMBER) {

        double a = node->a->nval;
        double b = node->b->nval;
        double result;
        int can_fold = 1;

        switch (node->op) {
            case PLUS:   result = a + b; break;
            case MINUS:  result = a - b; break;
            case TIMES:  result = a * b; break;
            case DIVIDE:
                if (b == 0.0) { can_fold = 0; break; }
                result = a / b;
                break;
            case MOD:
                if (b == 0.0) { can_fold = 0; break; }
                result = fmod(a, b);
                break;
            default:
                can_fold = 0;
        }

        if (can_fold) {
            ast_free(node->a); node->a = NULL;
            ast_free(node->b); node->b = NULL;
            node->kind = AST_NUMBER;
            node->nval = result;
            node->op   = 0;
        }
    }

    /* Constant folding: negacao unaria de literal numerico. */
    if (node->kind == AST_UNARY && node->op == MINUS &&
        node->a && node->a->kind == AST_NUMBER) {
        double val = -node->a->nval;
        ast_free(node->a); node->a = NULL;
        node->kind = AST_NUMBER;
        node->nval = val;
        node->op   = 0;
    }

    return node;
}
