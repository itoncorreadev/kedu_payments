class PlanoDePagamento < ApplicationRecord
  belongs_to :responsavel_financeiro
  belongs_to :centro_de_custo
  has_many :cobrancas, dependent: :destroy
  accepts_nested_attributes_for :cobrancas

  def calcular_total!
    update!(valor_total_cents: cobrancas.sum(:valor_cents))
  end

  def total_money
    cents = valor_total_cents || cobrancas.sum(:valor_cents)
    Money.new(cents.to_i, "BRL")
  end
end
