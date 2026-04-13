import type { Reader } from "./Reader.js";
import { Token } from "../Token.js";
import { TokenType } from "../TokenType.js";
import type { Lexer } from "../Lexer.js";

const PALAVRAS_RESERVADAS = new Set([
  "def", "if", "while", "for", "match", "case", "break", "pass",
  "try", "except", "import", "as", "return", "in", "not",
  "None", "True", "False",
]);

export class IdentifierReader implements Reader {
  /**
   * Retorna true se o caractere pode iniciar um identificador.
   * Em Python, identificadores começam com letra (a-z, A-Z) ou underscore (_).
   * Dígitos NÃO são aceitos na primeira posição (senão conflita com NumberReader).
   */
  canRead(char: string): boolean {
    // TODO: retornar true se char é letra ou '_'
    return false;
  }

  /**
   * Consome o identificador completo a partir da posição atual do lexer.
   * Passos:
   *   1. Guardar line/column iniciais (lexer.getLine(), lexer.getColumn()).
   *   2. Acumular caracteres enquanto forem letra, dígito ou '_' — usar
   *      lexer.peek() + lexer.advance() em loop.
   *   3. Montar o lexema completo da sequência consumida.
   *   4. Se o lexema está em PALAVRAS_RESERVADAS, emitir TokenType.KEYWORD;
   *      caso contrário, TokenType.IDENTIFIER.
   */
  read(lexer: Lexer): Token {
    // TODO: implementar conforme descrito acima
    throw new Error("IdentifierReader.read not implemented");
  }
}
