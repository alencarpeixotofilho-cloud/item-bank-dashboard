# Painel de Diagnóstico de Banco de Itens

![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=r&logoColor=white) ![Shiny](https://img.shields.io/badge/Shiny-1A162D?style=flat-square&logo=shiny&logoColor=white) ![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-green?style=flat-square) ![Status](https://img.shields.io/badge/status-em%20constru%C3%A7%C3%A3o-orange?style=flat-square)

> Painel interativo para conhecer a composição de um banco de questões e encontrar lacunas de cobertura.

## 📌 Visão geral

Lê a exportação de um banco de itens e mostra, de forma interativa, a distribuição por área, tema, competência e nível cognitivo (Bloom), além de indicadores de qualidade de redação. Também exporta uma versão HTML estática para compartilhar.

## ✨ Funcionalidades

- Distribuição de itens por área, tema e competência
- Mapa de cobertura em relação a uma matriz de referência
- Níveis cognitivos (taxonomia de Bloom)
- Indicadores de qualidade e status de validação
- Exportação para HTML autônomo (uso offline)
- Tema visual configurável

## 🗂️ Estrutura do repositório

```text
painel-banco-de-itens/
├── R/              # leitura, gráficos, tema e indicadores
├── app.R           # aplicação Shiny
├── exemplos/       # banco de itens sintético
├── LICENSE
└── README.md
```

## 🚀 Como usar

```r
source("instalar.R")      # instala dependências
shiny::runApp()           # abre o painel com o banco de exemplo
```

## 🔒 Dados e privacidade

Este repositório **não contém dados reais** de estudantes, docentes ou instituições.
Todos os exemplos usam **dados sintéticos** gerados pelo próprio projeto
(`exemplos/gerar_dados_exemplo`), com identificadores fictícios (`Estudante 001`, `Item 001`…).
Os itens de prova usados nos exemplos são inventados para fins de demonstração.

## 🛣️ Roadmap

- [ ] Banco de itens sintético
- [ ] Módulos de leitura e indicadores
- [ ] Painel Shiny
- [ ] Exportação HTML offline
- [ ] Demonstração online

## 📄 Licença

Distribuído sob a licença MIT. Veja [`LICENSE`](LICENSE).
