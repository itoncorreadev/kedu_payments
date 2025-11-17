FactoryBot.define do
  factory :cobranca do
    association :plano_de_pagamento
    valor_cents { rand(50..100) * 100 }
    data_vencimento { Date.current + rand(1..60) }
    metodo_pagamento { %i[boleto pix].sample }
    status { :emitida }
  end
end
