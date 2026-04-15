import { readFileSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { Lexer } from "../lexer/Lexer.js";

type Caso = {
  id: string;
  description: string;
  validity: "valid" | "invalid";
  input: string;
  expectedOutput?: string;
  expectedError?: string;
};

const __dirname = dirname(fileURLToPath(import.meta.url));
const pastaTestes = resolve(__dirname, "../../..", "testes");
const casesPath = resolve(pastaTestes, "cases.json");

const casos: Caso[] = JSON.parse(readFileSync(casesPath, "utf-8"));

let aprovados = 0;
let reprovados = 0;

for (const caso of casos) {
  const caminhoFonte = resolve(pastaTestes, caso.input);
  const fonte = readFileSync(caminhoFonte, "utf-8");

  let erro: Error | null = null;
  try {
    new Lexer(fonte).tokenize();
  } catch (e) {
    erro = e instanceof Error ? e : new Error(String(e));
  }

  if (caso.validity === "valid") {
    if (!erro) {
      console.log(`[PASS] ${caso.id}`);
      aprovados++;
    } else {
      console.log(`[FAIL] ${caso.id} — esperava sucesso, recebeu erro:`);
      console.log(`  ${erro.message}`);
      reprovados++;
    }
  } else {
    if (!erro) {
      console.log(`[FAIL] ${caso.id} — esperava erro, tokenizou sem problemas`);
      reprovados++;
    } else if (caso.expectedError && !erro.message.includes(caso.expectedError)) {
      console.log(`[FAIL] ${caso.id} — mensagem de erro não bate`);
      console.log(`  Esperado conter: ${caso.expectedError}`);
      console.log(`  Recebido:       ${erro.message}`);
      reprovados++;
    } else {
      console.log(`[PASS] ${caso.id}`);
      aprovados++;
    }
  }
}

console.log(`\nResultado: ${aprovados} passou, ${reprovados} falhou`);

if (reprovados > 0) {
  process.exit(1);
}
