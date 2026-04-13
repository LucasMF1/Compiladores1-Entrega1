import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { Statement } from "../ast/Statements.js";

/**
 * Fallback para statements que NÃO começam com uma keyword estrutural:
 *   - break
 *   - pass
 *   - atribuições:             x = expr,  x += expr, ...
 *   - expression statements:   f(x),  obj.method(),  etc.
 *
 * É o último parser da cadeia no Parser.statementParsers — se nenhum parser
 * keyword-gated aceitou o token, cai aqui.
 */
export class SimpleStatementParser implements StatementParser {
  /**
   * Aceita 'break', 'pass', ou qualquer token que possa iniciar uma expressão
   * (identificador, número, string, '(', 'not', '-', 'None', 'True', 'False').
   */
  canParse(token: Token): boolean {
    if (token.type === TokenType.KEYWORD) {
      return token.lexeme === "break"
        || token.lexeme === "pass"
        || token.lexeme === "not"
        || token.lexeme === "None"
        || token.lexeme === "True"
        || token.lexeme === "False";
    }
    return (
      token.type === TokenType.IDENTIFIER
      || token.type === TokenType.NUMBER
      || token.type === TokenType.STRING
      || (token.type === TokenType.PUNCTUATION && token.lexeme === "(")
      || (token.type === TokenType.OPERATOR
        && (token.lexeme === "-" || token.lexeme === "+"))
    );
  }

  /**
   * Passos:
   *   1. Se o token é KEYWORD 'break' ou 'pass', consumir e emitir o nó
   *      correspondente. Consumir o NEWLINE de fim de statement.
   *   2. Caso contrário, parsear uma expressão (parseExpression) → left.
   *   3. Se o próximo token é um OPERATOR de atribuição
   *      ('=', '+=', '-=', '*=', '/='), consumir, parsear o lado direito
   *      (parseExpression) e emitir Assignment.
   *   4. Senão, emitir ExpressionStatement com a expressão já parseada.
   *   5. Consumir o NEWLINE de fim de statement.
   */
  parse(_parser: Parser): Statement {
    throw new Error("SimpleStatementParser.parse not implemented");
  }
}
