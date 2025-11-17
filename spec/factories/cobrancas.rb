FactoryBot.define do
  factory :cobranca do
    plano_de_pagamento { nil }
    valor_cents { 1 }
    data_vencimento { "2025-11-16" }
    metodo_pagamento { 1 }
    status { 1 }
    codigo_pagamento { "MyString" }
  end
end
