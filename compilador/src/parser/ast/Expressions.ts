import type { Node } from "./Node.js";

/**
 * União de todos os nós de expressão.
 * Expressões PRODUZEM um valor: literais, identificadores, operações, etc.
 */
export type Expression =
  | Literal
  | Identifier
  | BinaryOp
  | UnaryOp
  | Call
  | Attribute
  | Subscript;

/** Literal: número, string, None, True, False. */
export interface Literal extends Node {
  kind: "Literal";
  value: number | string | boolean | null;
  raw: string;
}

/** Referência a um nome (variável, função, parâmetro). */
export interface Identifier extends Node {
  kind: "Identifier";
  name: string;
}

/** Operação binária: a + b, x == y, etc. */
export interface BinaryOp extends Node {
  kind: "BinaryOp";
  op: string;
  left: Expression;
  right: Expression;
}

/** Operação unária: -x, not x. */
export interface UnaryOp extends Node {
  kind: "UnaryOp";
  op: string;
  operand: Expression;
}

/** Chamada de função: f(a, b). */
export interface Call extends Node {
  kind: "Call";
  callee: Expression;
  args: Expression[];
}

/** Acesso a atributo: obj.attr. */
export interface Attribute extends Node {
  kind: "Attribute";
  object: Expression;
  attr: string;
}

/** Indexação: obj[index]. */
export interface Subscript extends Node {
  kind: "Subscript";
  object: Expression;
  index: Expression;
}
