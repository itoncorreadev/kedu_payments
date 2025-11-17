module Types
  class QueryType < Types::BaseObject
    field :centros_de_custo, [ Types::CentroDeCustoType ], null: false
    field :plano, Types::PlanoDePagamentoType, null: true do
      argument :id, Integer, required: true
    end
    field :planos_do_responsavel, [ Types::PlanoDePagamentoType ], null: false do
      argument :responsavel_id, Integer, required: true
    end
    field :cobrancas_do_responsavel, [ Types::CobrancaType ], null: false do
      argument :responsavel_id, Integer, required: true
      argument :metodo_pagamento, String, required: false
      argument :status, String, required: false
      argument :vencida, Boolean, required: false
    end
    field :cobrancas_quantidade, Integer, null: false do
      argument :responsavel_id, Integer, required: true
    end

    def centros_de_custo
      ::CentroDeCusto.all
    end

    def plano(id:)
      ::PlanoDePagamento.find_by(id: id)
    end

    def planos_do_responsavel(responsavel_id:)
      ::PlanoDePagamento.where(responsavel_financeiro_id: responsavel_id).includes(:centro_de_custo, :cobrancas)
    end

    def cobrancas_do_responsavel(responsavel_id:, metodo_pagamento: nil, status: nil, vencida: nil)
      service = Cobrancas::ConsultaPorResponsavel.new(params: {
        responsavel_id: responsavel_id,
        metodoPagamento: metodo_pagamento,
        status: status,
        vencida: vencida ? "true" : nil
      })
      service.listar
    end

    def cobrancas_quantidade(responsavel_id:)
      service = Cobrancas::ConsultaPorResponsavel.new(params: { responsavel_id: responsavel_id })
      service.contar
    end
  end
end
