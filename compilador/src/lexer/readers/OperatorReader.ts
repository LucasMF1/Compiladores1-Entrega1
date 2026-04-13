import type { Reader } from "./Reader.js";
import { Token } from "../Token.js";
import { TokenType } from "../TokenType.js";
import type { Lexer } from "../Lexer.js";

export class OperatorReader implements Reader {
  /**
   * Retorna true se o caractere pode iniciar um operador.
   * Caracteres aceitos: '=', '+', '-', '*', '/', '<', '>', '!'.
   * Note que '!' sozinho NÃO é operador válido em Python — ele só existe como
   * parte de '!='. A validação final fica no read().
   */
  canRead(char: string): boolean {
    // TODO: retornar true se char é um dos caracteres listados acima
    return false;
  }

  /**
   * Consome um operador a partir da posição atual, priorizando o casamento
   * mais longo (maximal munch): '==' antes de '=', '!=' antes de '!', etc.
   * Passos:
   *   1. Guardar line/column iniciais.
   *   2. Ler o primeiro caractere (lexer.advance()).
   *   3. Se o próximo é '=' E o primeiro forma um operador composto válido
   *      (==, !=, <=, >=, +=, -=, *=, /=), consumir também com lexer.match('=').
   *   4. Validar que o lexema resultante é um operador real — se for apenas
   *      '!' sozinho, lançar erro léxico.
   *   5. Emitir TokenType.OPERATOR com o lexema final.
   */
  read(lexer: Lexer): Token {
    // TODO: implementar conforme descrito acima
    throw new Error("OperatorReader.read not implemented");
  }
}
