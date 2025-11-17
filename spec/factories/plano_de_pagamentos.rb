FactoryBot.define do
  factory :plano_de_pagamento do
    association :responsavel_financeiro
    association :centro_de_custo
  end
end
