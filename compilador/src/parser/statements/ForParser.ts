import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { ForStatement } from "../ast/Statements.js";

export class ForParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "for";
  }

  /**
   * Gramática:
   *   for_stmt = 'for' IDENTIFIER 'in' expr ':' block
   *
   * Passos:
   *   1. Consumir 'for'.
   *   2. Consumir IDENTIFIER (variável de iteração) → target.
   *   3. Consumir KEYWORD 'in'.
   *   4. Parsear a expressão iterável (parseExpression).
   *   5. Consumir ':'.
   *   6. Parsear o corpo (parseBlock).
   */
  parse(_parser: Parser): ForStatement {
    throw new Error("ForParser.parse not implemented");
  }
}
