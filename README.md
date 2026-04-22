# Compiladores1-Entrega1

> Compilador que traduz um subconjunto de **JavaScript** para **Python**, desenvolvido em **C** com **Flex** e **Bison** no contexto da disciplina de Compiladores 1.

---

## Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Pré-requisitos](#pré-requisitos)
- [Como Compilar e Executar](#como-compilar-e-executar)
- [Estado Atual do Projeto](#estado-atual-do-projeto)
- [Como Contribuir / Atualizar](#como-contribuir--atualizar)
- [Equipe](#equipe)
- [Licença](#licença)

---

## Sobre o Projeto

O objetivo deste projeto é construir um **compilador** que recebe como entrada um programa escrito em um subconjunto de JavaScript e produz como saída um código Python equivalente e funcionalmente correto.

O projeto é desenvolvido no contexto da disciplina de **Compiladores 1**, aplicando a metodologia ágil **Scrum** com sprints semanais. Todas as decisões técnicas são documentadas e justificadas ao longo do desenvolvimento.

## Estrutura do Repositório

```
Compiladores1-Entrega1/
├── compilador/                  
│   ├── src/                     # Código-fonte
│   ├── package.json
│   ├── package-lock.json
│   └── tsconfig.json
│
├── compilador_flex_bison/       # Implementação principal em C com Flex e Bison
│   ├── src/                     # Código-fonte (.l, .y, .c, .h)
│   ├── build.sh                 # Script de compilação
│   └── test.sh                  # Script de testes
│
├── testes_js_to_python/         # Casos de teste
│   ├── validos/                 # Entradas JS válidas com saída Python esperada
│   └── invalidos/               # Entradas com erros léxicos/sintáticos esperados
│
├── .gitignore
├── LICENSE
├── package-lock.json
└── README.md
```

---

## Tecnologias Utilizadas

| Tecnologia | Função |
|---|---|
| **C** | Linguagem base do compilador |
| **Flex (lex)** | Geração do analisador léxico (`lexer.l`) |
| **Bison** | Geração do analisador sintático (`parser.y`) |

---

## Pré-requisitos

Certifique-se de ter instalado em sua máquina:

```bash
# Ubuntu / Debian
sudo apt update
sudo apt install gcc flex bison make

# macOS (Homebrew)
brew install gcc flex bison
```

Verifique as instalações:

```bash
gcc --version
flex --version
bison --version
```

---

## Como Compilar e Executar

### 1. Clone o repositório

```bash
git clone https://github.com/SEU_ORG/Compiladores1-Entrega1.git
cd Compiladores1-Entrega1
```

### 2. Acesse o diretório principal

```bash
cd compilador_flex_bison
```

### 3. Compile o projeto

```bash
bash build.sh
```

O script `build.sh` executa internamente os seguintes passos:

```bash
# Gera o analisador léxico a partir do lexer.l
flex src/lexer.l

# Gera o analisador sintático a partir do parser.y
bison -d src/parser.y

# Compila tudo com GCC
gcc -o compilador lex.yy.c parser.tab.c -lfl
```

## Como Testar

### Executar todos os testes

```bash
bash test.sh
```

### Testes manuais

Utilize os arquivos da pasta `testes_js_to_python/`:

```bash
# Teste com entrada válida
./compilador < testes_js_to_python/validos/exemplo1.js

# Teste com entrada inválida (deve retornar erro)
./compilador < testes_js_to_python/invalidos/erro_lexico.js
```

---

## Estado Atual do Projeto

| Componente | Status |
|---|---|
| Analisador Léxico (`lexer.l`) |  Implementado |
| Analisador Sintático (`parser.y`) |  Implementado |
| Tabela de Símbolos | Implementado  |
| AST (Árvore Sintática Abstrata) | 📋 Planejado |
| Geração de Código Python | 📋 Planejado |
| Testes de Integração | 📋 Planejado |


## Como Contribuir / Atualizar

### Fluxo de trabalho com Git

```bash
# 1. Sempre atualize sua branch local antes de começar
git checkout main
git pull origin main

# 2. Crie uma branch para sua feature ou correção
git checkout -b feat/nome-da-feature

# 3. Faça suas alterações e commit
git add .
git commit -m "feat: descrição clara do que foi feito"

# 4. Envie para o repositório remoto
git push origin feat/nome-da-feature

# 5. Abra um Pull Request no GitHub para revisão
```

### Convenção de commits

| Prefixo | Uso |
|---|---|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `docs:` | Atualização de documentação |
| `test:` | Adição ou correção de testes |
| `refactor:` | Refatoração de código |

## Equipe

- GABRIEL SAMPAIO FAÉ (231011382)
- JOAO GABRIEL MILHOMEM DE BRITO (221022005)
- LUCAS MONTEIRO FREITAS (231035446)
- MANUELLA DAL BIANCO PERLIN ALMEIDA (231038214)
- OTAVIO OLIVEIRA DE MAYA VIANA (211029503)

---

## Licença

Este projeto está licenciado sob a licença **MIT**. Consulte o arquivo [LICENSE](./LICENSE) para mais detalhes. 

