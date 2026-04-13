import { TokenType } from "./TokenType.js";

export class Token {
  constructor(
    public readonly type: TokenType,
    public readonly lexeme: string,
    public readonly line: number,
    public readonly column: number,
  ) {}

  toString(): string {
    return `${this.type}(${this.lexeme}) @ ${this.line}:${this.column}`;
  }
}
