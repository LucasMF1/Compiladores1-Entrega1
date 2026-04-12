# Testes iniciais do compilador

Os casos de teste iniciais ficam organizados em:

- `cases.json`: catalogo com descricao, validade da entrada e expectativa.
- `validos/`: entradas aceitas pelo subconjunto atual e a saida esperada.
- `invalidos/`: entradas rejeitadas e a mensagem de erro esperada.

## Como executar

Dentro de `compilador/`:

```bash
npm run tests
```

## Convencoes atuais

- Casos `valid` informam `input` e `expectedOutput`.
- Casos `invalid` informam `input` e `expectedError`.
- No estado atual do projeto, casos validos ainda preservam o codigo-fonte original como saida esperada.
- Casos invalidos cobrem erros lexicos do subconjunto suportado neste momento.

## Cobertura inicial

- imports e aliases
- definicao de funcao
- atribuicoes e operadores compostos
- listas e dicionarios
- condicionais, lacos, `break`, `pass`, `try/except`, `match/case`
- rejeicao de caracteres fora do subconjunto suportado
