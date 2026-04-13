import { Token } from "./Token.js";
import { TokenType } from "./TokenType.js";
import type { Reader } from "./readers/Reader.js";
import { IdentifierReader } from "./readers/IdentifierReader.js";
import { NumberReader } from "./readers/NumberReader.js";
import { StringReader } from "./readers/StringReader.js";
import { OperatorReader } from "./readers/OperatorReader.js";
import { PunctuationReader } from "./readers/PunctuationReader.js";

export class Lexer {
  private pos = 0;
  private line = 1;
  private column = 1;

  // Pilha de níveis de indentação (em número de espaços).
  // Começa com 0 — o "nível do topo do arquivo".
  // Cada INDENT empilha um novo nível; cada DEDENT desempilha.
  private indentStack: number[] = [0];

  // true quando estamos no início de uma linha lógica e ainda não processamos
  // a indentação dela. Vira false assim que o primeiro token "de verdade" sai.
  private atLineStart = true;

  private readonly readers: Reader[] = [
    new IdentifierReader(),
    new NumberReader(),
    new StringReader(),
    new OperatorReader(),
    new PunctuationReader(),
  ];

  constructor(private readonly source: string) {}

  tokenize(): Token[] {
    const tokens: Token[] = [];

    while (!this.isAtEnd()) {
      // Início de linha lógica: processar indentação ANTES de qualquer outro
      // token. Pode emitir INDENT, um ou mais DEDENTs, ou nada.
      if (this.atLineStart) {
        this.handleIndentation(tokens);
        this.atLineStart = false;
        if (this.isAtEnd()) break;
      }

      // Pular espaços/tabs NO MEIO da linha (não afetam indentação).
      this.skipInlineWhitespace();
      if (this.isAtEnd()) break;

      const char = this.peek();

      // Fim de linha lógica: emite NEWLINE e marca que a próxima iteração
      // precisa processar indentação.
      if (char === "\n") {
        tokens.push(new Token(TokenType.NEWLINE, "\\n", this.line, this.column));
        this.advance();
        this.atLineStart = true;
        continue;
      }

      const reader = this.readers.find((r) => r.canRead(char));
      if (!reader) {
        throw new Error(
          `Caractere inesperado '${char}' em ${this.line}:${this.column}`,
        );
      }

      tokens.push(reader.read(this));
    }

    // No EOF, fechar todos os níveis de indentação pendentes com DEDENTs.
    while (this.indentStack.length > 1) {
      this.indentStack.pop();
      tokens.push(new Token(TokenType.DEDENT, "", this.line, this.column));
    }

    tokens.push(new Token(TokenType.EOF, "", this.line, this.column));
    return tokens;
  }

  /**
   * Processa a indentação no início de uma linha lógica.
   *
   * Algoritmo:
   *   1. Contar espaços/tabs na frente da linha (indent atual).
   *   2. Se a linha for VAZIA (só espaços + '\n') ou for comentário, ignorar
   *      — linhas em branco não mudam o nível de indentação.
   *   3. Comparar com o topo da pilha:
   *      - indent > topo  → empilhar, emitir INDENT.
   *      - indent == topo → nada.
   *      - indent < topo  → desempilhar até achar um nível igual, emitindo um
   *                         DEDENT por pop. Se não achar nível igual, erro
   *                         ("indentação inconsistente").
   */
  private handleIndentation(tokens: Token[]): void {
    // TODO: implementar conforme algoritmo descrito acima.
    // Placeholder: só pula espaços/tabs sem emitir tokens de indentação.
    this.skipInlineWhitespace();
  }

  private skipInlineWhitespace(): void {
    while (!this.isAtEnd()) {
      const c = this.peek();
      if (c === " " || c === "\t" || c === "\r") {
        this.advance();
      } else {
        break;
      }
    }
  }

  peek(offset = 0): string {
    return this.source[this.pos + offset] ?? "";
  }

  advance(): string {
    const char = this.source[this.pos++];
    if (char === "\n") {
      this.line++;
      this.column = 1;
    } else {
      this.column++;
    }
    return char || "";
  }

  match(expected: string): boolean {
    if (this.peek() !== expected) return false;
    this.advance();
    return true;
  }

  isAtEnd(): boolean {
    return this.pos >= this.source.length;
  }

  getLine(): number {
    return this.line;
  }

  getColumn(): number {
    return this.column;
  }

}
