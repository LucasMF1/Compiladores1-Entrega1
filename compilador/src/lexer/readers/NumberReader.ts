import type { Reader } from "./Reader.js";
import { Token } from "../Token.js";
import { TokenType } from "../TokenType.js";
import type { Lexer } from "../Lexer.js";

export class NumberReader implements Reader {
  /**
   * Retorna true se o caractere pode iniciar um literal numérico.
   * Aceita apenas dígitos 0-9 na primeira posição — o ponto decimal só é
   * válido depois do primeiro dígito (ex.: "3.14" sim, ".5" não neste lexer).
   */
  canRead(char: string): boolean {
    // TODO: retornar true se char está entre '0' e '9'
    return false;
  }

  /**
   * Consome um literal numérico (inteiro ou float) a partir da posição atual.
   * Passos:
   *   1. Guardar line/column iniciais.
   *   2. Consumir todos os dígitos seguidos (parte inteira).
   *   3. Se o próximo caractere for '.' E o seguinte for dígito, consumir o '.'
   *      e todos os dígitos da parte fracionária. Cuidado: não consumir '.' se
   *      o que vem depois não for dígito (ex.: "obj.foo" não é número).
   *   4. Emitir TokenType.NUMBER com o lexema completo.
   */
  read(lexer: Lexer): Token {
    // TODO: implementar conforme descrito acima
    throw new Error("NumberReader.read not implemented");
  }
}
