#ifndef COMPILADOR_CODEGEN_H
#define COMPILADOR_CODEGEN_H

#include <stdio.h>
#include "ast.h"

// Função principal
void generate_code(AstNode *node, FILE *out);

#endif