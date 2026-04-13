import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { ReturnStatement } from "../ast/Statements.js";

export class ReturnParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "return";
  }

  /**
   * Gramática:
   *   return_stmt = 'return' expr? NEWLINE
   *
   * Passos:
   *   1. Consumir 'return'.
   *   2. Se o próximo token é NEWLINE, argument = null.
   *      Caso contrário, parsear a expressão (parseExpression).
   *   3. Consumir o NEWLINE de fim de statement.
   */
  parse(_parser: Parser): ReturnStatement {
    throw new Error("ReturnParser.parse not implemented");
  }
}
