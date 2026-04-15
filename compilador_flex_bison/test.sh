#!/usr/bin/env bash
# =============================================================================
# test.sh  --  Executa o compilador nos casos da pasta testes_js_to_python/
# =============================================================================
#
# Rodagem:
#   ./build.sh        # gera build/compilador
#   ./test.sh         # executa cada .js de testes_js_to_python/
#
# Observacao:
#   Como este e um template, o script apenas invoca o binario em cada
#   arquivo e mostra o codigo de retorno. A validacao real (comparar com
#   o .expected.py) sera adicionada quando o gerador de codigo existir.
# =============================================================================

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$ROOT_DIR/build/compilador"
TESTES_DIR="$ROOT_DIR/../testes_js_to_python"

# -----------------------------------------------------------------------------
# Mensagens caso o binario ainda nao exista.
# -----------------------------------------------------------------------------
if [ ! -x "$BIN" ]; then
    cat <<EOF
Binario nao encontrado em:
  $BIN

Rode ./build.sh primeiro. Se a compilacao falhar por falta de flex/bison,
o proprio build.sh mostra as instrucoes de instalacao para macOS, Linux e
Windows.
EOF
    exit 1
fi

run_case () {
    local arquivo="$1"
    local esperado="$2"  # "valid" ou "invalid"
    printf "  %-60s " "$(basename "$arquivo")"
    if "$BIN" "$arquivo" > /dev/null 2>&1; then
        status="valid"
    else
        status="invalid"
    fi
    if [ "$status" = "$esperado" ]; then
        echo "OK ($status)"
    else
        echo "FALHOU (esperado $esperado, obtido $status)"
    fi
}

echo "== Casos validos =="
for arq in "$TESTES_DIR"/validos/*.js; do
    [ -e "$arq" ] || continue
    run_case "$arq" valid
done

if [ -d "$TESTES_DIR/invalidos" ]; then
    echo "== Casos invalidos =="
    for arq in "$TESTES_DIR"/invalidos/*.js; do
        [ -e "$arq" ] || continue
        run_case "$arq" invalid
    done
fi
