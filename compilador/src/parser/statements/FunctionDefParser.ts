import type { StatementParser } from "./StatementParser.js";
import type { Token } from "../../lexer/Token.js";
import { TokenType } from "../../lexer/TokenType.js";
import type { Parser } from "../Parser.js";
import type { FunctionDef } from "../ast/Statements.js";

export class FunctionDefParser implements StatementParser {
  canParse(token: Token): boolean {
    return token.type === TokenType.KEYWORD && token.lexeme === "def";
  }

  /**
   * Gramática:
   *   func_def = 'def' IDENTIFIER '(' param_list? ')' ':' block
   *   param_list = IDENTIFIER (',' IDENTIFIER)*
   *
   * Passos:
   *   1. Consumir 'def'.
   *   2. Consumir IDENTIFIER (nome da função).
   *   3. Consumir '('.
   *   4. Enquanto o próximo não for ')', ler IDENTIFIERs separados por ','.
   *   5. Consumir ')'.
   *   6. Consumir ':'.
   *   7. Parsear o corpo (parseBlock).
   */
  parse(_parser: Parser): FunctionDef {
    throw new Error("FunctionDefParser.parse not implemented");
  }
}
