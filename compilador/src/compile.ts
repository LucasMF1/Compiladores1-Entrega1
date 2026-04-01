


const simbolos = [
  "def", "{nome_funcao}", "(", "{nome_variavel}",
  ",", ")", ":", "=", "+", "*", "/", "[", "]", "{", "}", "if",
  "while", "for", "match", "case", "break", "pass", "try", "not","in", "!=",
  "==", ">", "<", ">=", "<=", "+=", "*=", "/=", "-=", "None", "True", "False", "return", "", "import", "as", "except",
  ""
];

function analisadorLexico(fonte: string): any {

  const regex = /\b(def|if|while|for|match|case|break|pass|try|except|import|as|return|in|not|None|True|False)\b|!=|==|>=|<=|\+=|\-=|\*=|\/=|>|<|[+\-*/=:,.()\[\]{}]|\b\d+(?:\.\d+)?\b|"[^"]*"|'[^']*'|\b[a-zA-Z_]\w*\b/g;

  return fonte.match(regex) || [];
}

export function compilar(fonte: string): string {
  // TODO: implementar compilação Python -> JavaScript


  // análise léxica
  let tokensLexicos = analisadorLexico(fonte);

  console.log(JSON.stringify(tokensLexicos));


  return fonte;
}
