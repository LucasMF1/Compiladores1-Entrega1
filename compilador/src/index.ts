import { readFileSync, writeFileSync } from "node:fs";
import { basename, resolve } from "node:path";
import { compilar } from "./compile.js";

const caminhoEntrada = process.argv[2];

if (!caminhoEntrada) {
  console.error("Usage: npm run dev -- <arquivo.py>");
  process.exit(1);
}

const caminhoAbsoluto = resolve(caminhoEntrada);
const fonte = readFileSync(caminhoAbsoluto, "utf-8");

const compilado = compilar(fonte);

const caminhoSaida = resolve(
  caminhoAbsoluto,
  "..",
  basename(caminhoAbsoluto, ".py") + ".js"
);

writeFileSync(caminhoSaida, compilado, "utf-8");
console.log(`Arquivo compilado salvo em: ${caminhoSaida}`);
