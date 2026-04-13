import type { Parser } from "./Parser.js";
import type { Expression } from "./ast/Expressions.js";

/**
 * Parser de expressões (separado dos statement parsers).
 *
 * Expressões em Python têm precedência e associatividade — não cabe na mesma
 * interface de statement parser. A abordagem clássica aqui é Pratt parsing
 * (aka precedence climbing), com uma função por nível de precedência:
 *
 *   parseOr       (or)
 *   parseAnd      (and)
 *   parseNot      (not)
 *   parseCompare  (==, !=, <, <=, >, >=, in, not in)
 *   parseAdd      (+, -)
 *   parseMul      (*, /)
 *   parseUnary    (-x, +x)
 *   parseCall     (f(...), obj.attr, obj[i])
 *   parsePrimary  (literal, identificador, '(' expr ')')
 *
 * Cada nível chama o próximo mais apertado, consome operadores do seu nível
 * em loop, e devolve uma árvore BinaryOp/UnaryOp.
 */
export class ExpressionParser {
  /**
   * Entrada: o token atual do parser é o início de uma expressão.
   * Saída: o nó AST da expressão completa.
   *
   * TODO: implementar a cascata de precedência descrita acima.
   */
  parse(_parser: Parser): Expression {
    throw new Error("ExpressionParser.parse not implemented");
  }
}
