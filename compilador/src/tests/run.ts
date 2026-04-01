import { readdirSync, readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { compile } from "../compile.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const testesDir = resolve(__dirname, "../../..", "testes");

const pyFiles = readdirSync(testesDir).filter((f) => f.endsWith(".py"));

if (pyFiles.length === 0) {
  console.log("Nenhum arquivo .py encontrado em testes/");
  process.exit(0);
}

let passed = 0;
let failed = 0;

for (const pyFile of pyFiles) {
  const name = pyFile.replace(".py", "");
  const expectedFile = resolve(testesDir, name + ".expected.js");

  const source = readFileSync(resolve(testesDir, pyFile), "utf-8");
  const compiled = compile(source);

  let expected: string;
  try {
    expected = readFileSync(expectedFile, "utf-8");
  } catch {
    console.log(`[SKIP] ${pyFile} — arquivo ${name}.expected.js não encontrado`);
    continue;
  }

  if (compiled.trim() === expected.trim()) {
    console.log(`[PASS] ${pyFile}`);
    passed++;
  } else {
    console.log(`[FAIL] ${pyFile}`);
    console.log(`  Esperado:\n${expected}`);
    console.log(`  Recebido:\n${compiled}`);
    failed++;
  }
}

console.log(`\nResultado: ${passed} passou, ${failed} falhou`);

if (failed > 0) {
  process.exit(1);
}
