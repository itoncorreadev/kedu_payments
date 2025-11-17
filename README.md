# 💳 Kedu API

API em Ruby on Rails para gestão de planos de pagamento, responsáveis financeiros, centros de custo, cobranças e pagamentos. Documentada com Swagger/OpenAPI (RSwag), com suporte adicional a GraphQL.

## 🔍 Visão Geral

- Recursos principais: Responsáveis, Planos de Pagamento, Centros de Custo, Cobranças e Pagamentos.
- Documentação: Swagger UI em `http://localhost:3000/api-docs` e arquivo gerado em `swagger/v1/swagger.yaml`.
- GraphQL: endpoint `POST /graphql` e GraphiQL em `http://localhost:3000/graphiql` (apenas desenvolvimento).
- Execução via Docker Compose.

## 🛠 Tecnologias

- Ruby 3.4.7
- Rails 8.1.1
- PostgreSQL 16
- RSpec, FactoryBot, Shoulda Matchers, Fuubar
- RSwag (rswag-api, rswag-ui, rswag-specs)
- GraphQL (graphql, graphiql-rails)
- RuboCop Rails Omakase
- Docker e Docker Compose

## 🏗 Arquitetura

- Controllers: expõem endpoints REST e delegam regras de negócio para services.
- Services: encapsulam lógica de domínio (SRP), ex.: `Pagamentos::RegistrarPagamento`, `PlanosDePagamento::CriarPlano`, `Cobrancas::ConsultaPorResponsavel`.
- Serializers: definem contratos de resposta, ex.: `CobrancaSerializer`.
- GraphQL: schema com `Query` e `Mutation` reutilizando os services para manter paridade com REST.

## ⚙️ Pré-requisitos

- Docker e Docker Compose instalados.
- Arquivo `.env` na raiz de `kedu_api` com variáveis mínimas:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
DB_PORT=5432
```

Valide a interpolação do Compose:

```
docker compose config
```

## 🚀 Subir com Docker Compose

1) Subir banco

```
docker compose up -d db
```

Verifique status/logs:

```
docker compose ps
docker compose logs -f db
```

2) Preparar banco (primeira execução)

```
docker compose run --rm web bash -lc "bin/rails db:create db:migrate"
```

Popular dados (opcional):

```
docker compose run --rm web bash -lc "bin/rails db:seed"
```

3) Subir aplicação

```
docker compose up -d web
```

Acessos:

- API: `http://localhost:3000`
- Swagger UI: `http://localhost:3000/api-docs`
- GraphiQL (dev): `http://localhost:3000/graphiql`

Observações (Windows/PowerShell): evite encadear comandos com `&&`. Prefira executá-los separadamente ou use `;` apenas quando suportado.

## 🖥 Rodar sem Docker (opcional)

```
bundle install
bin/rails db:prepare
bin/rails server
```

## 📚 Documentação da API (Swagger/RSwag)

- UI: `http://localhost:3000/api-docs`
- Arquivo: `swagger/v1/swagger.yaml`
- Regenerar via specs:

```
docker compose run --rm --no-deps web bash -lc "RAILS_ENV=test SWAGGER_DRY_RUN=true bundle exec rake rswag:specs:swaggerize"
```

Notas:

- Há política de cobertura com SimpleCov. A geração roda em modo "dry-run" via `SWAGGER_DRY_RUN=true` para evitar falha por cobertura, mas pode retornar código não-zero em alguns cenários. O arquivo é gerado corretamente.

## 🧪 Testes

Rodar a suíte:

```
docker compose run --rm --no-deps web bash -lc "RAILS_ENV=test bundle exec rspec"
```

GraphQL apenas:

```
docker compose run --rm --no-deps web bash -lc "RAILS_ENV=test SWAGGER_DRY_RUN=true bundle exec rspec spec/requests/graphql_spec.rb --format documentation --order defined"
```

Cobertura:

- Relatório em `coverage/`.
- Para geração de Swagger ou execução pontual sem falha por cobertura, use `SWAGGER_DRY_RUN=true`.

## ✨ Qualidade de Código

RuboCop Rails Omakase:

```
docker compose run --rm --no-deps web bash -lc "rubocop"
```

## 🗂 Endpoints Principais (REST)

- Responsáveis
  - `GET /responsaveis` — lista
  - `POST /responsaveis` — cria
  - `GET /responsaveis/:id` — exibe
  - `GET /responsaveis/:id/cobrancas` — lista cobranças com filtros `metodoPagamento`, `status`, `vencida`
  - `GET /responsaveis/:id/cobrancas/quantidade` — contagem

- Planos de Pagamento
  - `POST /planos-de-pagamento` — cria (payload com `responsavelId`, `centroDeCusto`, `cobrancas`)
  - `GET /planos-de-pagamento/:id` — exibe
  - `GET /planos-de-pagamento/:id/total` — total do plano

- Pagamentos
  - `POST /cobrancas/:cobranca_id/pagamentos` — registra pagamento (`valor` e opcional `data_pagamento`)

- Centros de Custo
  - `GET /centros-de-custo` — lista
  - `POST /centros-de-custo` — cria

## 🧠 GraphQL

- Endpoint: `POST /graphql`
- GraphiQL (dev): `http://localhost:3000/graphiql`

### 🔎 Exemplos de Query

Lista centros de custo:

```
{ centrosDeCusto { id nome } }
```

Plano por id:

```
{ plano(id: 1) { id valorTotalCents cobrancas { id metodoPagamento status } } }
```

Planos do responsável:

```
{ planosDoResponsavel(responsavelId: 1) { id valorTotalCents } }
```

Cobranças com filtros:

```
{ cobrancasDoResponsavel(responsavelId: 1, metodoPagamento: "boleto", status: "emitida", vencida: true) { id metodoPagamento status } }
```

Quantidade de cobranças:

```
{ cobrancasQuantidade(responsavelId: 1) }
```

### ✍️ Exemplos de Mutation

Criar plano:

```
mutation {
  criarPlano(
    responsavelId: 1,
    centroDeCustoId: 2,
    cobrancas: [{ valor: 100.0, dataVencimento: "2025-12-31", metodoPagamento: "boleto" }]
  ) {
    id valorTotalCents
  }
}
```

Registrar pagamento:

```
mutation {
  registrarPagamento(cobrancaId: 123, valor: 100.0, dataPagamento: "2025-11-17") {
    id valorCents cobrancaId
  }
}
```

## ℹ️ Notas Adicionais

- A aplicação usa services para manter separação de responsabilidades e facilitar testes/manutenção.
- O GraphQL reutiliza os services e models, garantindo consistência de regras entre REST e GraphQL.
- Rotas principais estão em `config/routes.rb`.

## 🧰 Troubleshooting

- Geração de Swagger falha por cobertura: use `SWAGGER_DRY_RUN=true` na execução.
- Erros de conexão com DB: verifique `.env` e se o serviço `db` está ativo (`docker compose ps`).
- Em Windows/PowerShell, execute comandos separadamente quando necessário.
