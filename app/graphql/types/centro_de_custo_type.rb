module Types
  class CentroDeCustoType < BaseObject
    field :id, Integer, null: false
    field :nome, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
