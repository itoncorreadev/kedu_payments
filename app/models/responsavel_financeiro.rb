class ResponsavelFinanceiro < ApplicationRecord
  has_many :planos_de_pagamento, dependent: :destroy
  validates :nome, presence: true
end
