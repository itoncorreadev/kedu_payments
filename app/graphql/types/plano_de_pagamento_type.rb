module Types
  class PlanoDePagamentoType < BaseObject
    field :id, Integer, null: false
    field :responsavel_financeiro_id, Integer, null: false
    field :centro_de_custo_id, Integer, null: false
    field :valor_total_cents, Integer, null: true
    field :cobrancas, [ Types::CobrancaType ], null: true

    def valor_total_cents
      object.valor_total_cents || object.cobrancas.sum(:valor_cents)
    end
  end
end
