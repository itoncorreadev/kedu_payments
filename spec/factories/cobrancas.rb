FactoryBot.define do
  factory :cobranca do
    association :plano_de_pagamento
    valor_cents { 100_00 }
    data_vencimento { Date.current + 30 }
    metodo_pagamento { :boleto }
    status { :emitida }

    trait :pix do
      metodo_pagamento { :pix }
    end

    trait :paga do
      status { :paga }
    end

    trait :cancelada do
      status { :cancelada }
    end

    trait :vencida do
      data_vencimento { Date.yesterday }
    end

    trait :vincenda do
      data_vencimento { Date.tomorrow }
    end
  end
end
