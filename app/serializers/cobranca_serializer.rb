class CobrancaSerializer < ActiveModel::Serializer
  attributes :id, :plano_id, :valor, :valor_cents, :data_vencimento,
             :metodo_pagamento, :status, :codigo_pagamento, :vencida

  def plano_id
    object.plano_de_pagamento_id
  end

  def valor
    object.valor_money&.to_f
  end

  def vencida
    object.vencida?
  end
end
