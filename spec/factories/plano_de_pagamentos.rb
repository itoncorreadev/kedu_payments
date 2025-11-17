FactoryBot.define do
  factory :plano_de_pagamento do
    responsavel_financeiro { nil }
    centro_de_custo { nil }
    valor_total_cents { 1 }
  end
end
