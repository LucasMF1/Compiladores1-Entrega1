import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { ImportStatement } from "../ast/Statements.js";

export class ImportParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "import";
  }

  /**
   * Gramática:
   *   import_stmt = 'import' IDENTIFIER ('as' IDENTIFIER)? NEWLINE
   *
   * Passos:
   *   1. Consumir 'import'.
   *   2. Consumir IDENTIFIER (nome do módulo).
   *   3. Se o próximo é KEYWORD 'as', consumir e ler IDENTIFIER (alias).
   *   4. Consumir NEWLINE.
   */
  parse(_parser: Parser): ImportStatement {
    throw new Error("ImportParser.parse not implemented");
  }
}
