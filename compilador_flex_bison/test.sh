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
# Fase a ser testada: lexer | parser | integracao | "" (raiz).
# Uso:
#   ./test.sh            # casos em testes_js_to_python/validos e /invalidos
#   ./test.sh parser     # casos em testes_js_to_python/parser/validos|invalidos
#   ./test.sh lexer      # casos em testes_js_to_python/lexer/validos|invalidos
#   ./test.sh integracao # casos em testes_js_to_python/integracao/validos|invalidos
# -----------------------------------------------------------------------------
PHASE="${1:-}"
if [ -n "$PHASE" ]; then
    CASES_DIR="$TESTES_DIR/$PHASE"
    if [ ! -d "$CASES_DIR" ]; then
        echo "Fase desconhecida: '$PHASE' (diretorio $CASES_DIR nao existe)"
        echo "Fases disponiveis:"
        for d in "$TESTES_DIR"/*/; do
            [ -d "$d" ] || continue
            name="$(basename "$d")"
            case "$name" in validos|invalidos) continue ;; esac
            echo "  - $name"
        done
        exit 1
    fi
else
    CASES_DIR="$TESTES_DIR"
fi

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

echo "== Casos validos${PHASE:+ ($PHASE)} =="
for arq in "$CASES_DIR"/validos/*.js; do
    [ -e "$arq" ] || continue
    run_case "$arq" valid
done

if [ -d "$CASES_DIR/invalidos" ]; then
    echo "== Casos invalidos${PHASE:+ ($PHASE)} =="
    for arq in "$CASES_DIR"/invalidos/*.js; do
        [ -e "$arq" ] || continue
        run_case "$arq" invalid
    done
fi
