import { readdirSync, readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { compilar } from "../compile.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const pastaTestes = resolve(__dirname, "../../..", "testes");

const arquivosPy = readdirSync(pastaTestes).filter((f) => f.endsWith(".py"));

if (arquivosPy.length === 0) {
  console.log("Nenhum arquivo .py encontrado em testes/");
  process.exit(0);
}

let aprovados = 0;
let reprovados = 0;

for (const arquivoPy of arquivosPy) {
  const nome = arquivoPy.replace(".py", "");
  const arquivoEsperado = resolve(pastaTestes, nome + ".expected.js");

  const fonte = readFileSync(resolve(pastaTestes, arquivoPy), "utf-8");
  const compilado = compilar(fonte);

  let esperado: string;
  try {
    esperado = readFileSync(arquivoEsperado, "utf-8");
  } catch {
    console.log(`[SKIP] ${arquivoPy} — arquivo ${nome}.expected.js não encontrado`);
    continue;
  }

  if (compilado.trim() === esperado.trim()) {
    console.log(`[PASS] ${arquivoPy}`);
    aprovados++;
  } else {
    console.log(`[FAIL] ${arquivoPy}`);
    console.log(`  Esperado:\n${esperado}`);
    console.log(`  Recebido:\n${compilado}`);
    reprovados++;
  }
}

console.log(`\nResultado: ${aprovados} passou, ${reprovados} falhou`);

if (reprovados > 0) {
  process.exit(1);
}
