import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { WhileStatement } from "../ast/Statements.js";

export class WhileParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "while";
  }

  /**
   * Gramática:
   *   while_stmt = 'while' expr ':' block
   *
   * Passos:
   *   1. Consumir 'while'.
   *   2. Parsear a condição (parseExpression).
   *   3. Consumir ':'.
   *   4. Parsear o corpo (parseBlock).
   */
  parse(_parser: Parser): WhileStatement {
    throw new Error("WhileParser.parse not implemented");
  }
}
