require 'swagger_helper'

RSpec.describe 'Pagamentos API', openapi_spec: 'v1/swagger.yaml', type: :request do
  path '/cobrancas/{cobranca_id}/pagamentos' do
    parameter name: :cobranca_id, in: :path, type: :string
    parameter name: :'Content-Type', in: :header, schema: { type: :string }
    parameter name: :Accept, in: :header, schema: { type: :string }

    post 'Registra pagamento' do
      tags 'Pagamentos'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          valor: { type: :number },
          data_pagamento: { type: :string, format: :date }
        },
        required: [ 'valor', 'data_pagamento' ]
      }

      response '201', 'created' do
        let(:'Content-Type') { 'application/json' }
        let(:Accept) { 'application/json' }
        let(:plano) { create(:plano_de_pagamento) }
        let(:cobranca) { plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida) }
        let(:cobranca_id) { cobranca.id }
        let(:payload) { { valor: 100.0, data_pagamento: Date.current } }
        let(:raw_post) { payload.to_json }
        schema '$ref' => '#/components/schemas/Pagamento'
        run_test!
      end

      response '422', 'invalid' do
        let(:'Content-Type') { 'application/json' }
        let(:Accept) { 'application/json' }
        let(:plano) { create(:plano_de_pagamento) }
        let(:cobranca) { plano.cobrancas.create!(valor_cents: 100_00, data_vencimento: Date.tomorrow, metodo_pagamento: :boleto, status: :emitida) }
        let(:cobranca_id) { cobranca.id }
        let(:payload) { { valor: 0, data_pagamento: Date.current } }
        let(:raw_post) { payload.to_json }
        schema '$ref' => '#/components/schemas/ErrorResponse'
        run_test!
      end
    end
  end
end
