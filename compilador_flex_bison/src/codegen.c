#include "codegen.h"
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

static int indent_level = 0;

static void print_indent(FILE *out) {
    for (int i = 0; i < indent_level; ++i) {
        fputs("    ", out);
    }
}

// Converte os códigos de operação do Bison para strings do Python
static const char *op_to_python(int op) {
    switch (op) {
        case PLUS: return "+";       case MINUS: return "-";
        case TIMES: return "*";      case DIVIDE: return "/";
        case MOD: return "%";
        case EQ: case STRICT_EQ: return "=="; 
        case NEQ: case STRICT_NEQ: return "!=";
        case LT: return "<";         case GT: return ">";
        case LE: return "<=";        case GE: return ">=";
        case AND: return "and";      case OR: return "or";
        case NOT: return "not";
        case ASSIGN: return "=";
        case PLUS_ASSIGN: return "+=";   case MINUS_ASSIGN: return "-=";
        case TIMES_ASSIGN: return "*=";  case DIV_ASSIGN: return "/=";
        case MOD_ASSIGN: return "%=";
        default: return "";
    }
}

void generate_code(AstNode *node, FILE *out) {
    if (!node) return;

    switch (node->kind) {
        case AST_PROGRAM:
            generate_code(node->a, out);
            break;

        case AST_LIST:
            for (int i = 0; i < node->child_count; ++i) {
                generate_code(node->children[i], out);
            }
            break;

        case AST_VAR_DECL:
            print_indent(out);
            fprintf(out, "%s", node->sval);
            if (node->a) {
                fputs(" = ", out);
                generate_code(node->a, out);
            } else {
                fputs(" = None", out); // let x; vira x = None
            }
            fputs("\n", out);
            break;

        case AST_EXPR_STMT:
            print_indent(out);
            generate_code(node->a, out);
            fputs("\n", out);
            break;

        case AST_ASSIGN:
            fprintf(out, "%s %s ", node->sval, op_to_python(node->op));
            generate_code(node->b, out);
            break;

        case AST_BINARY:
            fputs("(", out);
            generate_code(node->a, out);
            fprintf(out, " %s ", op_to_python(node->op));
            generate_code(node->b, out);
            fputs(")", out);
            break;

        case AST_UNARY:
            if (node->op == NOT) fputs("not ", out);
            else if (node->op == MINUS) fputs("-", out);
            generate_code(node->a, out);
            break;

        case AST_IDENT:
            fprintf(out, "%s", node->sval);
            break;

        case AST_NUMBER:
            fprintf(out, "%g", node->nval);
            break;

        case AST_STRING:
            fprintf(out, "\"%s\"", node->sval);
            break;

        case AST_BOOL:
            fprintf(out, "%s", node->bval ? "True" : "False");
            break;

        case AST_NULL:
        case AST_UNDEFINED:
            fputs("None", out);
            break;

        case AST_BLOCK:
            indent_level++;
            if (node->a && node->a->child_count > 0) {
                generate_code(node->a, out);
            } else {
                print_indent(out);
                fputs("pass\n", out);
            }
            indent_level--;
            break;

        case AST_IF:
            print_indent(out);
            fputs("if ", out);
            generate_code(node->a, out);
            fputs(":\n", out);
            generate_code(node->b, out);
            
            if (node->c) {
                print_indent(out);
                fputs("else:\n", out);
                generate_code(node->c, out);
            }
            break;

        case AST_WHILE:
            print_indent(out);
            fputs("while ", out);
            generate_code(node->a, out);
            fputs(":\n", out);
            generate_code(node->b, out);
            break;
        
        case AST_BREAK:
            print_indent(out);
            fputs("break\n", out);
            break;

        case AST_CONTINUE:
            print_indent(out);
            fputs("continue\n", out);
            break;

        case AST_FUNCTION:
            print_indent(out);
            fprintf(out, "def %s(", node->sval);
            if (node->a) {
                for (int i = 0; i < node->a->child_count; ++i) {
                    generate_code(node->a->children[i], out);
                    if (i < node->a->child_count - 1) fputs(", ", out);
                }
            }
            fputs("):\n", out);
            generate_code(node->b, out);
            break;

        case AST_RETURN:
            print_indent(out);
            fputs("return ", out);
            if (node->a) generate_code(node->a, out);
            fputs("\n", out);
            break;
            
        case AST_CALL:
            generate_code(node->a, out);
            fputs("(", out);
            for (int i = 0; i < node->child_count; ++i) {
                generate_code(node->children[i], out);
                if (i < node->child_count - 1) fputs(", ", out);
            }
            fputs(")", out);
            break;
        
        case AST_FOR:
            if (node->a) generate_code(node->a, out);
            
            print_indent(out);
            fputs("while ", out);
            if (node->b) generate_code(node->b, out);
            else fputs("True", out);
            fputs(":\n", out);
            
            indent_level++;
            
            if (node->d) {
                if (node->d->kind == AST_BLOCK) {
                    generate_code(node->d->a, out);
                } else {
                    generate_code(node->d, out);
                }
            }
            
            if (node->c) {
                print_indent(out);
                generate_code(node->c, out);
                fputs("\n", out);
            }
            
            indent_level--;
            break;

        case AST_MEMBER:
            generate_code(node->a, out);
            fprintf(out, ".%s", node->sval);
            break;

        case AST_INDEX:
            generate_code(node->a, out);
            fputs("[", out);
            generate_code(node->b, out);
            fputs("]", out);
            break;

        default:
            break;
    }
}