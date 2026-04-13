import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { TryStatement } from "../ast/Statements.js";

export class TryParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "try";
  }

  /**
   * Gramática (simplificada — sem exception types ou 'as' por enquanto):
   *   try_stmt = 'try' ':' block 'except' ':' block
   *
   * Passos:
   *   1. Consumir 'try', consumir ':'.
   *   2. Parsear o corpo do try (parseBlock) → body.
   *   3. Consumir KEYWORD 'except', consumir ':'.
   *   4. Parsear o corpo do except (parseBlock) → handler.
   */
  parse(_parser: Parser): TryStatement {
    throw new Error("TryParser.parse not implemented");
  }
}
