FactoryBot.define do
  factory :centro_de_custo do
    sequence(:nome) { |n| "Centro #{n}" }
  end
end
