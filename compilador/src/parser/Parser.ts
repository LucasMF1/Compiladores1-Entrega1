import type { Token } from "../lexer/Token.js";
import { TokenType } from "../lexer/TokenType.js";
import type { Program, Statement } from "./ast/Node.js";
import type { Expression } from "./ast/Expressions.js";
import type { Block } from "./ast/Statements.js";
import type { StatementParser } from "./statements/StatementParser.js";
import { IfParser } from "./statements/IfParser.js";
import { WhileParser } from "./statements/WhileParser.js";
import { ForParser } from "./statements/ForParser.js";
import { FunctionDefParser } from "./statements/FunctionDefParser.js";
import { ReturnParser } from "./statements/ReturnParser.js";
import { MatchParser } from "./statements/MatchParser.js";
import { TryParser } from "./statements/TryParser.js";
import { ImportParser } from "./statements/ImportParser.js";
import { SimpleStatementParser } from "./statements/SimpleStatementParser.js";
import { ExpressionParser } from "./ExpressionParser.js";

export class Parser {
  private pos = 0;

  /**
   * Ordem importa: parsers mais específicos (keyword-gated) vêm antes do
   * SimpleStatementParser, que é o fallback para tudo que não é keyword
   * (atribuições e expression statements).
   */
  private readonly statementParsers: StatementParser[] = [
    new IfParser(),
    new WhileParser(),
    new ForParser(),
    new FunctionDefParser(),
    new ReturnParser(),
    new MatchParser(),
    new TryParser(),
    new ImportParser(),
    new SimpleStatementParser(),
  ];

  private readonly expressionParser = new ExpressionParser();

  constructor(private readonly tokens: Token[]) {}

  /**
   * Ponto de entrada: consome a lista inteira de tokens e devolve o Program.
   *
   * Algoritmo:
   *   enquanto não for EOF:
   *     - pular NEWLINEs sozinhos (linhas em branco)
   *     - achar o primeiro statementParser com canParse(token atual)
   *     - se nenhum casar → erro sintático
   *     - chamar parse(this) e empurrar o statement no body
   */
  parse(): Program {
    const body: Statement[] = [];
    const first = this.peek();

    while (!this.isAtEnd()) {
      if (this.check(TokenType.NEWLINE)) {
        this.advance();
        continue;
      }

      const token = this.peek();
      const sp = this.statementParsers.find((p) => p.canParse(token));
      if (!sp) {
        throw new Error(
          `Token inesperado '${token.lexeme}' em ${token.line}:${token.column}`,
        );
      }

      body.push(sp.parse(this));
    }

    return {
      kind: "Program",
      line: first.line,
      column: first.column,
      body,
    };
  }

  /**
   * Consome um bloco indentado (corpo de if, while, def, ...).
   * Espera a sequência: NEWLINE, INDENT, <statements>, DEDENT.
   *
   * TODO: implementar quando os statement parsers estiverem prontos.
   */
  parseBlock(): Block {
    throw new Error("Parser.parseBlock not implemented");
  }

  /** Delega parsing de expressão para o ExpressionParser. */
  parseExpression(): Expression {
    return this.expressionParser.parse(this);
  }

  // ──────────────── Métodos utilitários do cursor ────────────────

  peek(offset = 0): Token {
    return this.tokens[this.pos + offset] ?? this.tokens[this.tokens.length - 1];
  }

  advance(): Token {
    const t = this.tokens[this.pos];
    if (!this.isAtEnd()) this.pos++;
    return t;
  }

  /** Retorna true se o próximo token é do tipo esperado (sem consumir). */
  check(type: TokenType, lexeme?: string): boolean {
    const t = this.peek();
    if (t.type !== type) return false;
    if (lexeme !== undefined && t.lexeme !== lexeme) return false;
    return true;
  }

  /** Consome SE casar; retorna true/false. */
  match(type: TokenType, lexeme?: string): boolean {
    if (!this.check(type, lexeme)) return false;
    this.advance();
    return true;
  }

  /** Consome exigindo casamento; lança erro caso contrário. */
  expect(type: TokenType, lexeme?: string): Token {
    if (this.check(type, lexeme)) return this.advance();
    const t = this.peek();
    const wanted = lexeme ? `${type}('${lexeme}')` : type;
    throw new Error(
      `Esperado ${wanted}, encontrado ${t.type}('${t.lexeme}') em ${t.line}:${t.column}`,
    );
  }

  isAtEnd(): boolean {
    return this.peek().type === TokenType.EOF;
  }
}
