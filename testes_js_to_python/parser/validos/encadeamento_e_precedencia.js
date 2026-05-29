let resultado;
let obj;
let a = 1;
let b = 2;
let ativo = true;
let pronto = false;
let extra = true;
let flag;
let c = 3;
let d = 4;
let e = 5;
let valor;


// Chamada de função seguida de indexação no resultado.
resultado = obj.soma(a, b)[0];

// Confere precedência entre !, && e || na mesma expressão.
flag = !ativo || pronto && extra;

// Parênteses devem alterar a associação natural das operações aritméticas.
valor = (a + b) * (c - d) / e;
