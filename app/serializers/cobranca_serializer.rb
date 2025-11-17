class CobrancaSerializer < ActiveModel::Serializer
  attributes :id, :plano_id, :valor, :valor_cents, :data_vencimento,
             :metodo_pagamento, :status, :codigo_pagamento, :vencida

  def plano_id
    object.plano_de_pagamento_id
  end

  def valor
    (object.valor_cents.to_f / 100.0) if object.respond_to?(:valor_cents) && object.valor_cents
  end

  def vencida
    object.vencida?
  end
end
