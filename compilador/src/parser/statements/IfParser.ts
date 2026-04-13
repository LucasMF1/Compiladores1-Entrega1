import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { IfStatement } from "../ast/Statements.js";

export class IfParser implements StatementParser {
  /** Aceita se o token atual é KEYWORD 'if'. */
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "if";
  }

  /**
   * Gramática:
   *   if_stmt = 'if' expr ':' block ('elif' expr ':' block)* ['else' ':' block]
   *
   * Passos:
   *   1. Consumir 'if' (expect KEYWORD 'if').
   *   2. Parsear a condição com parser.parseExpression().
   *   3. Consumir ':' (expect PUNCTUATION ':').
   *   4. Parsear o corpo com parser.parseBlock() → consequent.
   *   5. Se o próximo token é 'elif', parsear recursivamente como um if
   *      aninhado no alternate. Se for 'else', consumir ':' e parseBlock.
   *   6. Caso contrário, alternate = null.
   */
  parse(_parser: Parser): IfStatement {
    throw new Error("IfParser.parse not implemented");
  }
}
