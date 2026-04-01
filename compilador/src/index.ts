import { readFileSync, writeFileSync } from "node:fs";
import { basename, resolve } from "node:path";
import { compile } from "./compile.js";

const inputPath = process.argv[2];

if (!inputPath) {
  console.error("Usage: npm run dev -- <arquivo.py>");
  process.exit(1);
}

const absolutePath = resolve(inputPath);
const source = readFileSync(absolutePath, "utf-8");

const compiled = compile(source);

const outputPath = resolve(
  absolutePath,
  "..",
  basename(absolutePath, ".py") + ".js"
);

writeFileSync(outputPath, compiled, "utf-8");
console.log(`Arquivo compilado salvo em: ${outputPath}`);
