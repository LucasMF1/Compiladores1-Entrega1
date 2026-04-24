// Caracteres fora do subconjunto aceito devem disparar erro lexico.
ç
à

// Simbolos exoticos no meio de identificadores.
x ¬ y
x ¢ y
x £ y
x ¥ y
x ³ y
x ² y
x³
x²
x ª y
x º y
x ¿ y
x ¡ y
x ° y
x ¶ y
x § y
x ♦ y
x © y
x ® y
x ◘ y
x ◙ y
x ☺ y
x ☻ y
x ♥ y
x ♦ y
x ♣ y
x ♠ y

// Simbolos isolados que este conjunto de testes marca como invalidos.
x @ y 
x # y
x $ y
x ~ y
x % y
x ^ y
x | y
x ? y
x : y

// Variantes que parecem atribuicao tambem devem falhar aqui.
x @= 1
x #= 1
x $= 1
x ~= 1
x %= 1
x ^= 1
x |= 1
x ?= 1
x := 1

// Backtick solto, aspas sem fechamento correto e barra invertida isolada.
x ` y
x " y 
x \ y
