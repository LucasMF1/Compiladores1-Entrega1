import type { Reader } from "./Reader.js";
import { Token } from "../Token.js";
import { TokenType } from "../TokenType.js";
import type { Lexer } from "../Lexer.js";

export class StringReader implements Reader {
  /**
   * Retorna true se o caractere inicia um literal de string.
   * Python aceita tanto aspas simples (') quanto duplas (") — ambas produzem
   * o mesmo tipo de token, só precisam casar no início e no fim.
   */
  canRead(char: string): boolean {
    return char === '"' || char === "'";
  }

  /**
   * Consome um literal de string a partir da posição atual.
   * Passos:
   *   1. Guardar line/column iniciais e a aspa de abertura (lexer.advance()).
   *   2. Acumular caracteres até encontrar a MESMA aspa de abertura.
   *      — Se for '"', só fecha com '"'; idem para "'".
   *   3. Se chegar ao fim do arquivo (lexer.isAtEnd()) sem achar o fechamento,
   *      lançar erro de string não terminada com line/column iniciais.
   *   4. Consumir a aspa final (lexer.advance()) e emitir TokenType.STRING.
   *
   * Observação: o lexema pode incluir ou não as aspas — escolha uma convenção
   * e mantenha. Sugestão: guardar APENAS o conteúdo interno (sem as aspas).
   */
  read(lexer: Lexer): Token {
    const line = lexer.getLine();
    const column = lexer.getColumn();
    const quote = lexer.advance();

    let lexema = "";
    while (!lexer.isAtEnd() && lexer.peek() !== quote) {
      if (lexer.peek() === "\n") {
        throw new Error(`String não terminada em ${line}:${column}`);
      }
      lexema += lexer.advance();
    }

    if (lexer.isAtEnd()) {
      throw new Error(`String não terminada em ${line}:${column}`);
    }

    lexer.advance();

    return new Token(TokenType.STRING, lexema, line, column);
  }
}
