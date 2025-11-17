class PagamentoSerializer < ActiveModel::Serializer
  attributes :id, :cobranca_id, :valor, :valor_cents, :data_pagamento

  def valor
    (object.valor_cents.to_f / 100.0) if object.respond_to?(:valor_cents) && object.valor_cents
  end
end
