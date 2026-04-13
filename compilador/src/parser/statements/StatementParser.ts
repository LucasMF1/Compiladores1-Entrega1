import type { Token } from "../../lexer/Token.js";
import type { Statement } from "../ast/Statements.js";
import type { Parser } from "../Parser.js";

/**
 * Um StatementParser sabe reconhecer e consumir UM tipo de statement.
 * Mesmo padrão dos Readers do lexer: canParse olha sem consumir, parse
 * avança o cursor do Parser e devolve o nó da AST.
 */
export interface StatementParser {
  /**
   * Retorna true se este parser sabe lidar com o token atual.
   * Normalmente checa se o token é uma keyword específica ('if', 'while', etc.).
   */
  canParse(token: Token): boolean;

  /**
   * Consome os tokens do statement e devolve o nó AST correspondente.
   * Deve consumir também o NEWLINE/DEDENT que fecha o statement.
   */
  parse(parser: Parser): Statement;
}
