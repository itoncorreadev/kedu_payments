class CentroDeCusto < ApplicationRecord
  has_many :planos_de_pagamento, dependent: :restrict_with_exception
  validates :nome, presence: true, uniqueness: true
end
