FactoryBot.define do
  factory :pagamento do
    cobranca { nil }
    valor_cents { 1 }
    data_pagamento { "2025-11-16" }
  end
end
