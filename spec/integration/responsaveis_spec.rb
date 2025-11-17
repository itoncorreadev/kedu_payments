require 'swagger_helper'

RSpec.describe 'Responsáveis API', swagger_doc: 'v1/swagger.yaml', type: :request do
  path '/responsaveis' do
    get 'Lista responsáveis' do
      tags 'Responsáveis'
      produces 'application/json'

      response '200', 'ok' do
        schema type: :array, items: { '$ref' => '#/components/schemas/ResponsavelFinanceiro' }
        before { create_list(:responsavel_financeiro, 2) }
        run_test!
      end
    end

    post 'Cria responsável' do
      tags 'Responsáveis'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          responsavel_financeiro: {
            type: :object,
            properties: { nome: { type: :string } },
            required: [ 'nome' ]
          }
        },
        required: [ 'responsavel_financeiro' ]
      }

      response '201', 'created' do
        let(:payload) { { responsavel_financeiro: { nome: 'Fulano' } } }
        schema '$ref' => '#/components/schemas/ResponsavelFinanceiro'
        run_test!
      end

      response '422', 'invalid' do
        let(:payload) { { responsavel_financeiro: { nome: '' } } }
        schema '$ref' => '#/components/schemas/ErrorResponse'
        run_test!
      end
    end
  end

  path '/responsaveis/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Exibe responsável' do
      tags 'Responsáveis'
      produces 'application/json'

      response '200', 'ok' do
        let(:id) { create(:responsavel_financeiro).id }
        schema '$ref' => '#/components/schemas/ResponsavelFinanceiro'
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
