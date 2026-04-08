// O analisador léxico pega o código-fonte e quebra em tokens.
// Tokens são pedaços importantes para o compilador entender o código.

const palavrasReservadas = [
  "def", "if", "while", "for", "match", "case", "break", "pass",
  "try", "except", "import", "as", "return", "in", "not",
  "None", "True", "False",
];

const operadores = [
  "=", "+", "-", "*", "/",
  "!=", "==", ">", "<", ">=", "<=",
  "+=", "-=", "*=", "/=",
];

const delimitadores = ["(", ")", ":", ",", ".", "[", "]", "{", "}"];

// O regex reconhece palavras reservadas, operadores, números,
// strings e identificadores.
const regex =
  /\b(def|if|while|for|match|case|break|pass|try|except|import|as|return|in|not|None|True|False)\b|!=|==|>=|<=|\+=|\-=|\*=|\/=|>|<|[+\-*/=:,.()\[\]{}]|\b\d+(?:\.\d+)?\b|"[^"]*"|'[^']*'|\b[a-zA-Z_]\w*\b/g;

function analisadorLexico(fonte: string): any {
  let tokens = fonte.match(regex) || [];
  let tokensEspecificados: any = [];

  // Aqui classificamos cada token encontrado.
  for (let token of tokens) {
    if (palavrasReservadas.includes(token)) {
      tokensEspecificados.push({ tipo: "PALAVRA_RESERVADA", valor: token });
    } else if (operadores.includes(token)) {
      tokensEspecificados.push({ tipo: "OPERADOR", valor: token });
    } else if (delimitadores.includes(token)) {
      tokensEspecificados.push({ tipo: "DELIMITADOR", valor: token });
    } else if (!isNaN(Number(token))) {
      tokensEspecificados.push({ tipo: "NUMERO", valor: token });
    } else if (
      (token.startsWith('"') && token.endsWith('"')) ||
      (token.startsWith("'") && token.endsWith("'"))
    ) {
      tokensEspecificados.push({ tipo: "CADEIA", valor: token });
    } else {
      // Se não for nenhum caso acima, tratamos como nome de variável/função.
      tokensEspecificados.push({ tipo: "IDENTIFICADOR", valor: token });
    }
  }

  return tokensEspecificados;
}

export function compilar(fonte: string): string {
  let tokensLexicos = analisadorLexico(fonte);

  console.log(JSON.stringify(tokensLexicos, null, 2));

  return fonte;
}
