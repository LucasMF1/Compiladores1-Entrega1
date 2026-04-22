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
OUT_DIR="$ROOT_DIR/build/test_output"

# -----------------------------------------------------------------------------
# Uso:
#   ./test.sh            # casos em testes_js_to_python/validos e /invalidos
#   ./test.sh parser     # casos em testes_js_to_python/parser/validos|invalidos
#   ./test.sh lexer      # casos em testes_js_to_python/lexer/validos|invalidos
#   ./test.sh -v parser  # verbose: mostra stderr tambem em casos OK
# -----------------------------------------------------------------------------
VERBOSE=0
while [ $# -gt 0 ]; do
    case "$1" in
        -v|--verbose) VERBOSE=1; shift ;;
        -h|--help)
            sed -n '1,/^# ======/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) break ;;
    esac
done
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

PASS=0
FAIL=0

# Imprime stderr do compilador com prefixo "      | " para alinhar sob o nome.
print_stderr () {
    local saida="$1"
    if [ -n "$saida" ]; then
        printf '%s\n' "$saida" | sed 's/^/      | /'
    else
        echo "      | (sem saida de erro)"
    fi
}

run_case () {
    local arquivo="$1"
    local esperado="$2"  # "valid" ou "invalid"
    local categoria="$3" # "validos" ou "invalidos"
    local nome status stderr_output rc out_subdir stdout_file stderr_file status_file
    nome="$(basename "$arquivo")"

    out_subdir="$OUT_DIR${PHASE:+/$PHASE}/$categoria"
    mkdir -p "$out_subdir"
    stdout_file="$out_subdir/$nome.stdout"
    stderr_file="$out_subdir/$nome.stderr"
    status_file="$out_subdir/$nome.status"

    # Executa capturando stdout e stderr em arquivos separados para debug.
    # Na fase "lexer", roda em modo --lex para imprimir os tokens em stdout.
    if [ "$PHASE" = "lexer" ]; then
        "$BIN" --lex "$arquivo" >"$stdout_file" 2>"$stderr_file"
    else
        "$BIN" "$arquivo" >"$stdout_file" 2>"$stderr_file"
    fi
    rc=$?
    stderr_output="$(cat "$stderr_file")"

    if [ $rc -eq 0 ]; then
        status="valid"
    else
        status="invalid"
    fi

    {
        echo "arquivo: $arquivo"
        echo "esperado: $esperado"
        echo "obtido: $status"
        echo "exit_code: $rc"
    } >"$status_file"

    printf "  %-60s " "$nome"
    if [ "$status" = "$esperado" ]; then
        echo "OK ($status)"
        PASS=$((PASS + 1))
        if [ "$VERBOSE" = "1" ]; then
            print_stderr "$stderr_output"
        fi
    else
        echo "FALHOU (esperado $esperado, obtido $status)"
        FAIL=$((FAIL + 1))
        print_stderr "$stderr_output"
    fi
}

# Limpa saidas anteriores desta fase para nao confundir o debug.
rm -rf "$OUT_DIR${PHASE:+/$PHASE}"

echo "== Casos validos${PHASE:+ ($PHASE)} =="
for arq in "$CASES_DIR"/validos/*.js; do
    [ -e "$arq" ] || continue
    run_case "$arq" valid validos
done

if [ -d "$CASES_DIR/invalidos" ]; then
    echo "== Casos invalidos${PHASE:+ ($PHASE)} =="
    for arq in "$CASES_DIR"/invalidos/*.js; do
        [ -e "$arq" ] || continue
        run_case "$arq" invalid invalidos
    done
fi

echo
echo "== Resumo =="
echo "  Passou: $PASS"
echo "  Falhou: $FAIL"
echo "  Saidas em: $OUT_DIR${PHASE:+/$PHASE}"
[ "$FAIL" -eq 0 ]
