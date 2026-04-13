import type { Node } from "./Node.js";
import type { Expression, Identifier } from "./Expressions.js";

/**
 * União de todos os nós de statement.
 * Statements EXECUTAM uma ação — não produzem valor diretamente.
 */
export type Statement =
  | Assignment
  | ExpressionStatement
  | IfStatement
  | WhileStatement
  | ForStatement
  | FunctionDef
  | ReturnStatement
  | BreakStatement
  | PassStatement
  | MatchStatement
  | TryStatement
  | ImportStatement;

/** Bloco de statements (corpo de if, while, def, etc.). */
export type Block = Statement[];

/** x = expr  ou  x += expr. */
export interface Assignment extends Node {
  kind: "Assignment";
  op: string;
  target: Expression;
  value: Expression;
}

/** Expressão usada como statement (ex.: chamada de função solta). */
export interface ExpressionStatement extends Node {
  kind: "ExpressionStatement";
  expression: Expression;
}

/** if cond: ... [elif cond: ...] [else: ...] */
export interface IfStatement extends Node {
  kind: "IfStatement";
  test: Expression;
  consequent: Block;
  alternate: Block | null;
}

export interface WhileStatement extends Node {
  kind: "WhileStatement";
  test: Expression;
  body: Block;
}

/** for target in iter: body */
export interface ForStatement extends Node {
  kind: "ForStatement";
  target: Identifier;
  iter: Expression;
  body: Block;
}

/** def name(params): body */
export interface FunctionDef extends Node {
  kind: "FunctionDef";
  name: string;
  params: Identifier[];
  body: Block;
}

export interface ReturnStatement extends Node {
  kind: "ReturnStatement";
  argument: Expression | null;
}

export interface BreakStatement extends Node {
  kind: "BreakStatement";
}

export interface PassStatement extends Node {
  kind: "PassStatement";
}

/** match subject: case pattern: body ... */
export interface MatchStatement extends Node {
  kind: "MatchStatement";
  subject: Expression;
  cases: MatchCase[];
}

export interface MatchCase extends Node {
  kind: "MatchCase";
  pattern: Expression;
  body: Block;
}

/** try: body except: handler */
export interface TryStatement extends Node {
  kind: "TryStatement";
  body: Block;
  handler: Block;
}

/** import mod  ou  import mod as alias */
export interface ImportStatement extends Node {
  kind: "ImportStatement";
  module: string;
  alias: string | null;
}
