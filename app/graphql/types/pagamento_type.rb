module Types
  class PagamentoType < BaseObject
    field :id, Integer, null: false
    field :cobranca_id, Integer, null: false
    field :valor_cents, Integer, null: false
    field :data_pagamento, GraphQL::Types::ISO8601Date, null: true
  end
end
