//vetor de símbolos/termos ("vocabulário de linguagem")
//os que a gente definiu em sala (não entendi por que tinha operadores aqui também,
// daí eu tirei e continuou dando certo então acho que tava redundante rs)
const simbolos = [
    "def", "{nome_funcao}", "(", "{nome_variavel}",
    ",", ")", ":", "[", "]", "{", "}", "if",
    "while", "for", "match", "case", "break", "pass", "try", "not", "in", "None", "True", "False", "return", "", "import", "as", "except",
    ""
];

//lista específica só de operadores
const operadores = [
    "=", "+", "-", "*", "/",
    "!=", "==", ">", "<", ">=", "<=",
    "+=", "-=", "*=", "/=",
];

//função que recebe o código fonte como string
function analisadorLexico(fonte: string): any {

//o regex define o que é um token "válido" (lembrar da explicação do otavio) -> reconhece keywords

const regex = /\b(def|if|while|for|match|case|break|pass|try|except|import|as|return|in|not|None|True|False)\b|!=|==|>=|<=|\+=|\-=|\*=|\/=|>|<|[+\-*/=:,.()\[\]{}]|\b\d+(?:\.\d+)?\b|"[^"]*"|'[^']*'|\b[a-zA-Z_]\w*\b/g;

let tokens = fonte.match(regex) || []; //aplica o regex

let tokensEspecificados: any = [];

//mudei aqui pra ficar mais legível e facilitar pro parser (que a gente comentou na sala) e no fim das contas era of e não in mesmo rsrs
for (let token of tokens) {
    if (operadores.includes(token)) {
        tokensEspecificados.push({ tipo: "OPERADOR", valor: token }); //vê se é operador
    } else if (!isNaN(Number(token))) {
        tokensEspecificados.push({ tipo: "NUMERO", valor: token }); //vê se é número
    } else {
        tokensEspecificados.push({ tipo: "IDENTIFICADOR", valor: token }); //se não for operador ou número, é identificador (variável, função...)
    }
}
return tokensEspecificados;
}

export function compilar(fonte: string): string {
    //aqui entra o código pra fazer Python -> JavaScript

    // análise léxica
    let tokensLexicos = analisadorLexico(fonte);

    console.log(tokensLexicos); //debug

    return fonte;
}


//deu certo :)) botei pra testar no compile.ts com o run que já tem aí, daí voltei pra como tava, mas retornou:

/*

[
  { tipo: 'IDENTIFICADOR', valor: 'import' },
  { tipo: 'IDENTIFICADOR', valor: 'numpy' },
  { tipo: 'IDENTIFICADOR', valor: 'import' },
  { tipo: 'IDENTIFICADOR', valor: 'pandas' },
  { tipo: 'IDENTIFICADOR', valor: 'as' },
  { tipo: 'IDENTIFICADOR', valor: 'p' },
  { tipo: 'IDENTIFICADOR', valor: 'def' },
  { tipo: 'IDENTIFICADOR', valor: 'funcaoQualquer' },
  { tipo: 'IDENTIFICADOR', valor: '(' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'IDENTIFICADOR', valor: ',' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'IDENTIFICADOR', valor: ',' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: ')' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'print' },
  { tipo: 'IDENTIFICADOR', valor: '(' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'IDENTIFICADOR', valor: ',' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'IDENTIFICADOR', valor: ',' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: ')' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'OPERADOR', valor: '=' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'OPERADOR', valor: '+' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'OPERADOR', valor: '=' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'OPERADOR', valor: '*' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'OPERADOR', valor: '=' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'OPERADOR', valor: '/' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: 'd' },
  { tipo: 'OPERADOR', valor: '=' },
  { tipo: 'IDENTIFICADOR', valor: '[' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'IDENTIFICADOR', valor: ',' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'IDENTIFICADOR', valor: ',' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: ']' },
  { tipo: 'IDENTIFICADOR', valor: 'e' },
  { tipo: 'OPERADOR', valor: '=' },
  { tipo: 'IDENTIFICADOR', valor: '{' },
  { tipo: 'IDENTIFICADOR', valor: '"qualquer"' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'c' },
  { tipo: 'IDENTIFICADOR', valor: '}' },
  { tipo: 'IDENTIFICADOR', valor: 'd' },
  { tipo: 'IDENTIFICADOR', valor: '.' },
  { tipo: 'IDENTIFICADOR', valor: 'append' },
  { tipo: 'IDENTIFICADOR', valor: '(' },
  { tipo: 'NUMERO', valor: '2' },
  { tipo: 'IDENTIFICADOR', valor: ')' },
  { tipo: 'IDENTIFICADOR', valor: 'd' },
  { tipo: 'IDENTIFICADOR', valor: '.' },
  { tipo: 'IDENTIFICADOR', valor: 'remove' },
  { tipo: 'IDENTIFICADOR', valor: '(' },
  { tipo: 'NUMERO', valor: '2' },
  { tipo: 'IDENTIFICADOR', valor: ')' },
  { tipo: 'IDENTIFICADOR', valor: 'e' },
  { tipo: 'IDENTIFICADOR', valor: '[' },
  { tipo: 'IDENTIFICADOR', valor: '"qualquer"' },
  { tipo: 'IDENTIFICADOR', valor: ']' },
  { tipo: 'OPERADOR', valor: '=' },
  { tipo: 'NUMERO', valor: '2.2' },
  { tipo: 'IDENTIFICADOR', valor: 'try' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'raise' },
  { tipo: 'IDENTIFICADOR', valor: 'Exception' },
  { tipo: 'IDENTIFICADOR', valor: '(' },
  { tipo: 'IDENTIFICADOR', valor: ')' },
  { tipo: 'IDENTIFICADOR', valor: 'except' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'pass' },
  { tipo: 'IDENTIFICADOR', valor: 'match' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'case' },
  { tipo: 'NUMERO', valor: '1' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'pass' },
  { tipo: 'IDENTIFICADOR', valor: 'case' },
  { tipo: 'NUMERO', valor: '2' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'pass' },
  { tipo: 'IDENTIFICADOR', valor: 'case' },
  { tipo: 'IDENTIFICADOR', valor: 'b' },
  { tipo: 'IDENTIFICADOR', valor: ':' },
  { tipo: 'IDENTIFICADOR', valor: 'pass' },
  { tipo: 'IDENTIFICADOR', valor: 'if' },
  { tipo: 'IDENTIFICADOR', valor: 'a' },
  { tipo: 'OPERADOR', valor: '>' },
  ... 55 more items
]

*/
