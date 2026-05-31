let a = 10;
let b = -a;
let flag = false;

if (!flag) {
    // Bloco aninhado cria um novo escopo
    let c = a + b;
    
    {
        // Outro sub-bloco
        let d = c * 2;
    }
}