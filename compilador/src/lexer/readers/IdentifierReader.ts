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
    return /[a-zA-Z_]/.test(char);
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
    const line = lexer.getLine();
    const column = lexer.getColumn();

    let lexema = "";
    while (!lexer.isAtEnd() && /[a-zA-Z0-9_]/.test(lexer.peek())) {
      lexema += lexer.advance();
    }

    const type = PALAVRAS_RESERVADAS.has(lexema)
      ? TokenType.KEYWORD
      : TokenType.IDENTIFIER;

    return new Token(type, lexema, line, column);
  }
}
