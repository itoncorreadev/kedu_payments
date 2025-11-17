require 'swagger_helper'

RSpec.describe 'Centros de Custo API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/centros-de-custo' do
    get 'Lista centros de custo' do
      tags 'Centros de Custo'
      produces 'application/json'

      response '200', 'ok' do
        schema type: :array, items: { '$ref' => '#/components/schemas/CentroDeCusto' }
        before { create_list(:centro_de_custo, 2) }
        run_test!
      end
    end

    post 'Cria centro de custo' do
      tags 'Centros de Custo'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
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

      response '201', 'created' do
        let(:payload) { { centro_de_custo: { nome: 'MATRICULA' } } }
        schema '$ref' => '#/components/schemas/CentroDeCusto'
        run_test!
      end

      response '422', 'invalid' do
        let(:payload) { { centro_de_custo: { nome: '' } } }
        schema '$ref' => '#/components/schemas/ErrorResponse'
        run_test!
      end
    end
  end
end
