module Types
  class MutationType < Types::BaseObject
    field :criar_plano, Types::PlanoDePagamentoType, null: true do
      argument :responsavel_id, Integer, required: true
      argument :centro_de_custo_id, Integer, required: true
      argument :cobrancas, [GraphQL::Types::JSON], required: true
    end

    field :registrar_pagamento, Types::PagamentoType, null: true do
      argument :cobranca_id, Integer, required: true
      argument :valor, Float, required: false
      argument :data_pagamento, GraphQL::Types::ISO8601Date, required: false
    end

    def criar_plano(responsavel_id:, centro_de_custo_id:, cobrancas: [])
      service = PlanosDePagamento::CriarPlano.new(params: {
        responsavel_id: responsavel_id,
        centro_de_custo_id: centro_de_custo_id,
        cobrancas: cobrancas
      })
      service.call
    end

    def registrar_pagamento(cobranca_id:, valor: nil, data_pagamento: nil)
      cobranca = ::Cobranca.find(cobranca_id)
      service = Pagamentos::RegistrarPagamento.new(cobranca: cobranca, params: { valor: valor, data_pagamento: data_pagamento })
      service.call
    end
  end
end