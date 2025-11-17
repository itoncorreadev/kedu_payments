require 'swagger_helper'

RSpec.describe 'Planos de Pagamento API', openapi_spec: 'v1/swagger.yaml', type: :request do
  path '/planos-de-pagamento' do
    post 'Cria plano' do
      tags 'Planos'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          responsavelId: { type: :integer },
          centroDeCusto: { type: :integer },
          cobrancas: {
            type: :array,
            items: {
              type: :object,
              properties: {
                valor: { type: :number },
                dataVencimento: { type: :string, format: :date },
                metodoPagamento: { type: :string }
              },
              required: [ 'valor', 'dataVencimento', 'metodoPagamento' ]
            }
          }
        },
        required: [ 'responsavelId', 'centroDeCusto', 'cobrancas' ]
      }

      response '201', 'created' do
        let(:r) { create(:responsavel_financeiro) }
        let(:cc) { create(:centro_de_custo) }
        let(:payload) do
          { responsavelId: r.id, centroDeCusto: cc.id,
            cobrancas: [ { valor: 100.0, dataVencimento: Date.tomorrow, metodoPagamento: 'boleto' } ] }
        end
        schema '$ref' => '#/components/schemas/PlanoDePagamento'
        run_test!
      end

      response '422', 'invalid' do
        let(:r) { create(:responsavel_financeiro) }
        let(:cc) { create(:centro_de_custo) }
        let(:payload) do
          { responsavelId: r.id, centroDeCusto: cc.id,
            cobrancas: [ { valor: 0, dataVencimento: Date.tomorrow, metodoPagamento: 'boleto' } ] }
        end
        schema '$ref' => '#/components/schemas/ErrorResponse'
        run_test!
      end
    end
  end

  path '/planos-de-pagamento/{id}' do
    parameter name: :id, in: :path, type: :string
    get 'Exibe plano' do
      tags 'Planos'
      produces 'application/json'

      response '200', 'ok' do
        let(:id) { create(:plano_de_pagamento).id }
        schema '$ref' => '#/components/schemas/PlanoDePagamento'
        run_test!
      end

      response '404', 'not found' do
        let(:id) { '999999' }
        schema '$ref' => '#/components/schemas/ErrorResponse'
        run_test!
      end
    end
  end

  path '/planos-de-pagamento/{id}/total' do
    parameter name: :id, in: :path, type: :string
    get 'Total do plano' do
      tags 'Planos'
      produces 'application/json'

      response '200', 'ok' do
        let(:plano) { create(:plano_de_pagamento) }
        let(:id) { plano.id }
        before { plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida); plano.calcular_total! }
        schema type: :object, properties: { total: { type: :string } }
        run_test!
      end

      response '404', 'not found' do
        let(:id) { '999999' }
        schema '$ref' => '#/components/schemas/ErrorResponse'
        run_test!
      end
    end
  end
end
