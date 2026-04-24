// Identificador simples.
x

// Nome alfabetico comum.
nome

// Nome sem caracteres especiais, ainda valido.
contador

// Prefixo com underscore deve ser aceito.
_privado

// Sufixo numerico eh permitido apos a primeira letra.
valor1

// Snake case deve continuar valido.
minha_variavel

// CamelCase deve ser lido como IDENTIFIER, nao como keyword.
CamelCase

// Dois underscores iniciais tambem entram na regex de identificador.
__init__

// Palavra parecida com keyword, mas diferente, deve cair como IDENTIFIER.
define

// Prefixo de "for" nao transforma o lexema em keyword.
fort

// Palavra contendo "while" mas maior que a keyword deve seguir como IDENTIFIER.
whileTrue
