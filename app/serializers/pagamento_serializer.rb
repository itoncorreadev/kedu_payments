class PagamentoSerializer < ActiveModel::Serializer
  attributes :id, :cobranca_id, :valor, :valor_cents, :data_pagamento

  def valor
    object.valor_money&.to_f
  end
end
