class CentroDeCusto < ApplicationRecord
  has_many :plano_de_pagamentos, dependent: :restrict_with_exception
  validates :nome, presence: true, uniqueness: true
end
