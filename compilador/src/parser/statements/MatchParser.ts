import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { MatchStatement } from "../ast/Statements.js";

export class MatchParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "match";
  }

  /**
   * Gramática (simplificada):
   *   match_stmt = 'match' expr ':' NEWLINE INDENT case+ DEDENT
   *   case       = 'case' expr ':' block
   *
   * Passos:
   *   1. Consumir 'match', parsear subject (parseExpression), consumir ':'.
   *   2. Consumir NEWLINE + INDENT.
   *   3. Repetir enquanto o próximo for KEYWORD 'case':
   *      a. Consumir 'case', parsear pattern (parseExpression), consumir ':'.
   *      b. Parsear o corpo do case (parseBlock).
   *   4. Consumir DEDENT.
   */
  parse(_parser: Parser): MatchStatement {
    throw new Error("MatchParser.parse not implemented");
  }
}
