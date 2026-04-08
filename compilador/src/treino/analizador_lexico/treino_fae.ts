// primeiro teste do analisador léxico, tentando entender a lógica >(

//
// x = 5
// y = 6
// h = 4
//def chamadas(x, y):
//    for i in range(h):
//          x + y
//    return x,y
//
// print(x, y)
//
//

const chamadas = ["{variavel}", "def", "{funcao}", "for", "in", "range", "return", "print", "case","break","pass", "try", "while", "match","except", "import","as","None","True","False","in"];

const operadores = ["=", "==", "+", "-", "*", "/", "%", "!=", ">","<",">=","<=", "*=", "/="];

const delimitadores = ["(",")", ":", ",", "|"]

// defino a função do analisador léxico com os tokens do regex,
// e faço a verificação correta

function lexAnalisador(fonte: string): any{

    const regex = /\b(def|if|while|for|match|case|break|pass|try|except|import|as|return|in|not|None|True|False)\b|!=|==|>=|<=|\+=|\-=|\*=|\/=|>|<|[+\-*/=:,.()\[\]{}]|\b\d+(?:\.\d+)?\b|"[^"]*"|'[^']*'|\b[a-zA-Z_]\w*\b/g;

    let tokens = fonte.match(regex) || []; // o regex vai ser recolhido junto da fonte givada dentro do "lexanalisador", fazendo a lista de tokens

    let tokensEspecificos: any = []; 

    for(let token of tokens){
        if(chamadas.includes(token)){
            tokensEspecificos.push({tipo : "CHAMADA", valor:token }); //confere se é uma chamada do pyhton, como "def"
        }
        else if(operadores.includes(token)){
            tokensEspecificos.push({tipo : "OPERADOR", valor:token }); //confere se é uim operador *, +, =
        } else if(delimitadores.includes(token)){
            tokensEspecificos.push({tipo: "DELIMITADOR", valor:token}); //confere se é um delimitador (), :, etc
        } else if(!isNaN(Number(token))){
            tokensEspecificos.push({tipo: "NUMERO", valor:token}); //confere se é um número
        } else{
            tokensEspecificos.push({tipo: "IDENTIFICADOR", valor:token});// se nn for nenhum acima, é um identificador (variavel)
        }
    }

    return tokensEspecificos;
}

export function teste(fonte: string) {

    let tokensLexicos = lexAnalisador(fonte);

    console.log(tokensLexicos);

}