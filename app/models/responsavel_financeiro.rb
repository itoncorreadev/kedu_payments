class ResponsavelFinanceiro < ApplicationRecord
  has_many :plano_de_pagamentos, dependent: :destroy
  validates :nome, presence: true
end
