class PlanoDePagamentoSerializer < ActiveModel::Serializer
  attributes :id, :responsavel_financeiro_id, :centro_de_custo_id, :valor_total, :total_cents
  has_many :cobrancas

  def valor_total
    object.total_money&.to_f
  end
end
