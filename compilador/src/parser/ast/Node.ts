/**
 * Nó base da AST. Todo nó carrega a linha/coluna do token que o originou
 * para que fases posteriores possam reportar erros com posição exata.
 */
export interface Node {
  readonly kind: string;
  readonly line: number;
  readonly column: number;
}

/**
 * Raiz da AST — representa um arquivo Python inteiro como uma lista de
 * statements de topo.
 */
export interface Program extends Node {
  kind: "Program";
  body: Statement[];
}

// Re-exports para reduzir ruído de import nos arquivos que só querem "Node".
import type { Statement } from "./Statements.js";
export type { Statement };
