require 'swagger_helper'

RSpec.describe 'Cobranças API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/responsaveis/{id}/cobrancas' do
    parameter name: :id, in: :path, type: :string
    parameter name: :metodoPagamento, in: :query, schema: { type: :string }
    parameter name: :status, in: :query, schema: { type: :string }
    parameter name: :vencida, in: :query, schema: { type: :string }

    get 'Lista cobranças do responsável' do
      tags 'Cobranças'
      produces 'application/json'

      response '200', 'ok' do
        let(:resp) { create(:responsavel_financeiro) }
        let(:id) { resp.id }
        let(:metodoPagamento) { nil }
        let(:status) { nil }
        let(:vencida) { nil }
        let(:plano) { create(:plano_de_pagamento, responsavel_financeiro: resp, centro_de_custo: create(:centro_de_custo)) }
        before { plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida) }
        schema type: :array, items: { '$ref' => '#/components/schemas/Cobranca' }
        run_test!
      end
    end
  end

  path '/responsaveis/{id}/cobrancas/quantidade' do
    parameter name: :id, in: :path, type: :string

    get 'Quantidade de cobranças do responsável' do
      tags 'Cobranças'
      produces 'application/json'

      response '200', 'ok' do
        let(:resp) { create(:responsavel_financeiro) }
        let(:id) { resp.id }
        let(:plano) { create(:plano_de_pagamento, responsavel_financeiro: resp, centro_de_custo: create(:centro_de_custo)) }
        before { plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida) }
        schema type: :object, properties: { quantidade: { type: :integer } }
        run_test!
      end
    end
  end
end
