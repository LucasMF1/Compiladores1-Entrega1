#!/usr/bin/env bash
# =============================================================================
# build.sh  --  Script de compilacao do compilador JavaScript -> Python
# =============================================================================
#
# O que este script faz:
#   1. Verifica se flex, bison e um compilador C estao instalados e, se
#      algum estiver faltando, mostra como instalar em macOS/Linux/Windows.
#   2. Roda o Bison sobre src/parser.y, gerando build/parser.tab.c e
#      build/parser.tab.h (este ultimo contem os codigos dos tokens que o
#      lexer precisa conhecer).
#   3. Roda o Flex sobre src/lexer.l, gerando build/lexer.yy.c.
#   4. Compila os arquivos gerados junto com src/main.c e produz o
#      executavel build/compilador.
#
# Variaveis de ambiente opcionais:
#   FLEX  -> caminho do executavel flex   (padrao: flex do PATH)
#   BISON -> caminho do executavel bison  (padrao: bison do PATH)
#   CC    -> compilador C                 (padrao: cc)
# =============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$ROOT_DIR/src"
BUILD_DIR="$ROOT_DIR/build"

FLEX="${FLEX:-flex}"
BISON="${BISON:-bison}"
CC="${CC:-cc}"

# -----------------------------------------------------------------------------
# Mensagens de instalacao por sistema operacional.
# -----------------------------------------------------------------------------
print_install_instructions () {
    local missing="$1"
    cat <<EOF

================================================================================
ERRO: "$missing" nao foi encontrado no PATH.

Instale antes de continuar:

  macOS (Homebrew):
      brew install flex bison
      # O Bison da Apple e a versao 2.3 (antiga). Para usar o do Homebrew,
      # adicione ao PATH (na sessao ou no ~/.zshrc):
      #   export PATH="/opt/homebrew/opt/bison/bin:\$PATH"   # Apple Silicon
      #   export PATH="/usr/local/opt/bison/bin:\$PATH"      # Intel

  Linux (Debian/Ubuntu):
      sudo apt update
      sudo apt install flex bison build-essential

  Linux (Fedora/RHEL):
      sudo dnf install flex bison gcc make

  Linux (Arch):
      sudo pacman -S flex bison base-devel

  Windows:
      Opcao 1 - WSL (recomendado):
          wsl --install
          # depois, dentro do WSL, seguir as instrucoes de Linux acima.
      Opcao 2 - MSYS2 (https://www.msys2.org):
          pacman -S flex bison mingw-w64-x86_64-gcc
      Opcao 3 - Chocolatey:
          choco install winflexbison3 mingw

Depois de instalar, rode novamente: ./build.sh
================================================================================
EOF
}

check_tool () {
    local tool="$1"
    local cmd="$2"
    if ! command -v "$cmd" > /dev/null 2>&1; then
        print_install_instructions "$tool"
        exit 1
    fi
}

check_tool "flex"  "$FLEX"
check_tool "bison" "$BISON"
check_tool "compilador C (cc/gcc/clang)" "$CC"

# -----------------------------------------------------------------------------
# Aviso se a versao do Bison for < 3.0 (Apple envia a 2.3).
# -----------------------------------------------------------------------------
BISON_MAJOR="$("$BISON" --version | awk 'NR==1 { print $NF }' | cut -d. -f1)"
if [ "${BISON_MAJOR:-0}" -lt 3 ]; then
    cat <<EOF
AVISO: Bison versao antiga detectada ($("$BISON" --version | head -1)).
       Algumas diretivas modernas (%define parse.error verbose, %code) nao
       funcionam. Considere instalar uma versao >= 3.0 (veja instrucoes em
       caso de erro mais abaixo).
EOF
fi

mkdir -p "$BUILD_DIR"

echo "[1/3] Gerando parser com Bison..."
"$BISON" -d -o "$BUILD_DIR/parser.tab.c" "$SRC_DIR/parser.y"

echo "[2/3] Gerando lexer com Flex..."
"$FLEX" -o "$BUILD_DIR/lexer.yy.c" "$SRC_DIR/lexer.l"

echo "[3/3] Compilando executavel..."
"$CC" -std=c11 -D_POSIX_C_SOURCE=200809L -Wall -Wno-unused-function \
    -I"$SRC_DIR" -I"$BUILD_DIR" \
    "$BUILD_DIR/parser.tab.c" \
    "$BUILD_DIR/lexer.yy.c"   \
    "$SRC_DIR/main.c"         \
    "$SRC_DIR/symbol_table.c" \
    "$SRC_DIR/ast.c"          \
    -o "$BUILD_DIR/compilador"

echo "OK -> $BUILD_DIR/compilador"
