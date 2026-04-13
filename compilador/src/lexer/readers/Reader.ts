import type { Token } from "../Token.js";
import type { Lexer } from "../Lexer.js";

export interface Reader {
  canRead(char: string): boolean;
  read(lexer: Lexer): Token;
}
