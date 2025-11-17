FactoryBot.define do
  factory :centro_de_custo do
    nome { Faker::Commerce.department(max: 1, fixed_amount: true) }
  end
end
