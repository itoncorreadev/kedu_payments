# frozen_string_literal: true

require 'rails_helper'
require 'rswag/specs'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {
        '/centros-de-custo' => {
          get: {
            summary: 'Lista centros de custo',
            tags: [ 'Centros de Custo' ],
            responses: {
              '200' => {
                description: 'ok',
                content: {
                  'application/json' => {
                    schema: { type: :array, items: { '$ref' => '#/components/schemas/CentroDeCusto' } }
                  }
                }
              }
            }
          },
          post: {
            summary: 'Cria centro de custo',
            tags: [ 'Centros de Custo' ],
            parameters: [],
            responses: {
              '201' => {
                description: 'created',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/CentroDeCusto' }
                  }
                }
              },
              '422' => {
                description: 'invalid',
                content: {
                  'application/json' => {
                    schema: { '$ref' => '#/components/schemas/ErrorResponse' }
                  }
                }
              }
            },
            requestBody: {
              content: {
                'application/json' => {
                  schema: {
                    type: :object,
                    properties: {
                      centro_de_custo: {
                        type: :object,
                        properties: { nome: { type: :string } },
                        required: [ 'nome' ]
                      }
                    },
                    required: [ 'centro_de_custo' ]
                  }
                }
              }
            }
          }
        }
      },
      components: {
        schemas: {
          ResponsavelFinanceiro: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              nome: { type: :string, example: 'Fulano' },
              created_at: { type: :string, format: :'date-time', example: '2025-10-12T21:41:02Z' },
              updated_at: { type: :string, format: :'date-time', example: '2025-10-12T21:41:02Z' }
            },
            required: %w[id nome]
          },
          CentroDeCusto: {
            type: :object,
            properties: {
              id: { type: :integer, example: 10 },
              nome: { type: :string, example: 'Financeiro' },
              created_at: { type: :string, format: :'date-time', example: '2025-10-12T21:41:02Z' },
              updated_at: { type: :string, format: :'date-time', example: '2025-10-12T21:41:02Z' }
            },
            required: %w[id nome]
          },
          Cobranca: {
            type: :object,
            properties: {
              id: { type: :integer, example: 100 },
              valor_cents: { type: :integer, example: 10000 },
              data_vencimento: { type: :string, format: :date, example: '2025-12-01' },
              metodo_pagamento: { type: :string, example: 'boleto' },
              status: { type: :string, example: 'emitida' },
              codigo_pagamento: { type: :string, example: 'ABC123' }
            },
            required: %w[id valor_cents data_vencimento metodo_pagamento status]
          },
          Pagamento: {
            type: :object,
            properties: {
              id: { type: :integer, example: 200 },
              cobranca_id: { type: :integer, example: 100 },
              valor_cents: { type: :integer, example: 10000 },
              data_pagamento: { type: :string, format: :date, example: '2025-11-17' }
            },
            required: %w[id cobranca_id valor_cents data_pagamento]
          },
          PlanoDePagamento: {
            type: :object,
            properties: {
              id: { type: :integer, example: 300 },
              responsavel_financeiro_id: { type: :integer, example: 1 },
              centro_de_custo_id: { type: :integer, example: 10 },
              valor_total_cents: { type: :integer, example: 10000 },
              cobrancas: {
                type: :array,
                items: { '$ref' => '#/components/schemas/Cobranca' }
              }
            },
            required: %w[id responsavel_financeiro_id centro_de_custo_id valor_total_cents]
          },
          ErrorResponse: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                example: [ 'campo nome é obrigatório' ]
              },
              error: { type: :string, example: 'Recurso não encontrado' }
            }
          }
        }
      },
      servers: [
        {
          url: 'http://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'localhost:3000'
            }
          }
        }
      ]
    }
  }

  config.openapi_format = :yaml
end
