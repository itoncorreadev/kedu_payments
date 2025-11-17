module Types
  class CobrancaType < BaseObject
    field :id, Integer, null: false
    field :valor_cents, Integer, null: false
    field :data_vencimento, GraphQL::Types::ISO8601Date, null: false
    field :metodo_pagamento, String, null: false
    field :status, String, null: false
    field :codigo_pagamento, String, null: true
  end
end
