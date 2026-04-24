// Cobre os statements estruturais principais aceitos pela gramática.
if (ativo) { total = total + 1; } else { total = 0; }

// Garante que while aceita comparação no cabeçalho e bloco com atribuição composta.
while (indice < limite) { indice += 1; }

// Garante que for aceita inicialização, condição e incremento separados por ';'.
for (let i = 0; i < 10; i += 1) { soma += i; }
