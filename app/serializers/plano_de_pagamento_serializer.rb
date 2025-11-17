class PlanoDePagamentoSerializer < ActiveModel::Serializer
  attributes :id, :responsavel_financeiro_id, :centro_de_custo_id, :valor_total, :total_cents
  has_many :cobrancas

  def valor_total
    if object.respond_to?(:total_cents) && object.total_cents
      (object.total_cents.to_f / 100.0)
    else
      object.valor_total.to_f
    end
  end
end
