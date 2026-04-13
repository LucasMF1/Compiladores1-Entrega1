import type { Reader } from "./Reader.js";
import { Token } from "../Token.js";
import { TokenType } from "../TokenType.js";
import type { Lexer } from "../Lexer.js";

export class PunctuationReader implements Reader {
  /**
   * Retorna true se o caractere é um símbolo de pontuação de um único
   * caractere: '(', ')', '[', ']', '{', '}', ',', ':', '.'.
   * Diferente dos operadores, estes nunca se combinam em sequências de dois,
   * então o parsing é trivial.
   */
  canRead(char: string): boolean {
    // TODO: retornar true se char está no conjunto acima
    return false;
  }

  /**
   * Consome exatamente UM caractere e emite um TokenType.PUNCTUATION.
   * Passos:
   *   1. Guardar line/column antes de avançar.
   *   2. Consumir o caractere com lexer.advance().
   *   3. Retornar o Token com o lexema de um caractere.
   */
  read(lexer: Lexer): Token {
    // TODO: implementar conforme descrito acima
    throw new Error("PunctuationReader.read not implemented");
  }
}
