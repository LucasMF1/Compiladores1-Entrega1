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
#   ./test.sh ast        # casos em testes_js_to_python/ast/validos (+ .ast esperado)
#   ./test.sh semantic   # casos em testes_js_to_python/semantic/validos|invalidos
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
# Compila antes de testar. Se build.sh falhar, ele proprio exibe instrucoes
# de instalacao de flex/bison/cc.
# -----------------------------------------------------------------------------
echo "== Build =="
"$ROOT_DIR/build.sh" || exit $?

if [ ! -x "$BIN" ]; then
    echo "Build reportou sucesso mas binario nao existe em: $BIN" >&2
    exit 1
fi
echo

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
    local expected_err_file expected_ast_file expected_tokens_file expected_err mismatch
    nome="$(basename "$arquivo")"

    out_subdir="$OUT_DIR${PHASE:+/$PHASE}/$categoria"
    mkdir -p "$out_subdir"
    stdout_file="$out_subdir/$nome.stdout"
    stderr_file="$out_subdir/$nome.stderr"
    status_file="$out_subdir/$nome.status"
    expected_err_file="${arquivo%.js}.err"
    expected_ast_file="${arquivo%.js}.ast"
    expected_tokens_file="${arquivo%.js}.tokens"
    expected_py_file="${arquivo%.js}.expected.py"

    # Executa capturando stdout e stderr em arquivos separados para debug.
    # Na fase "lexer", roda em modo --lex para imprimir os tokens em stdout.
    if [ "$PHASE" = "lexer" ]; then
        "$BIN" --lex "$arquivo" >"$stdout_file" 2>"$stderr_file"
    elif [ "$PHASE" = "ast" ]; then
        "$BIN" --ast "$arquivo" >"$stdout_file" 2>"$stderr_file"
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

    mismatch=""
    if [ "$status" != "$esperado" ]; then
        mismatch="esperado $esperado, obtido $status"
    elif [ "$PHASE" = "lexer" ] && [ "$esperado" = "valid" ] && [ -f "$expected_tokens_file" ]; then
        if ! diff -u "$expected_tokens_file" "$stdout_file" >"$out_subdir/$nome.diff"; then
            mismatch="tokens diferentes do esperado ($(basename "$expected_tokens_file"))"
        else
            rm -f "$out_subdir/$nome.diff"
        fi
    elif [ "$PHASE" = "lexer" ] && [ "$esperado" = "invalid" ] && [ -f "$expected_err_file" ]; then
        if ! diff -u "$expected_err_file" "$stderr_file" >"$out_subdir/$nome.diff"; then
            mismatch="stderr diferente do esperado ($(basename "$expected_err_file"))"
        else
            rm -f "$out_subdir/$nome.diff"
        fi
    elif [ "$PHASE" = "parser" ] && [ -f "$expected_err_file" ]; then
        expected_err="$(cat "$expected_err_file")"

        # mudanca aqui de Fq pra Eq pra aceitar regex e as mensagens de erro ficarem mais personalizadas
        if ! grep -Eq -- "$expected_err" "$stderr_file"; then
            mismatch="stderr nao contem o trecho esperado de $(basename "$expected_err_file")"
        fi
    elif [ "$PHASE" = "semantic" ] && [ -f "$expected_err_file" ]; then
        expected_err="$(cat "$expected_err_file")"

        if ! grep -Eq -- "$expected_err" "$stderr_file"; then
            mismatch="stderr nao contem o trecho esperado de $(basename "$expected_err_file")"
        fi
    elif [ "$PHASE" = "integracao" ] && [ "$esperado" = "invalid" ] && [ -f "$expected_err_file" ]; then
        expected_err="$(cat "$expected_err_file")"

        if ! grep -Eq -- "$expected_err" "$stderr_file"; then
            mismatch="stderr nao contem o trecho esperado de $(basename "$expected_err_file")"
        fi
    elif [ "$PHASE" = "integracao" ] && [ "$esperado" = "valid" ] && [ -f "$expected_py_file" ]; then
        if ! diff -u "$expected_py_file" "$stdout_file" >"$out_subdir/$nome.diff"; then
            mismatch="saida Python diferente do esperado ($(basename "$expected_py_file"))"
        else
            rm -f "$out_subdir/$nome.diff"
        fi
    elif [ "$PHASE" = "otimizacao" ] && [ "$esperado" = "valid" ] && [ -f "$expected_py_file" ]; then
        if ! diff -u "$expected_py_file" "$stdout_file" >"$out_subdir/$nome.diff"; then
            mismatch="saida Python diferente do esperado ($(basename "$expected_py_file"))"
        else
            rm -f "$out_subdir/$nome.diff"
        fi
    elif [ "$PHASE" = "ast" ] && [ "$esperado" = "valid" ]; then
        if [ ! -f "$expected_ast_file" ]; then
            mismatch="arquivo esperado ausente: $(basename "$expected_ast_file")"
        elif ! diff -u "$expected_ast_file" "$stdout_file" >"$out_subdir/$nome.diff"; then
            mismatch="AST diferente do esperado ($(basename "$expected_ast_file"))"
        else
            rm -f "$out_subdir/$nome.diff"
        fi
    fi

    printf "  %-60s " "$nome"
    if [ -z "$mismatch" ]; then
        echo "OK ($status)"
        PASS=$((PASS + 1))
        if [ "$VERBOSE" = "1" ]; then
            print_stderr "$stderr_output"
        fi
    else
        echo "FALHOU ($mismatch)"
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
