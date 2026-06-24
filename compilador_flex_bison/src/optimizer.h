#ifndef COMPILADOR_OPTIMIZER_H
#define COMPILADOR_OPTIMIZER_H

#include "ast.h"

/*
 * Percorre a AST de baixo para cima (filhos antes do pai) aplicando
 * constant folding: expressoes binarias/unarias cujos operandos sejam
 * literais numericos sao substituidas pelo resultado calculado em
 * tempo de compilacao.
 *
 * O no e modificado in-place; o ponteiro retornado e sempre o mesmo
 * que foi recebido (mantido para consistencia de interface).
 */
AstNode *optimize(AstNode *node);

#endif /* COMPILADOR_OPTIMIZER_H */
