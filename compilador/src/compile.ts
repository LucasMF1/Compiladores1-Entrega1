import { Lexer } from "./lexer/Lexer.js";
import { Token } from "./lexer/Token.js";
import { Parser } from "./parser/Parser.js";

export function compilar(fonte: string): string {
  // TODO: implementar compilação Python -> JavaScript

  // análise léxica
  const tokens = new Lexer(fonte).tokenize();
  console.log(JSON.stringify(tokens.map((t: Token) => t.toString())));

  // análise sintática
  const ast = new Parser(tokens).parse();
  console.log(JSON.stringify(ast, null, 2));

  return fonte;
}
