let max = 5;
let global_flag = true;
let res;

function processamentoProfundo(fator, limite) {
    let atual = 0;
    let contador = 0;

    if (global_flag) {
        while (contador < max) {
            let passo = contador * fator;

            if (passo < limite) {
                for (let j = 0; j < 3; j += 1) {
                    if (atual == 10) {
                        break;
                    } else {
                        atual += 1;
                    }
                }
            } else {
                atual = atual + passo;
                contador += 1;
                continue;
            }
            
            contador += 1;
        }
    } else {
        return 0;
    }

    return atual;
}

res = processamentoProfundo(2, 8);