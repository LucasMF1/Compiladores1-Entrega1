/*
 * ===========================================================================
 * parser.y  --  Analisador sintatico (Bison) do compilador JS -> Python
 * ===========================================================================
 *
 * Cada producao constroi um no da AST e propaga via $$. A raiz fica em
 * `ast_root` (definida em ast.c) ao final do parse.
 *
 * Ownership de strings: o lexer entrega cada lexema (IDENTIFIER/STRING)
 * como char* malloc'd. Aqui passamos esse ponteiro direto para o construtor
 * de no, que assume posse e libera em ast_free(). Por isso nao chamamos
 * mais free($n) nas acoes.
 * ===========================================================================
 */

%{
#include "common.h"
%}

%locations
%define parse.error verbose

/* Usamos `struct AstNode *` (e nao o typedef AstNode*) no %union para que
 * parser.tab.h compile sem precisar de #include "ast.h" antes - o tag de
 * struct dispensa declaracao previa. Quem consumir parser.tab.h (main.c,
 * ast.c) inclui ast.h por conta propria para resolver o typedef. */
%union {
    int             ival;
    double          fval;
    char           *sval;
    struct AstNode *node;
}

/* Tokens com valor semantico. */
%token <sval> IDENTIFIER STRING TEMPLATE_STRING
%token <fval> NUMBER

/* Palavras-chave. */
%token LET CONST VAR FUNCTION RETURN
%token IF ELSE WHILE DO FOR BREAK CONTINUE
%token SWITCH CASE DEFAULT TRY CATCH FINALLY THROW
%token CLASS EXTENDS IMPORT FROM EXPORT NEW THIS
%token IN OF INSTANCEOF TYPEOF VOID_TOK DELETE
%token ASYNC AWAIT
%token TRUE_TOK FALSE_TOK NULL_TOK UNDEFINED_TOK

/* Operadores compostos. */
%token EQ NEQ STRICT_EQ STRICT_NEQ LE GE
%token AND OR SHL SHR INCREMENT DECREMENT
%token PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token ARROW

/* Operadores simples. */
%token ASSIGN PLUS MINUS TIMES DIVIDE MOD
%token NOT LT GT BIT_AND BIT_OR BIT_XOR BIT_NOT

/* Pontuacao. */
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token COMMA SEMI COLON DOT QUESTION

/* Tipos das nao-terminais. */
%type <node> program stmt_list statement block
%type <node> if_stmt while_stmt for_stmt return_stmt break_stmt continue_stmt
%type <node> var_decl expr_stmt
%type <node> for_init expr_opt
%type <node> expression primary
%type <node> arg_list_opt arg_list

/* Precedencia. Linhas posteriores ligam mais forte. */
%right ASSIGN PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIV_ASSIGN MOD_ASSIGN
%left  OR
%left  AND
%left  BIT_OR
%left  BIT_XOR
%left  BIT_AND
%left  EQ NEQ STRICT_EQ STRICT_NEQ
%left  LT GT LE GE
%left  SHL SHR
%left  PLUS MINUS
%left  TIMES DIVIDE MOD
%right NOT BIT_NOT UMINUS
%left  DOT LBRACKET LPAREN

%start program

%%

program
    : stmt_list                                 { ast_root = ast_program($1, @$.first_line, @$.first_column); $$ = ast_root; }
    ;

stmt_list
    : /* vazio */                               { $$ = ast_list(@$.first_line, @$.first_column); }
    | stmt_list statement                       { ast_add_child($1, $2); $$ = $1; }
    ;

statement
    : var_decl                                  { $$ = $1; }
    | expr_stmt                                 { $$ = $1; }
    | block                                     { $$ = $1; }
    | if_stmt                                   { $$ = $1; }
    | while_stmt                                { $$ = $1; }
    | for_stmt                                  { $$ = $1; }
    | return_stmt                               { $$ = $1; }
    | break_stmt                                { $$ = $1; }
    | continue_stmt                             { $$ = $1; }
    | SEMI                                      { $$ = ast_empty_stmt(@$.first_line, @$.first_column); }
    ;

block
    : LBRACE stmt_list RBRACE                   { $$ = ast_block($2, @$.first_line, @$.first_column); }
    ;

if_stmt
    : IF LPAREN expression RPAREN statement                   { $$ = ast_if($3, $5, NULL, @$.first_line, @$.first_column); }
    | IF LPAREN expression RPAREN statement ELSE statement    { $$ = ast_if($3, $5, $7,   @$.first_line, @$.first_column); }
    ;

while_stmt
    : WHILE LPAREN expression RPAREN statement                { $$ = ast_while($3, $5, @$.first_line, @$.first_column); }
    ;

for_stmt
    : FOR LPAREN for_init SEMI expr_opt SEMI expr_opt RPAREN statement
        { $$ = ast_for($3, $5, $7, $9, @$.first_line, @$.first_column); }
    ;

for_init
    : /* vazio */                                             { $$ = NULL; }
    | LET   IDENTIFIER ASSIGN expression                      { $$ = ast_var_decl(LET,   $2, $4, @$.first_line, @$.first_column); }
    | CONST IDENTIFIER ASSIGN expression                      { $$ = ast_var_decl(CONST, $2, $4, @$.first_line, @$.first_column); }
    | VAR   IDENTIFIER ASSIGN expression                      { $$ = ast_var_decl(VAR,   $2, $4, @$.first_line, @$.first_column); }
    | expression                                              { $$ = $1; }
    ;

expr_opt
    : /* vazio */                                             { $$ = NULL; }
    | expression                                              { $$ = $1; }
    ;

return_stmt
    : RETURN SEMI                                             { $$ = ast_return(NULL, @$.first_line, @$.first_column); }
    | RETURN expression SEMI                                  { $$ = ast_return($2,   @$.first_line, @$.first_column); }
    ;

break_stmt
    : BREAK SEMI                                              { $$ = ast_break(@$.first_line, @$.first_column); }
    ;

continue_stmt
    : CONTINUE SEMI                                           { $$ = ast_continue(@$.first_line, @$.first_column); }
    ;

var_decl
    : LET   IDENTIFIER ASSIGN expression SEMI   { $$ = ast_var_decl(LET,   $2, $4,   @$.first_line, @$.first_column); }
    | CONST IDENTIFIER ASSIGN expression SEMI   { $$ = ast_var_decl(CONST, $2, $4,   @$.first_line, @$.first_column); }
    | VAR   IDENTIFIER ASSIGN expression SEMI   { $$ = ast_var_decl(VAR,   $2, $4,   @$.first_line, @$.first_column); }
    | LET   IDENTIFIER SEMI                     { $$ = ast_var_decl(LET,   $2, NULL, @$.first_line, @$.first_column); }
    | VAR   IDENTIFIER SEMI                     { $$ = ast_var_decl(VAR,   $2, NULL, @$.first_line, @$.first_column); }
    ;

expr_stmt
    : expression SEMI                           { $$ = ast_expr_stmt($1, @$.first_line, @$.first_column); }
    ;

expression
    : expression PLUS       expression          { $$ = ast_binary(PLUS,       $1, $3, @$.first_line, @$.first_column); }
    | expression MINUS      expression          { $$ = ast_binary(MINUS,      $1, $3, @$.first_line, @$.first_column); }
    | expression TIMES      expression          { $$ = ast_binary(TIMES,      $1, $3, @$.first_line, @$.first_column); }
    | expression DIVIDE     expression          { $$ = ast_binary(DIVIDE,     $1, $3, @$.first_line, @$.first_column); }
    | expression MOD        expression          { $$ = ast_binary(MOD,        $1, $3, @$.first_line, @$.first_column); }
    | expression EQ         expression          { $$ = ast_binary(EQ,         $1, $3, @$.first_line, @$.first_column); }
    | expression NEQ        expression          { $$ = ast_binary(NEQ,        $1, $3, @$.first_line, @$.first_column); }
    | expression STRICT_EQ  expression          { $$ = ast_binary(STRICT_EQ,  $1, $3, @$.first_line, @$.first_column); }
    | expression STRICT_NEQ expression          { $$ = ast_binary(STRICT_NEQ, $1, $3, @$.first_line, @$.first_column); }
    | expression LT         expression          { $$ = ast_binary(LT,         $1, $3, @$.first_line, @$.first_column); }
    | expression GT         expression          { $$ = ast_binary(GT,         $1, $3, @$.first_line, @$.first_column); }
    | expression LE         expression          { $$ = ast_binary(LE,         $1, $3, @$.first_line, @$.first_column); }
    | expression GE         expression          { $$ = ast_binary(GE,         $1, $3, @$.first_line, @$.first_column); }
    | expression AND        expression          { $$ = ast_binary(AND,        $1, $3, @$.first_line, @$.first_column); }
    | expression OR         expression          { $$ = ast_binary(OR,         $1, $3, @$.first_line, @$.first_column); }
    | MINUS expression  %prec UMINUS            { $$ = ast_unary(MINUS, $2, @$.first_line, @$.first_column); }
    | NOT   expression                          { $$ = ast_unary(NOT,   $2, @$.first_line, @$.first_column); }
    | IDENTIFIER ASSIGN        expression       { $$ = ast_assign(ASSIGN,        $1, $3, @$.first_line, @$.first_column); }
    | IDENTIFIER PLUS_ASSIGN   expression       { $$ = ast_assign(PLUS_ASSIGN,   $1, $3, @$.first_line, @$.first_column); }
    | IDENTIFIER MINUS_ASSIGN  expression       { $$ = ast_assign(MINUS_ASSIGN,  $1, $3, @$.first_line, @$.first_column); }
    | IDENTIFIER TIMES_ASSIGN  expression       { $$ = ast_assign(TIMES_ASSIGN,  $1, $3, @$.first_line, @$.first_column); }
    | IDENTIFIER DIV_ASSIGN    expression       { $$ = ast_assign(DIV_ASSIGN,    $1, $3, @$.first_line, @$.first_column); }
    | IDENTIFIER MOD_ASSIGN    expression       { $$ = ast_assign(MOD_ASSIGN,    $1, $3, @$.first_line, @$.first_column); }
    | expression LPAREN arg_list_opt RPAREN     { $$ = ast_call($1, $3, @$.first_line, @$.first_column); }
    | expression DOT IDENTIFIER                 { $$ = ast_member($1, $3, @$.first_line, @$.first_column); }
    | expression LBRACKET expression RBRACKET   { $$ = ast_index($1, $3,  @$.first_line, @$.first_column); }
    | primary                                   { $$ = $1; }
    ;

arg_list_opt
    : /* vazio */                               { $$ = NULL; }
    | arg_list                                  { $$ = $1; }
    ;

arg_list
    : expression                                { $$ = ast_list(@$.first_line, @$.first_column); ast_add_child($$, $1); }
    | arg_list COMMA expression                 { ast_add_child($1, $3); $$ = $1; }
    ;

primary
    : IDENTIFIER                                { $$ = ast_ident($1, @$.first_line, @$.first_column); }
    | NUMBER                                    { $$ = ast_number($1, @$.first_line, @$.first_column); }
    | STRING                                    { $$ = ast_string($1, @$.first_line, @$.first_column); }
    | TRUE_TOK                                  { $$ = ast_bool(1, @$.first_line, @$.first_column); }
    | FALSE_TOK                                 { $$ = ast_bool(0, @$.first_line, @$.first_column); }
    | NULL_TOK                                  { $$ = ast_null(@$.first_line, @$.first_column); }
    | UNDEFINED_TOK                             { $$ = ast_undefined(@$.first_line, @$.first_column); }
    | LPAREN expression RPAREN                  { $$ = $2; }
    ;

%%

void yyerror(const char *msg) {
    fprintf(stderr, "Erro sintatico na linha %d, coluna %d: %s\n",
            yylloc.first_line, yylloc.first_column, msg);
}

int lex_error_count = 0;

void lex_error(const char *lexeme, int line, int column) {
    lex_error_count++;
    fprintf(stderr, "Token invalido \"%s\" na linha %d, coluna %d\n",
            lexeme, line, column);
}
