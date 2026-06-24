function calcular() {
    let interno = 10;
    return interno;
}

// Erro semântico esperado: 'interno' não existe no escopo global
let x = interno + 5;