import { Lexer } from "./lexer/Lexer.js";
import { Token } from "./lexer/Token.js";

export function compilar(fonte: string): string {
  // TODO: implementar compilação Python -> JavaScript

  // análise léxica
  const tokens = new Lexer(fonte).tokenize();

  console.log(JSON.stringify(tokens.map((t: Token) => t.toString())));

  return fonte;
}
