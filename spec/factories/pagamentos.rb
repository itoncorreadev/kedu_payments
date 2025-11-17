FactoryBot.define do
  factory :pagamento do
    association :cobranca
    valor_cents { cobranca.valor_cents }
    data_pagamento { Date.current }
  end
end
